# NOTE(alex): Copied from peers_table_webpage_generate.py on 2021-03-14
# Generate Smokeping config to ping peers
#  * 2021-03-14|>Alex|>Initial version

import ipaddress
import mysql.connector

database = None
try:
    database = mysql.connector.connect(user='evix', password='***REMOVED***', host='127.0.0.1',
                                       database='evix')
except mysql.connector.Error as err:
    print("Something went wrong with the database connection:")
    print(err)
    exit(1)

sp_conf = """# This file was automatically generated by %s
# Local changes may be overwritten without notice or backups being taken.

+ Peers
  menu = Peers
  title = Peers
  nomasterpoll = yes
  slaves = evix-fmt-ts01.evix.org evix-nl-ts01
    
""" % __file__

clients_cursor = database.cursor(dictionary=True, buffered=True)
asns_cursor = database.cursor(dictionary=True, buffered=True)
ips_cursor = database.cursor(dictionary=True, buffered=True)
connections_cursor = database.cursor(dictionary=True, buffered=True)

clients_cursor.execute("SELECT id,name FROM clients")

clients = tuple((i, tuple((ipaddress.ip_address(j['ip']).version, ipaddress.ip_address(j['ip']).packed) for j in next(
    ips_cursor.execute("SELECT ip FROM ips \
                       INNER JOIN asns ON ips.asn=asns.asn \
                       WHERE provisioned=true AND client_id=%s \
                       ORDER BY (ip not like '%:%') DESC, INET6_ATON(ip)",
                       (i['id'],), multi=True)))) for i in clients_cursor)

for client, _ in sorted(clients, key=lambda x: x[1]):
    asns_cursor.reset()
    connections_cursor.reset()
    asns_cursor.execute(
        "SELECT asn FROM asns \
        WHERE client_id = %s AND \
        EXISTS (SELECT 1 FROM ips WHERE asns.asn=ips.asn AND provisioned=1)",
        (client['id'],))
    connections_cursor.execute("SELECT type,server FROM connections WHERE client_id = %s", (client['id'],))
    connections = tuple(connections_cursor)
    connections_counter = 0
    if len(connections) == 0:
        connections = ({'type': 'n/a', 'server': 'n/a'},)

    for asn in asns_cursor:
        ips_cursor.reset()
        ips_cursor.execute(
            "SELECT ip,version,provisioned FROM ips WHERE asn = %s ORDER BY (ip not like '%:%') DESC, INET6_ATON(ip)",
            (asn['asn'],))
        ips = tuple(i for i in ips_cursor if i['provisioned'])

        if len(ips) > 0:
            sp_conf += """++ AS{asn}
   menu = AS{asn} ({name})
   title = AS{asn} - {name}

""".format(asn=asn['asn'], name = client['name'])

            for ip in ips:
                ip_stripped = ip['ip'].translate({ord(i): None for i in ':.'})
                probe = "FPing" if ip['version'] == 4 else "FPing6"
                sp_conf += """+++ {asn}_{ipstr}
    title = AS{asn} - {ip}
    probe = {probe}
    host = {ip}
    
""".format(asn=asn['asn'], ipstr=ip_stripped, ip=ip['ip'], probe=probe)

database.close()

print(sp_conf)
