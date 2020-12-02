#! /bin/python3

import datetime
import smtplib
import ssl
import sys

import mysql.connector

email = """From: "EVIX Support" <support@evix.org>
To: "{name}" <{contact}>
BCC: "EVIX Peering" <peering@evix.org>
Subject: EVIX IPv{version} session down

Hi {name}!

Your IPv{version} session with EVIX has been down for {difference} days.

If your session has been down for 14 days or more, it will be deprovisioned.
If you wish to have your IP reprovisioned, please *do not* send a new
request. Please just reply to this email. If you are still setting up your
session, let us know on your original ticket and we will reprovision it for
you. This email was sent by a robot who does not know that you are still
setting up your tunnel!


Here are your connection details:
ASN: {asn}
IPv{version}: {ip}
Route Server: {server}

If you believe this to be in error, please reply to this email.
"""

database = None

try:
    database = mysql.connector.connect(user='evix', password='***REMOVED***', host='127.0.0.1', database='evix', autocommit=True)
except mysql.connector.Error as err:
    print("Something went wrong with the database connection:")
    print(err)
    exit(1)

context = ssl.create_default_context()

version = sys.argv[1]
rt = sys.argv[2]
now = datetime.datetime.now()
print("\n\n")
print(now)

cursor = database.cursor(buffered=True)

with smtplib.SMTP_SSL("***REMOVED***", 465, context=context) as server:
    # server.set_debuglevel(2)
    server.login("scripts", "***REMOVED***")
    # NOTE(bryce): This is because we WANT to set them all to false and then set to true when we find it
    # noinspection SqlWithoutWhere
    cursor.execute("UPDATE ips SET birdable=false")
    for i in sys.stdin:
        line = i.split()
        asn = line[4].replace("AS", '').split("_")[0]
        ip = line[3]
        if line[0] == "up":
            cursor.execute("UPDATE ips SET birdable=true WHERE ip=%s", (ip,))
            cursor.execute("SELECT 1 FROM clients INNER JOIN asns ON client_id=id INNER JOIN ips ON ips.asn=asns.asn WHERE ip=%s AND monitor=true AND provisioned=true", (ip,))
            if len(tuple(cursor)) == 0:
                cursor.execute("UPDATE ips SET provisioned=true, monitor=true WHERE ip=%s", (ip,))
                print(f"+ Found up session for {asn} over {ip}. Set provisioned and monitored")
            continue
        since = datetime.datetime.strptime(" ".join(line[1:3]), "%Y-%m-%d %H:%M:%S")
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
                server.sendmail("support@evix.org", (contact, "peering@evix.org"), email.format(name=name, version=version, difference=difference, asn=asn, ip=ip, server=rt, contact=contact))
                print(f"Sent deprovision for {asn} over {ip} to {contact}")
            elif difference == 3 and provisioned:
                server.sendmail("support@evix.org", (contact, "peering@evix.org"), email.format(name=name, version=version, difference=difference, asn=asn, ip=ip, server=rt, contact=contact))
                print(f"Sent warning for {asn} over {ip} to {contact}")
