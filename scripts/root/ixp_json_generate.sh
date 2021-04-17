#!/bin/bash
# NOTE(bryce): Originally written by Chris, added to git by Bryce Wilson on 2020-09-13.
#  * 2020-11-28|>Bryce|>Cleaned up a bit
#  * 2020-11-29|>Bryce|>Added printing of result for debugging
#  * 2021-02-19|>Bryce|>Move to JQ based system
#  * 2021-04-16|>Bryce|>Added JSON config

user=$(jq -r '.database.user' /evix/secret-config.json)
password=$(jq -r '.database.password' /evix/secret-config.json)
database=$(jq -r '.database.database' /evix/secret-config.json)

mysql --user "$user" --password="$password" --reconnect "$database" --batch -N 2>/dev/null <<<"SELECT json_arrayagg(json_object('id', id, 'name', name, 'website', website, 'contact', contact, 'tunnels', (SELECT json_arrayagg(json_object('id', id, 'type', type, 'server', server, 'tunnel_id', tunnel_id, 'ip', ip, 'additional_args', additional_args)) FROM connections WHERE client_id=clients.id), 'asns', (SELECT json_arrayagg(json_object('asn', asn, 'ips', (SELECT json_arrayagg(json_object('ip', ip, 'version', version, 'monitor', monitor, 'provisioned', provisioned, 'pingable', pingable, 'rs_session', birdable)) FROM ips WHERE ips.asn=asns.asn))) FROM asns WHERE client_id=clients.id))) FROM clients;" |
jq --compact-output 'ixp_json_format' |
tee /var/www/evix/participants.json | jq -C '.'
