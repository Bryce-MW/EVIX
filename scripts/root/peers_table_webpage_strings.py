# NOTE(bryce): This should not be run by itself as it has no effect
#  Written by Bryce Wilson on 2020-11-28 by extracting strings from peers_table_website_generate.sh

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
<tbody><tr></tr>
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
"""

multi_asn_entry = """
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
        </tr></tbody>"""

single_asn_entry = """
    <tr>
        <td></td>
        <td class="peer-table-company"><a href="{website}">{name}</a></td>
        <td class="peer-table-as">{asn}</td>
        <td class="peer-table-ipv4">{ipv4}</td>
        <td class="peer-table-ipv6">{ipv6}</td>
        <td class="peer-table-loc">{server}</td>
        <td class="peer-table-policy"><font color="grey">{type}</font></td>
    </tr>"""

single_asn_footer = '\n\t<tbody class="hide2">'

multi_asn_footer = '\n\t<tbody class="hide2" style="display: none;">'

invisible_asn = """
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
"""
