#! /usr/bin/env python3
import cgi
import cgitb
cgitb.enable()
if __name__ == "__main__":
    print("Content-type: text/html\n")

from jinja2 import Environment, PackageLoader, select_autoescape
import json
import validators
import mysql.connector
import smtplib
import ssl
import sys
sys.stderr = sys.stdout

email_template = """To: "EVIX Helpdesk" <helpdesk@evix.org>
BCC: "{name}" <{contact}>
Subject: EVIX Join Request - {name}

Hi {name}!

Thanks for filling out the form to join EVIX.
Please look over the information below to see
if it is accurate. If so then we will get
back to you as soon as we can.

Name: {name}
ASN: {asn}
Email Address: {contact}
Website: {website}
Peering Location: {location}
Connection Type: {type}
Needs IPv4: {ipv4}

You also supplied the following additional comment:
{comments}

Have a nice day!
"""

def print_error(error):
    print(template.render(correct=False, error=error))
    exit(0)

if __name__ == "__main__":
    with open("/evix/secret-config.json") as config_f:
        config = json.load(config_f)
    database = None
    try:
        database = mysql.connector.connect(user=config['database']['user'], password=config['database']['password'],
                                           host=config['database']['host'], database=config['database']['database'],
                                           autocommit=True)
    except mysql.connector.Error as err:
        print("<pre>Something went wrong with the database connection:")
        print(err)
        exit(1)
    cursor = database.cursor()

    env = Environment(
        loader=PackageLoader("peering_form", ""),
        autoescape=select_autoescape()
    )

    template = env.get_template("peering_form.jinja.html")

    form = cgi.FieldStorage()
    # Expected elements: name, asn, contact, website (optional), location, type, ipv4 (bool), comments (optional)
    if "name" not in form:
        print_error("No name was supplied.")
    name = form.getfirst("name")

    if "asn" not in form:
        print_error("No ASN was supplied.")
    asn = form.getfirst("asn")
    if not asn.isnumeric():
        print_error(f"ASN {asn} is not a number.")
    asn = int(asn)
    if asn <= 0 or asn >= 4_294_967_295:
        print_error(f"ASN {asn} is not in the valid range of ASNs.")
    if asn == 23456 or 64496 <= asn <= 131071 or 4200000000 <= asn <= 4294967295:
        print_error(f"ASN {asn} is a private or otherwise reserved ASN.")

    if "contact" not in form:
        print_error("No contact email was supplied.")
    contact = form.getfirst("contact")
    if not validators.email(contact):
        print_error(f"The email address {contact} is not valid.")

    website = form.getfirst("website") or ""
    if website and not validators.url(website, public=True):
        print_error(f"The url {website} is invalid or suspicious. Stick to public https urls.")

    location = form.getfirst("location")
    if location not in {"fmt", "ams", "nz", "zur", "van", "fra"}:
        print_error(f"The location {location} is not one of fmt, ams, nz, zur, van, or fra.")

    tunnel_type = form.getfirst("type")
    if tunnel_type not in {"openvpn", "zerotier", "eoip", "vxlan", "custom"}:
        print_error(f"The connection type {tunnel_type} is not one of openvpn, zerotier, eoip, vxlan, or custom.")
    if location in {"van", "fra"} and tunnel_type != "custom":
        print_error(f"Only custom connections are allowed at {location}, not {tunnel_type}.")

    needs_ipv4 = bool(form.getfirst("ipv4"))

    comments = form.getfirst("comments") or ""

    cursor.execute("""
        INSERT INTO requests 
               (asn, name, contact, website, tunnel_location, tunnel_type, ipv4)
        VALUES (%s,  %s,   %s,      %s,      %s,              %s,          %s)
        """,   (asn, name, contact, website, location,        tunnel_type, needs_ipv4))

    context = ssl.create_default_context()
    with smtplib.SMTP_SSL(config['mail']['server'], config['mail']['port'], context=context) as server:
        # server.set_debuglevel(2)
        server.login(config['mail']['username'], config['mail']['password'])
        server.sendmail("support@evix.org", ("helpdesk@evix.org", contact), email_template.format(
            name=name,
            asn=asn,
            contact=contact,
            website=website,
            location=location,
            type=tunnel_type,
            ipv4=needs_ipv4,
            comments=comments
        ))


    print(template.render(correct=True, error=None))
