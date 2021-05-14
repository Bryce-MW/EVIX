reduce
  .[]
as $item
  ([];
  if
    (. | map(select(.asn == $item.asn)) | length > 0)
  then
    map(if .asn == $item.asn then .additional_ips += [$item | {ip, version}] else . end)
  else . + [$item + {additional_ips:[]}]
  end)
| reduce
  .[]
as $item
  ([];
  if
    (. | map(select(.client_id == $item.client_id)) | length > 0)
  then
    map(if .client_id == $item.client_id then .additional_asns += [$item | {ip, asn, additional_ips}] else . end)
  else
    . + [$item + {additional_asns:[]}]
  end)
| .[]
