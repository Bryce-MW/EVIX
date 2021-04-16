# NOTE(bryce): Written by Bryce Wilson on 2020-09-11
#  * 2020-09-16|>Bryce|>Fixed many issues that cause the table to not always be created correctly
#  * 2020-09-16|>Bryce|>Attempt to ensure that improperly formatted links do not link to ourselves
#  * 2020-11-29|>Bryce|>Move strings to peers_table_webpage_strings.py so that this file is easier to read
#  * 2021-04-16|>Bryce|>Added JSON config

import ipaddress
import json

import mysql.connector

# NOTE(bryce): This is where all of the strings inserted into the table are kept
from peers_table_webpage_strings import *

with open("/evix/secret-config.json") as config_f:
    config = json.load(config_f)

database = None
try:
    database = mysql.connector.connect(user=config['database']['user'], password=config['database']['password'],
                                       host=config['database']['host'], database=config['database']['database'])
except mysql.connector.Error as err:
    print("Something went wrong with the database connection:")
    print(err)
    exit(1)

table = ""

clients_cursor = database.cursor(dictionary=True, buffered=True)
asns_cursor = database.cursor(dictionary=True, buffered=True)
ips_cursor = database.cursor(dictionary=True, buffered=True)
connections_cursor = database.cursor(dictionary=True, buffered=True)

clients_cursor.execute("SELECT id,name,website,contact FROM clients")

clients = tuple((i, tuple((ipaddress.ip_address(j['ip']).version, ipaddress.ip_address(j['ip']).packed) for j in next(
    ips_cursor.execute("SELECT ip FROM ips \
                       INNER JOIN asns ON ips.asn=asns.asn \
                       WHERE provisioned=true AND client_id=%s \
                       ORDER BY (ip not like '%:%') DESC, INET6_ATON(ip)",
                       (i['id'],), multi=True)))) for i in clients_cursor)

for client, _ in sorted(clients, key=lambda x: x[1]):
    asns_cursor.reset()
    connections_cursor.reset()
    asns_cursor.execute(
        "SELECT asn FROM asns \
        WHERE client_id = %s AND \
        EXISTS (SELECT 1 FROM ips WHERE asns.asn=ips.asn AND provisioned=1)",
        (client['id'],))
    connections_cursor.execute("SELECT type,server FROM connections WHERE client_id = %s", (client['id'],))
    connections = tuple(connections_cursor)
    connections_counter = 0
    if len(connections) == 0:
        connections = ({'type': '-----', 'server': '-----'},)

    first = True
    multiple = asns_cursor.rowcount > 1
    n = 0
    total = 0
    for asn in asns_cursor:
        ips_cursor.reset()
        ips_cursor.execute(
            "SELECT ip,version,provisioned FROM ips WHERE asn = %s ORDER BY (ip not like '%:%') DESC, INET6_ATON(ip)",
            (asn['asn'],))

        ips = tuple(i for i in ips_cursor if i['provisioned'])
        ipv4 = tuple(i for i in ips if i['version'] == 4)
        ipv6 = tuple(i for i in ips if i['version'] == 6)

        is_website = bool(client["website"])
        website = client['website'] or ""
        if not (website.startswith("https://") or website.startswith("http://")):
            website = "http://" + website
        if not is_website:
            website = "javascript:alert('User has not set a website.')"

        n_ips = max(len(ipv4), len(ipv6))

        multiple = multiple or n_ips > 1
        n += n_ips

        first_ip = True
        for i in range(n_ips):
            connection = connections[connections_counter]
            if connections_counter < len(connections) - 1:
                connections_counter += 1
            server = connection['server']
            obj_type = connection['type']

            total += 1
            ipv4_str = ipv4[i]['ip'] if i < len(ipv4) else "-----"
            ipv6_str = ipv6[i]['ip'] if i < len(ipv6) else "-----"

            name = client['name'] if first else ""
            asn = asn['asn'] if first_ip else ""

            if multiple and first:
                table += multi_asn_entry.format(website=website, name=name, asn=asn, ipv4=ipv4_str, ipv6=ipv6_str, server=server, type=obj_type)
            else:
                if not multiple:
                    table += single_asn_footer
                elif total == 2:
                    table += multi_asn_footer
                table += single_asn_entry.format(website=website, name=name, asn=asn, ipv4=ipv4_str, ipv6=ipv6_str, server=server, type=obj_type)
            if total == n:
                table += '</tbody>'
            first_ip = False
            first = False

print(header)
print(table)
print(invisible_asn * 5)

database.close()
