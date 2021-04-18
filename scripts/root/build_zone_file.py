#!/usr/bin/python3
# NOTE(bryce): Written Nate Sales on 2020-12-14.
#  * 2021-04-16|>Bryce|>Added JSON config

import ipaddress
import json
from os import system
from time import time

import mysql.connector
from jinja2 import Template

zone_template = Template("""
$TTL	86400
@	IN	SOA	ns1.evix.org. support.evix.org. {{ serial }} 86400 7200 3600000 86400
@	IN	NS	ns1.evix.org.

{% for record in records %}{{ record["label"] }}    IN    PTR    {{ record["value"] }}
{% endfor %}

""")

with open("/evix/secret-config.json") as config_f:
    config = json.load(config_f)

database = mysql.connector.connect(user=config['database']['user'], password=config['database']['password'], host=config['database']['host'], database=config['database']['database'])
cursor = database.cursor()
cursor.execute("SELECT * FROM ips;")

ipv4 = []
ipv6 = []

for line in cursor:
    address = ipaddress.ip_address(line[0])
    asn = str(line[2])

    record = {
        "label": address.reverse_pointer + ".",
        "value": "as" + str(line[2]) + ".evix.org."
    }

    if line[1] == 4:
        ipv4.append(record)
    else:
        ipv6.append(record)

serial = str(int(time()))

print(f"Writing zone files with serial {serial}...", end="", flush=True)

with open("/etc/bind/db.104.81.206.in-addr.arpa", "w") as ipv4_zone_file:
    ipv4_zone_file.write(zone_template.render(records=ipv4, serial=serial))

with open("/etc/bind/db.f.f.f.f.f.f.f.0.2.d.e.f.2.0.6.2.ip6.arpa", "w") as ipv6_zone_file:
    ipv6_zone_file.write(zone_template.render(records=ipv6, serial=serial))

print("DONE")

print("Reloading bind...", end="", flush=True)
system("/usr/sbin/rndc reload")
