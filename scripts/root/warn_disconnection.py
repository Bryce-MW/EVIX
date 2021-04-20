#! /bin/python3
# NOTE(bryce): Written by Bryce Wilson 2020-09-11
#  * 2020-11-24|>Bryce|>Removed P.S. from message
#  * 2020-11-29|>Bryce|>Opportunistically reprovision sessions
#  * 2020-11-30|>Bryce|>Add tracking of up sessions directly
#  * 2020-12-15|>Bryce|>Change script name from peers-status to warn_disconnection
#  * 2021-02-18|>Bryce|>Add error and use new date format
#  * 2021-04-16|>Bryce|>Added JSON config

import json
import smtplib
import ssl
import sys
from datetime import datetime

import mysql.connector

email = """From: "EVIX Support" <support@evix.org>
To: "{name}" <{contact}>
BCC: "EVIX Peering" <peering@evix.org>
Subject: EVIX IPv{version} session down

Hi {name}!

Your IPv{version} session with EVIX has been down for {difference} days.

If your session has been down for 14 days or more, it will be deprovisioned.
Please reply to this email with as many details as you can to help us fix
the problem. We are volunteers with very limited time so please respect that
we may not reply quickly and help us as much as possible. Be sure to check
if this email is about your IPv4 or IPv6 session and which route server this
disconnection was seen at. This email was sent by a robot so it may not know
if you are in a specific situation that you have already discussed with us.
If you already have a ticket, reply to that rather than replying to this
email.

Sincerely,
Your EVIX Admins (and the script that sent this email)


Here are your connection details:
ASN: {asn}
IPv{version}: {ip}
Route Server: {server}
Last seen connected: {since}
{error}

If you believe this to be in error, please reply to this email.
"""

with open("/evix/secret-config.json") as config_f:
    config = json.load(config_f)
database = None

try:
    database = mysql.connector.connect(user=config['database']['user'], password=config['database']['password'],
                                       host=config['database']['host'], database=config['database']['database'],
                                       autocommit=True)
except mysql.connector.Error as err:
    print("Something went wrong with the database connection:")
    print(err)
    exit(1)

context = ssl.create_default_context()

now = datetime.now()
print("\n\n")
print(now)

cursor = database.cursor(buffered=True)

with smtplib.SMTP_SSL(config['mail']['server'], config['mail']['port'], context=context) as server:
    # server.set_debuglevel(2)
    server.login(config['mail']['username'], config['mail']['password'])
    for i in sys.stdin:
        res = json.loads(i)
        version = res['version']
        rt = res["server"]
        line = res['old'].split()
        status = line[0]
        date = int(line[1])
        ip = line[2]
        asn = line[3]
        error = ("Last error: " + " ".join(line[4:])) if line[4] != "null" else "Bird reports no errors"
        if status == "up":
            cursor.execute("UPDATE ips SET birdable=true WHERE ip=%s", (ip,))
            cursor.execute("SELECT 1 FROM clients INNER JOIN asns ON client_id=id INNER JOIN ips ON ips.asn=asns.asn WHERE ip=%s AND monitor=true AND provisioned=true", (ip,))
            if len(tuple(cursor)) == 0:
                cursor.execute("UPDATE ips SET provisioned=true, monitor=true WHERE ip=%s", (ip,))
                print(f"+ Found up session for {asn} over {ip}. Set provisioned and monitored")
            continue
        since = datetime.fromtimestamp(date)
        difference = (now - since).days
        if difference == 3 or difference >= 14:
            cursor.execute("SELECT name,contact,provisioned FROM clients INNER JOIN asns ON client_id=id INNER JOIN ips ON ips.asn=asns.asn WHERE ip=%s AND monitor=true AND provisioned=true", (ip,))
            results = tuple(cursor)
            if len(results) == 0:
                print(f"- No result found for {asn} over {ip} (not monitored or deprovisioned?)")
                continue
            name, contact, provisioned = results[0]
            if not contact:
                print(f"Error: {name} has no email, not sending email for {asn} over {ip}")
                continue
            if difference >= 14 and provisioned:
                cursor.execute("UPDATE ips SET provisioned=false WHERE ip=%s", (ip,))
                if cursor.rowcount == 0:
                    print(f"- Could not deprovision {ip}?")
                results = tuple(cursor)
                server.sendmail("support@evix.org", (contact, "peering@evix.org"), email.format(name=name, version=version, difference=difference, asn=asn, ip=ip, server=rt, contact=contact, error=error, since=since))
                print(f"Sent deprovision for {asn} over {ip} to {contact}")
            elif difference == 3 and provisioned:
                server.sendmail("support@evix.org", (contact, "peering@evix.org"), email.format(name=name, version=version, difference=difference, asn=asn, ip=ip, server=rt, contact=contact, error=error, since=since))
                print(f"Sent warning for {asn} over {ip} to {contact}")
