#!/usr/bin/env python3
# NOTE(bryce): Fetch client info for a given IP or MAC address
#  * 2021-02-21|>Alex|>Initial Version
#  * 2021-04-16|>Bryce|>Added JSON config

import ipaddress
import json
import mysql.connector
import re
import socket
import subprocess
import sys
import json

with open("/evix/secret-config.json") as config_f:
    config = json.load(config_f)

ADMIN_SERVER_HOSTNAME = 'evix-van01-master'
ANSIBLE_GROUP_PRIMARY_RS = 'routeservers-primary'
BRIDGE_IF = 'br10'
MAC_REGEX = re.compile('^([0-9a-f]{2}[:-]){5}([0-9a-f]{2})$')


def print_usage():
    print(f'Usage: {sys.argv[0]} <ip/mac address>')


def get_primary_rs_hostname():
    ansible_hosts = subprocess.run(['/usr/bin/ansible-inventory', '--list'], stdout=subprocess.PIPE,
                                   stderr=subprocess.DEVNULL, check=True)
    return json.loads(ansible_hosts.stdout)[ANSIBLE_GROUP_PRIMARY_RS]["hosts"][0]


def get_client_info_for_ip(ip_list):
    format_strings = ','.join(['%s'] * len(ip_list))
    try:
        database = mysql.connector.connect(user=config['database']['user'], password=config['database']['password'],
                                           host=config['database']['host'], database=config['database']['database'])
    except mysql.connector.Error as err:
        print("Something went wrong with the database connection:")
        print(err)
        exit(1)
    cursor = database.cursor(dictionary=True)
    cursor.execute(
        "SELECT DISTINCT c.id, c.name, c.contact, a.asn FROM ips i \
        JOIN asns a ON i.asn = a.asn \
        JOIN clients c ON a.client_id = c.id \
        WHERE ip IN (%s) AND provisioned = true" % format_strings, tuple(ip_list))
    return json.dumps(cursor.fetchall())


def get_ips_for_mac(mac):
    primary_rs = get_primary_rs_hostname()
    # ex. fe80::59:30ff:fe63:c8a3 dev br10 lladdr 02:59:30:63:c8:a3 STALE
    neighbors = subprocess.run(['/usr/bin/ssh', primary_rs, '/sbin/ip', 'neighbor'], stdout=subprocess.PIPE,
                               stderr=subprocess.DEVNULL, check=True)
    ips = []
    for line in neighbors.stdout.decode('utf-8').split('\n'):
        if f' {mac} ' in line:
            ips.append(line.split()[0])
    return ips


def get_mac_address_for_ip(ip):
    primary_rs = get_primary_rs_hostname()
    # IPv6 link-local addresses need to be pinged first as they may not be available in the current neighbor list
    if ip.version == 6 and ip.is_link_local:
        subprocess.run(['/usr/bin/ssh', primary_rs, '/bin/ping6', '-c', '3', f'{str(ip)}%{BRIDGE_IF}'],
                       stdout=subprocess.DEVNULL,
                       stderr=subprocess.DEVNULL, check=True)
    # ex. fe80::84f8:87ff:fe6c:77ef lladdr 86:f8:87:6c:77:ef REACHABLE
    neighbors = subprocess.run(['/usr/bin/ssh', primary_rs, '/sbin/ip', 'neighbor', 'show', 'dev', BRIDGE_IF],
                               stdout=subprocess.PIPE,
                               stderr=subprocess.DEVNULL, check=True)
    mac = ""
    for line in neighbors.stdout.decode('utf-8').split('\n'):
        if f'{ip} ' in line:
            mac = line.split()[2]
    return mac


if __name__ == "__main__":
    if socket.gethostname() != ADMIN_SERVER_HOSTNAME:
        print("Error: This script needs to be run from the admin server!")
        exit(1)

    if len(sys.argv) != 2 or "-h" in sys.argv[1]:
        print_usage()
        exit(0)
    else:
        parameter = sys.argv[1].lower()

    ip = ipaddress.ip_address('127.0.0.1')
    clients = mac = ""

    try:
        ip = ipaddress.ip_address(parameter)
    except ValueError:
        if MAC_REGEX.match(parameter):
            mac = parameter

    if ip.is_link_local:
        mac = get_mac_address_for_ip(ip)

    if mac:
        ip_list = get_ips_for_mac(mac)
        if len(ip_list) > 0:
            clients = get_client_info_for_ip(ip_list)

    if ip.is_global:
        clients = get_client_info_for_ip([str(ip)])

    if clients:
        print(clients)
    else:
        print(f'No results found for IP or MAC address "{parameter}".')
