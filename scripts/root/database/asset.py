#! /usr/bin/python3

from validateASSET import getASSET
import mysql.connector
import socket, struct
import datetime
from os.path import expanduser
from subprocess import call

mydb = mysql.connector.connect(
        host="localhost",
        user="evix",
        passwd="***REMOVED***",
        database="evix"
)

mycursor = mydb.cursor()
mycursor.execute("SELECT asn FROM asns;")
updatedASN = []
for line in mycursor:
        updatedASN.append((getASSET(str(line[0])),line[0]))


IRREntry = """as-set:          AS-EVIX
descr:           Members of EVIX
remarks:         This object has been created automatically
remarks:         using a python script which reads from our members database.
remarks:         If there are errors, please email bryce@thenetworknerds.ca\n"""

for asset in updatedASN:
	IRRENTRY += "\nmembers:         " + asset
for asn in mycursor:
	IRRENTRY += "\nmembers:         AS" + str(asn)

IRREntry+="""mnt-by:          MAINT-EVIX
changed:         root@evix-svr1.evix.org """+\
datetime.datetime.now().replace(microsecond=0).isoformat().split('T')[0].replace('-', '')+\
"\nsource:          ALTDB"

print (IRREntry)

with open(expanduser("~/temporaryEmail"), 'w') as file:
        file.write(IRREntry)
        file.close()
        call("mail -s \"[ALTDB] as-set: AS-EVIX [update]\" \"auto-dbm@altdb.net\" < ~/temporaryEmail",shell=True)
