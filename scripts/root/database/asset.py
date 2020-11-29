#! /usr/bin/python3

import datetime
from os.path import expanduser
from subprocess import call

import mysql.connector

from validateASSET import get_as_set
from whois_strings import *

database = mysql.connector.connect(
    host="localhost",
    user="evix",
    passwd="***REMOVED***",
    database="evix"
)

cursor = database.cursor()
cursor.execute("SELECT asn FROM asns;")
updatedASN = []
for line in cursor:
    updatedASN.append((get_as_set(str(line[0])), line[0]))

IRREntry = evix_as_set_header

for asset in updatedASN:
    IRREntry += "\nmembers:         " + asset[0]
    IRREntry += "\nmembers:         AS" + asset[1]

date = datetime.datetime.now().replace(microsecond=0).isoformat().split('T')[0].replace('-', '')

IRREntry += evix_as_set_footer.format(date=date)

print(IRREntry)

with open(expanduser("~/temporaryEmail"), 'w') as file:
    file.write(IRREntry)
    file.close()
    call("mail -s \"[ALTDB] as-set: AS-EVIX [update]\" \"auto-dbm@altdb.net\" < ~/temporaryEmail", shell=True)
