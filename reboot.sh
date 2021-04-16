#! /bin/bash
# NOTE(bryce): Written by Chris, added to git by Bryce on 2020-08-30
#  * 2020-09-03|>Bryce|>Add per-server reboot
#  * 2020-12-01|>Bryce|>Added VXLAN mesh
#  * 2020-12-01|>Bryce|>Use brctl for bridges
#  * 2020-12-09|>Bryce|>Ensure that the logs dir exists
#  * 2021-04-16|>Bryce|>Added JSON config

host=$(/evix/scripts/hostname.sh)
local_ip=$(jq -L/evix/scripts -r --arg host "$host" '.hosts[$host].primary_ipv4' /evix/secret-config.json)
is_ts=$(jq -L/evix/scripts -r --arg host "$host" '.hosts[$host].roles | any(.=="ts")' /evix/secret-config.json)
fmt_ip=$(jq -L/evix/scripts -r '.hosts.fmt.primary_ipv4' /evix/secret-config.json)

# This should probably go away eventually?
if [ -f "/evix/config/reboot/$host.sh" ]; then
  /evix/config/reboot/"$host".sh
fi

jq -L/evix/scripts -r --arg host "$host" '(.hosts[$host].ports // empty)[].commands[]' /evix/secret-config.json |
  ip -b -

if [ "$is_ts" == "true" ]; then

  brctl addbr br10
  brctl stp br10 on

  /evix/scripts/ts/tunnels/vxlan.sh
  /evix/scripts/ts/tunnels/eoip.sh

  jq -L/evix/scripts -r --arg host "nz" '.hosts[$host] | (.ports // empty)[].name, .eoip_interface // empty, .ovpn_interface // empty' /evix/secret-config.json
    xargs -n 1 brctl addif br10

  if [ "$host" != "fmt" ]; then
    ip link add EVIX type vxlan id 10 local "$local_ip" remote "$fmt_ip" dstport 5000 learning rsc
  else
    ip link add EVIX type vxlan id 10 local "$local_ip" dstport 5000 learning rsc
  fi
  ip link set up EVIX
  brctl addif br10 EVIX

  jq -L/evix/scripts -r --compact-output --arg host "$host" '.hosts[] | select((.roles | contains(["ts"])) and .short_name!=$host).primary_ipv4' /evix/secret-config.json |
    xargs -n1 bridge fdb append 00:00:00:00:00:00 dev EVIX dst

  ip link set up br10
fi

jq -L/evix/scripts -r --arg host "$host" '(.hosts[$host].ip_setup // empty)[]' /evix/secret-config.json |
  ip -b -

# brctl
# apt install bridge-utils
# brctl addbr br10
# brctl addif br10 vxlan100
# brctl addif br10 vnet22
# brctl addif br10 vnet25
# brctl stp br10 off
# ip link set up dev br10
# ip link set up dev vxlan10
# bridge fdb append 00:00:00:00:00:00 dev vxlan10 dst 2001:db8:2::1
# bridge fdb append 00:00:00:00:00:00 dev vxlan10 dst 2001:db8:3::1
