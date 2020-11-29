#! /usr/bin/python3

import datetime
import json
import sys
from os.path import expanduser
from subprocess import call, check_output

import urllib3

# NOTE(bryce): Text for new IRR objects is stored here:
from whois_strings import *


def normalize_asn(asn):
    """Takes an ASN and removes the 'AS' prefix if any"""
    return asn.upper().replace("AS", "")


def validate_as_set(as_set):
    """Takes and AS-SET and checks if it is valid"""
    # %  No entries found for the selected source(s).
    whois_data = str(check_output(["whois", "-h", "rr.ntt.net", "-T", "as-set", as_set]))
    if "%  No entries found for the selected source(s)." in whois_data:
        return False
    return True


def create_multi_as_set(as_sets, name):
    irr_entry = multi_as_set_header.format(name=name)
    for ASSET in as_sets:
        irr_entry += "\nmembers:         " + ASSET
    date = datetime.datetime.now().replace(microsecond=0).isoformat().split('T')[0].replace('-', '')
    irr_entry += multi_as_set_footer.format(date=date)
    with open(expanduser("~/temporaryEmail"), 'w') as file:
        file.write(irr_entry)
        file.close()
        call("mail -s \"[ALTDB] as-set: AS-EVIX [update]\" \"auto-dbm@altdb.net\" < ~/temporaryEmail", shell=True)


def get_as_set(asn):
    """Attempt to get the AS-SET associated with an ASN"""
    asn = normalize_asn(asn)
    if not asn.isdigit():
        raise ValueError("ASN " + asn + ", is not a number")
    as_info = str(check_output(["curl", "-s", "https://peeringdb.com/api/net?asn=" + asn]))[2:-1]
    # The peeringdb API adds some weird characters so we remove them using the slice
    try:
        as_info_parced = json.loads(as_info)
    except json.decoder.JSONDecodeError:
        # TODO(bryce): I have since removed this URL. It should be replaced with something better
        weird_asns = urllib3.urlopen("https://thenetworknerds.ca/scripts/weirdASNs.txt")
        for weird_asn in weird_asns:
            weird_asn = weird_asn.split(" ")
            if len(weird_asn) == 2 and asn == weird_asn[0]:
                return weird_asn[1]
        return "AS" + asn
    if 'meta' in as_info_parced and 'error' in as_info_parced['meta']:
        return "AS" + asn
    as_set = ""
    for as_set_str in as_info_parced['data'][0]['irr_as_set'].split():
        if "::" in as_set_str:
            as_set_str = as_set_str.split("::")[1]
        as_set += ", " + as_set_str
    if as_set.startswith(", "):
        as_set = as_set[2:]
    if as_set.startswith(","):
        as_set = as_set[1:]
    if as_set == "":
        return "AS" + asn
    if ", " in as_set:
        multi_set = "AS-BRYCE-MULTISET"
        for single_as_set in as_set.split(", "):
            multi_set += "-" + single_as_set
        if not validate_as_set(multi_set):
            create_multi_as_set(as_set.split(", "), multi_set)
        as_set = multi_set
    else:
        if not validate_as_set(as_set):
            return "AS" + asn
    return as_set


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: " + sys.argv[0] + " ASN")
        exit(-1)
    print(get_as_set(sys.argv[1]))
    exit(0)
