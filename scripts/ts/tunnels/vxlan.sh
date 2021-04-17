#! /bin/bash
# NOTE(bryce): Written by Bryce Wilson a while ago and added to git on 2020-08-30
#  * 2020-09-01|>Bryce|>Allow different ports
#  * 2020-10-07|>Bryce|>Fixed some issues with spacing and added print
#  * 2020-11-28|>Bryce|>Fixed some bash errors
#  * 2020-12-01|>Bryce|>Switched to brctl
#  * 2021-02-18|>Bryce|>Almost complete re-write to use json to add and removed exactly the required tunnels
#  * 2021-04-16|>Bryce|>Added JSON config

host=$(/evix/scripts/hostname.sh)
ip=$(jq --arg host "$host" -r '.hosts[$host].primary_ipv4' /evix/secret-config.json)
ipv6=$(jq --arg host "$host" -r '.hosts[$host].primary_ipv6' /evix/secret-config.json)
port_d=$(jq --arg host "$host" -r '.hosts[$host].vxlan_port' /evix/secret-config.json)
bridge="br10"

{
  /sbin/ip -json -d link show | jq 'parse_ip_vxlan'
  jq --slurp --raw-input --argjson port "$port_d" 'parse_config_vxlan($port)' "/evix/config/peers/$host.vxlan"
} |
  jq --slurp --raw-output --arg ip "$ip" --arg ipv6 "$ipv6" --arg bridge "$bridge" 'diff_vxlan($ip; $ipv6; $bridge)' |
  ip -b -
