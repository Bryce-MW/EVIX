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

email_warning = """From: "EVIX Support" <support@evix.org>
To: "{name}" <{contact}>
BCC: "EVIX Peering" <peering@evix.org>
Subject: Your EVIX RS session - {ip}

Hi {name} (AS{asn})!

This is a new email system so let us know if it does
something weird. Make sure to read the whole email since it
is different than before.

You currently have a connection with one or more of our route
servers. We just wanted to remind you that we have two route
servers. Details below. This is reminder {count}/3.

Fremont Route Sever:
  IPv4 - 206.81.104.1
  IPv6 - 2602:fed2:fff:ffff::1
  ASN  - 137933

Amsterdam Route Server:
  IPv4 - 206.81.104.253
  IPv6 - 2602:fed2:fff:ffff::253
  ASN  - 209762

We currently see the following session(s) being down

{sessions}

If you believe this to be in error, please reply to this email
with as many details as you can.
"""

session_template = """
{RS}:
  IP         - {ip}
  Down since - {since} ({days} days)
  Last Error - {error}
"""

email_remove = """From: "EVIX Support" <support@evix.org>
To: "{name}" <{contact}>
BCC: "EVIX Peering" <peering@evix.org>
Subject: Your EVIX RS session - {ip}

Hi {name} (AS{asn})!

This is a new email system so let us know if it does
something weird. Make sure to read the whole email since it
is different than before.

The IP {ip} currently has no sessions with any of our route
servers. The connection details of our route servers are
below. {remove}

Fremont Route Sever:
  IPv4 - 206.81.104.1
  IPv6 - 2602:fed2:fff:ffff::1
  ASN  - 137933

Amsterdam Route Server:
  IPv4 - 206.81.104.253
  IPv6 - 2602:fed2:fff:ffff::253
  ASN  - 209762

We currently see the following session(s) being down

{sessions}

If you believe this to be in error, please reply to this email
with as many details as you can.
"""

remove_template = "No session has been up in the past 4 weeks so we are\nremoving your IP, contact us to have them provisioned again."

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
        session = json.loads(i)
        cursor.execute("SELECT birdable FROM ips WHERE ip=%s", (session['ip'],))
        warnings_sent = cursor.fetchone()[0]
        if session['up']:
            if session['down']:
                if warnings_sent < (now - datetime.fromtimestamp(max(i['status']['since'] for i in session['down']))).days // 7 <= 3:
                    cursor.execute("SELECT contact,monitor,asns.asn,provisioned FROM clients INNER JOIN asns ON client_id=id INNER JOIN ips ON ips.asn=asns.asn WHERE ip=%s", (session['ip'],))
                    email, monitor, asn, provisioned = cursor.fetchone()
                    if not provisioned:
                        if not email:
                            print(f"Error: {session['ip']} is not provisioned. Bird config not updated?")
                            continue
                    if monitor:
                        if not email:
                            print(f"Error: {session['down'][0]['status']['description']}, not sending warning for {session['ip']}")
                            continue
                        server.sendmail("support@evix.org", (email, "peering@evix.org"), email_warning.format(
                            name=session['down'][0]['status']['description'],
                            contact=email,
                            ip=session['ip'],
                            count=warnings_sent + 1,
                            asn=asn,
                            sessions="".join(session_template.format(
                                RS=i['server'],
                                ip=i['status']['neighbor_address'],
                                since=datetime.fromtimestamp(i['status']['since']),
                                error=i['status']['last_error'] if 'last_error' in i['status'] else "Bird reports no errors",
                                days=(now - datetime.fromtimestamp(i['status']['since'])).days
                            ) for i in session['down'])
                        ))
                        print(f"Warned {session['ip']}: {email} {warnings_sent + 1}/3")
                        cursor.execute("UPDATE ips SET birdable=%s WHERE ip=%s", (weeks, session['ip']))
            else:
                cursor.execute("UPDATE ips SET birdable=%s WHERE ip=%s", (0, session['ip']))
        else:
            weeks = (now - datetime.fromtimestamp(max(i['status']['since'] for i in session['down']))).days // 7
            if warnings_sent < weeks:
                cursor.execute("SELECT contact,monitor,asns.asn,provisioned FROM clients INNER JOIN asns ON client_id=id INNER JOIN ips ON ips.asn=asns.asn WHERE ip=%s", (session['ip'],))
                email, monitor, asn, provisioned = cursor.fetchone()
                if not provisioned:
                    if not email:
                        print(f"Error: {session['ip']} is not provisioned. Bird config not updated?")
                        continue
                if monitor:
                    if not email:
                        print(f"Error: {session['down'][0]['status']['description']} has no email, not sending remove for {session['ip']}")
                        continue
                    server.sendmail("support@evix.org", (email, "peering@evix.org"), email_remove.format(
                        name=session['down'][0]['status']['description'],
                        contact=email,
                        ip=session['ip'],
                        remove=remove_template if weeks >= 4 else "",
                        asn=asn,
                        sessions="".join(session_template.format(
                            RS=i['server'],
                            ip=i['status']['neighbor_address'],
                            since=datetime.fromtimestamp(i['status']['since']),
                            error=i['status']['last_error'] if 'last_error' in i['status'] else "Bird reports no errors",
                            days=(now - datetime.fromtimestamp(i['status']['since'])).days
                        ) for i in session['down'])
                    ))
                    print(f"Removed {session['ip']}: {email} {warnings_sent + 1}/4")
                    cursor.execute("UPDATE ips SET birdable=%s WHERE ip=%s", (weeks, session['ip']))
                    if weeks >= 4:
                        cursor.execute("UPDATE ips SET provisioned=%s WHERE ip=%s", (False, session['ip']))
