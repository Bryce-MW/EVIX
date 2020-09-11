#! /usr/bin/python3

import json
from subprocess import check_output
from subprocess import call
import urllib3
import sys
import datetime
from os.path import expanduser

def normalizeASN(ASN):
	"Takes an ASN and removes the 'AS' prefix if any"
	return ASN.upper().replace("AS","")


def validateSET(ASSET):
	"Takes and AS-SET and checks if it is valid"
	#%  No entries found for the selected source(s).
	whoisData = str(check_output(["whois", "-h", "rr.ntt.net", "-T", "as-set", ASSET]))
	if "%  No entries found for the selected source(s)." in whoisData:
		return False
	return True

def createMultiSet(ASSETs, name):
	IRREntry = "as-set:          "+name+"""\ndescr:           Combo AS-SET
remarks:         This object has been created automatically
remarks:         by a python script. Email
remarks:         bryce@thenetworknerds.ca if there are any
remarks:         issues.
remarks:         This object was created beacause someone
remarks:         has listed two AS-SETs so we had to make a
remarks:         combo object to work with programms that
remarks:         only support a single AS-SET"""
	for ASSET in ASSETs:
		IRREntry += "\nmembers:         " + ASSET
	IRREntry += """\nmnt-by:          MAINT-AS396503
mnt-by:          MAINT-BRYCE
changed:         bmwilson@evix-svr1.evix.org """
	IRREntry += datetime.datetime.now().replace(microsecond=0).isoformat().split('T')[0].replace('-', '')+"\nsource:          ALTDB"
	with open(expanduser("~/temporaryEmail"), 'w') as file:
		file.write(IRREntry)
		file.close()
		call("mail -s \"[ALTDB] as-set: AS-EVIX [update]\" \"auto-dbm@altdb.net\" < ~/temporaryEmail",shell=True)

def getASSET(ASN):
	"Attempt to get the AS-SET associated with an ASN"
#	import pdb; pdb.set_trace()
	ASN = normalizeASN(ASN)
	if not ASN.isdigit():
		print("ASN, " + ASN + ", is not a number")
		raise ValueError("ASN " + ASN + ", is not a number")
	ASInfo = str(check_output(["curl", "-s", "https://peeringdb.com/api/net?asn=" + ASN]))[2:-1]
			#The peeringdb API adds some werid charactors so we remove them ^
	try:
		ASInfoParced = json.loads(ASInfo)
	except json.decoder.JSONDecodeError:
		weirdASNs = urllib3.urlopen("https://thenetworknerds.ca/scripts/weirdASNs.txt")
		for weirdASN in weirdASNs:
			weirdASNA = weirdASN.split(" ")
			if len(weirdASNA) == 2:
				if ASN == weirdASNA[0]:
					return weirdASNA[1]
		return("AS" + ASN)
	try:
		ASInfoParced['meta']['error']
		return("AS" + ASN)
	except KeyError:
		pass
	ASSet = ""
	for set in ASInfoParced['data'][0]['irr_as_set'].split(" "):
		if "::" in set:
			set = set.split("::")[1]
		ASSet += ", " + set
	if ASSet.startswith(", "):
		ASSet = ASSet[2:]
	if ASSet.startswith(","):
		ASSet = ASSet[1:]
	if ASSet == "":
		return("AS" + ASN)
	if ", " in ASSet:
		longTitle = "AS-BRYCE-MULTISET"
		for ASSetSingle in ASSet.split(", "):
			longTitle += "-" + ASSetSingle
		if not validateSET(longTitle):
			createMultiSet(ASSet.split(", "), longTitle)
		ASSet = longTitle
	else:
		if not validateSET(ASSet):
			return("AS" + ASN)
	return(ASSet)

if __name__ == "__main__":
	if len(sys.argv) < 2:
		print("Usage: " + sys.argv[0] + " ASN")
		exit(-1)
	print(getASSET(sys.argv[1]))
	exit(0)
