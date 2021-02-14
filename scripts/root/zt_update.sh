#! /bin/bash

token="***REMOVED***"
root_ip="23.129.32.56"
network="***REMOVED***"

mysql --user evix --password=***REMOVED*** --reconnect -B -N evix 2>/dev/null <<<"SELECT ip, additional_args FROM connections WHERE type='zerotier';"

curl -X GET --header "X-ZT1-Auth: $token" "http://$root_ip:9993/controller/network/$network/member" 2>/dev/null #|
#jq 'keys' |
#head -n -1 |
#tail -n +2 |
#cut -d ',' -f1 |
#tr -d ' '

# AND EXISTS (SELECT 1 FROM clients INNER JOIN asns ON clients.id=asns.client_id INNER JOIN ips ON ips.asn=asns.asn WHERE provisioned=true AND clients.id=connections.client_id);"
