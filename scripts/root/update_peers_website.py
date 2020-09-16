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

table = ""
header = """<table class="sortable" border="0" cellpadding="5" cellspacing=10" width="100%">
    <thead><tr class="peers">
        <th algin=left></th>
        <th align=left>User</th>
        <th align=left>AS</th>
        <th align=left class="wide">IPv4 /24</th>
        <th align=left class="wide">IPv6 /64</th>
        <th align=left>Location</th>
        <th align=left>Tunnel Type</th>
     </tr></thead>
<tbody><tr></tr>"""

clients_cursor = database.cursor(dictionary=True, buffered=True)
asns_cursor = database.cursor(dictionary=True, buffered=True)
ips_cursor = database.cursor(dictionary=True, buffered=True)
connections_cursor = database.cursor(dictionary=True, buffered=True)

clients_cursor.execute("SELECT id,name,website,contact FROM clients")

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
        connections = ({'type': '-----', 'server': '-----'},)

    first = True
    multiple = asns_cursor.rowcount > 1
    multiple_asns = multiple
    for asn in asns_cursor:
        ips_cursor.reset()
        ips_cursor.execute(
            "SELECT ip,version,provisioned FROM ips WHERE asn = %s ORDER BY (ip not like '%:%') DESC, INET6_ATON(ip)",
            (asn['asn'],))

        ips = tuple(i for i in ips_cursor if i['provisioned'])
        ipv4 = tuple(i for i in ips if i['version'] == 4)
        ipv6 = tuple(i for i in ips if i['version'] == 6)

        connection = connections[connections_counter]
        if connections_counter < len(connections) - 1:
            connections_counter += 1
        server = connection['server']
        type = connection['type']
        website = client['website'] if client['website'] else "javascript:alert('User has not set a website.')"

        multiple_ips = max(len(ipv4), len(ipv6)) > 1
        multiple = multiple or multiple_ips

        first_ip = True
        for i in range(max(len(ipv4), len(ipv6))):
            ipv4_str = ipv4[i]['ip'] if i < len(ipv4) else "-----"
            ipv6_str = ipv6[i]['ip'] if i < len(ipv6) else "-----"

            name = client['name'] if first else ""
            asn = asn['asn'] if first_ip else ""

            if multiple and first:
                table += """
    <tbody class="labels"><tr>
        <td>
            <label for="{name}">▶ </label>
            <input type="checkbox" name="{name}" id="{name}" data-toggle="toggle" style="display: none;"></td>
                <td class="peer-table-company"><a href="{website}">{name}</a></td>
                <td class="peer-table-as">{asn}</td>
                <td class="peer-table-ipv4">{ipv4}</td>
                <td class="peer-table-ipv6">{ipv6}</td>
                <td class="peer-table-loc">{server}</td>
                <td class="peer-table-policy"><font color="grey">{type}</font></td>
        </tr></tbody>""".format(website=website, name=name, asn=asn,
                                ipv4=ipv4_str, ipv6=ipv6_str, server=server, type=type)
            else:
                if i == 0 and not multiple_asns:
                    table += '\n\t<tbody class="hide2">'
                elif i == 1 or multiple_asns:
                    table += '\n\t<tbody class="hide2" style="display: none;">'
                table += """
    <tr>
        <td></td>
        <td class="peer-table-company"><a href="{website}">{name}</a></td>
        <td class="peer-table-as">{asn}</td>
        <td class="peer-table-ipv4">{ipv4}</td>
        <td class="peer-table-ipv6">{ipv6}</td>
        <td class="peer-table-loc">{server}</td>
        <td class="peer-table-policy"><font color="grey">{type}</font></td>
    </tr>""".format(website=website, name=name, asn=asn,
                    ipv4=ipv4_str, ipv6=ipv6_str, server=server, type=type)
                if i == multiple:
                    table += '</tbody>'
            first_ip = False
            first = False

print(header)
print("""
    <tbody class="hide2">
    <tr>
            <td></td>
            <td class="peer-table-company"><a href="None">EVIX Primary Route Server</a></td>
            <td class="peer-table-as">137933</td>
            <td class="peer-table-ipv4">206.81.104.1</td>
            <td class="peer-table-ipv6">2602:fed2:fff:ffff::1</td>
            <td class="peer-table-loc">-----</td>
            <td class="peer-table-policy"><font color="grey">-----</font></td>
    </tr></tbody>

    <tbody class="hide2">
    <tr>
            <td></td>
            <td class="peer-table-company"><a href="None">EVIX Backup Route Server</a></td>
            <td class="peer-table-as">209762</td>
            <td class="peer-table-ipv4">206.81.104.253</td>
            <td class="peer-table-ipv6">2602:fed2:fff:ffff::253</td>
            <td class="peer-table-loc">-----</td>
            <td class="peer-table-policy"><font color="grey">-----</font></td>
    </tr></tbody>

    <tbody class="hide2">
    <tr>
            <td></td>
            <td class="peer-table-company">-----</td>
            <td class="peer-table-as">-----</td>
            <td class="peer-table-ipv4">-----</td>
            <td class="peer-table-ipv6">-----</td>
            <td class="peer-table-loc">-----</td>
            <td class="peer-table-policy"><font color="grey">-----</font></td>
    </tr></tbody>
""")
print(table)
print("""
    <tbody class="hide2">
    <tr>
            <td></td>
            <td class="peer-table-company"><a href="None"></a></td>
            <td class="peer-table-as"></td>
            <td class="peer-table-ipv4"></td>
            <td class="peer-table-ipv6"></td>
            <td class="peer-table-loc"></td>
            <td class="peer-table-policy"><font color="grey"></font></td>
    </tr></tbody>
""" * 5)

database.close()
