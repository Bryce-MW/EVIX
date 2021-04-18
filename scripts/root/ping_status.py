#! /usr/bin/env python3
# NOTE(bryce): Written by Bryce Wilson 2021-01-01
#  * 2021-01-01|>Bryce|>Copied from warn_disconnection.py
#  * 2021-04-16|>Bryce|>Added JSON config

import datetime
import json
import sys

import mysql.connector
from click import secho

with open("/evix/secret-config.json") as config_f:
    config = json.load(config_f)

database = None
up = "/\\"
down = "\\/"

try:
    database = mysql.connector.connect(user=config['database']['user'], password=config['database']['password'],
                                       host=config['database']['host'], database=config['database']['database'],
                                       autocommit=True)
except mysql.connector.Error as err:
    print("Something went wrong with the database connection:")
    print(err)
    exit(1)

now = datetime.datetime.now()

cursor = database.cursor(buffered=True)

found = False
for i in sys.stdin:
    line = i.split()
    can_ping = line[0] == "yes"
    ip = line[1]
    cursor.execute("SELECT pingable FROM ips WHERE ip=%s", (ip,))
    pingable_before = bool(tuple(cursor)[0][0])
    if pingable_before != can_ping:
        found = True
        secho(f"{now} {up if can_ping else down} {ip}", fg=('green' if can_ping else 'red'))
    if can_ping:
        cursor.execute("UPDATE ips SET pingable=true WHERE ip=%s", (ip,))
    else:
        cursor.execute("UPDATE ips SET pingable=false WHERE ip=%s", (ip,))

if found:
    print()
