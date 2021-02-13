#! /bin/bash

mysql --user evix --password=***REMOVED*** evix <<<"SELECT ip, additional_args FROM connections WHERE type='zerotier';"


# AND EXISTS (SELECT 1 FROM clients INNER JOIN asns ON clients.id=asns.client_id INNER JOIN ips ON ips.asn=asns.asn WHERE provisioned=true AND clients.id=connections.client_id);"
