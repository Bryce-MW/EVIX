#! /usr/bin/env python3
import os

import json
import jq
import mysql.connector
from jinja2 import Environment, PackageLoader, select_autoescape

if "REQUEST_METHOD" in os.environ and __name__ == "__main__":
    # This is running in cgi mode
    import cgitb
    import sys
    sys.stderr = sys.stdout
    cgitb.enable()
    print("Content-type: text/html\n")


if __name__ == "__main__":
    env = Environment(
        loader=PackageLoader("peering_form", ""),
        autoescape=select_autoescape,
        trim_blocks=True,
        lstrip_blocks=True
    )

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
    cursor.execute("""
        SELECT 
            json_object(
                'ip', ip,
                'version', version,
                'asn', asns.asn,
                'client_id', client_id,
                'client', json_object(
                    'name', name,
                    'website', website,
                    'connections', (SELECT json_arrayagg(json_object(
                        'type', type,
                        'location', server)) FROM connections WHERE connections.client_id=clients.id)))
        FROM
            ips INNER JOIN
            asns on asns.asn=ips.asn
            INNER JOIN clients ON client_id=id
        WHERE
            provisioned
        ORDER BY
            IS_IPV6(ip),
            INET6_ATON(ip)
    """)
    with open('/evix/run/website/peers.jq', 'r') as jq_script:
        peers = jq.compile(jq_script.read()).input(text="[" + ",".join(i[0] for i in cursor.fetchall()) + "]")

    template = env.get_template("peers.jinja.html")
    print(template.render(peers=peers))
