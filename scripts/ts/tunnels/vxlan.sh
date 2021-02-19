#! /bin/bash

host=$(/evix/scripts/hostname.sh)
ip=$(/evix/scripts/ip.sh "$host")
ipv6=$(/evix/scripts/get-val.sh "$host" vxlan-ipv6)
port_d=$(/evix/scripts/get-val.sh "$host" vxlan-port)


{
  /sbin/ip -json -d link show | jq 'map(if .linkinfo.info_kind == "vxlan" and (.ifname | startswith("vtep")) then . else empty end) | map({id: .linkinfo.info_data.id, ip: (.linkinfo.info_data.remote // .linkinfo.info_data.remote6), port: .linkinfo.info_data.port})'
  jq --slurp --raw-input --argjson port "$port_d" 'split("\n") | .[:-1] | map(split(" ")) | map({id: .[0] | tonumber, ip: .[1], port: (if .[2] == "" or .[2] == null then $port else .[2] | tonumber end)})' "/evix/config/peers/$host.vxlan"
} |
jq --slurp --raw-output --arg ip "$ip" --arg ipv6 "$ipv6" '{existing: .[0], new: .[1]} | {delete: (.existing - .new), add: (.new - .existing)} | (.delete[] | "link delete vtep\(.id)"), (.add[] | "link add vtep\(.id) type vxlan id \(.id) local \(if .ip | test("[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+") then $ip else $ipv6 end) remote \(.ip) dstport \(.port)")' |
ip -b -
