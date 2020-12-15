#!/usr/bin/python3
# 12/14/2020 Nate Sales

import mysql.connector
from jinja2 import Template
import ipaddress
from time import time
from os import system

zone_template = Template("""
$TTL	86400
@	IN	SOA	ns1.evix.org. support.evix.org. {{ serial }} 86400 7200 3600000 86400
@	IN	NS	ns1.evix.org.

{% for record in records %}{{ record["label"] }}    IN    PTR    {{ record["value"] }}
{% endfor %}

""")

database = mysql.connector.connect(host="localhost", user="evix", passwd="***REMOVED***", database="evix")
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
system("rndc reload")
