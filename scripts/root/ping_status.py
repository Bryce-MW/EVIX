#! /usr/bin/env python3
# NOTE(bryce): Written by Bryce Wilson 2021-01-01
#  * 2021-01-01|>Bryce|>Copied from warn_disconnection.py

import datetime
import sys
from click import secho, style
import mysql.connector

database = None
up = r"/\"
down = r"\/"

try:
    database = mysql.connector.connect(user='evix', password='***REMOVED***', host='127.0.0.1', database='evix', autocommit=True)
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
