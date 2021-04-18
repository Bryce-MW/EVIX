#! /usr/bin/python3
# NOTE(bryce): Written by Bryce Wilson a while ago and added to git on 2020-09-10.
#  * 2020-11-28|>Bryce|>Did some refactoring
#  * 2021-04-16|>Bryce|>Added JSON config

# TODO(bryce):
#  <-> 2020-11-28 ==> This needs to be re-written and likely done very differently

import datetime
import json
from os.path import expanduser
from subprocess import call

import mysql.connector

from validateASSET import get_as_set
from whois_strings import *

with open("/evix/secret-config.json") as config_f:
    config = json.load(config_f)

database = mysql.connector.connect(
    user=config['database']['user'],
    password=config['database']['password'],
    host=config['database']['host'],
    database=config['database']['database']
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
