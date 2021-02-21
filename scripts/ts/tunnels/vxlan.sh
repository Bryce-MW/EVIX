#! /bin/bash
# NOTE(bryce): Written by Bryce Wilson a while ago and added to git on 2020-08-30
#  * 2020-09-01|>Bryce|>Allow different ports
#  * 2020-10-07|>Bryce|>Fixed some issues with spacing and added print
#  * 2020-11-28|>Bryce|>Fixed some bash errors
#  * 2020-12-01|>Bryce|>Switched to brctl
#  * 2021-02-18|>Bryce|>Almost complete re-write to use json to add and removed exactly the required tunnels

host=$(/evix/scripts/hostname.sh)
ip=$(/evix/scripts/ip.sh "$host")
ipv6=$(/evix/scripts/get-val.sh "$host" vxlan-ipv6)
port_d=$(/evix/scripts/get-val.sh "$host" vxlan-port)

{
  /sbin/ip -json -d link show | jq 'map(if .linkinfo.info_kind == "vxlan" and (.ifname | startswith("vtep")) then . else empty end) | map({id: .linkinfo.info_data.id, ip: (.linkinfo.info_data.remote // .linkinfo.info_data.remote6), port: .linkinfo.info_data.port})'
  jq --slurp --raw-input --argjson port "$port_d" 'split("\n") | .[:-1] | map(split(" ")) | map({id: .[0] | tonumber, ip: .[1], port: (if .[2] == "" or .[2] == null then $port else .[2] | tonumber end)})' "/evix/config/peers/$host.vxlan"
} |
  jq --slurp --raw-output --arg ip "$ip" --arg ipv6 "$ipv6" '{existing: .[0], new: .[1]} | {delete: (.existing - .new), add: (.new - .existing)} | (.delete[] | "link delete vtep\(.id)"), (.add[] | "link add vtep\(.id) type vxlan id \(.id) local \(if .ip | test("[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+") then $ip else $ipv6 end) remote \(.ip) dstport \(.port)\nlink set up vtep\(.id)")' |
  ip -b -
