#!/bin/bash
# Script to start all required tunnels on the monitoring server
# NOTE(alex): Written by Alex 2021-03-14
#  * 2021-03-14|>Alex|>Initial version

# Settings
locations=(fmt ams nz zur) # needs to be specified, otherwise the tunnels might be created in random order
declare -A loc_ids=([fmt]=1 [ams]=2 [nz]=3 [zur]=4)
declare -A tserv_ips=([fmt]=72.52.82.6 [ams]=93.158.213.143 [nz]=163.47.131.155 [zur]=193.148.250.34)
declare -A vxlan_ids=([fmt]=118 [ams]=130 [nz]=103 [zur]=104)
declare -A vxlan_ports=([fmt]=4789 [ams]=500 [nz]=4789 [zur]=500)
declare -A eoip_ids=([fmt]=111 [ams]=123 [nz]=304 [zur]=505)
eoip_tool="/opt/eoip/eoip"

# Zerotier is already configured and just needs to be started
echo Starting Zerotier...
systemctl restart zerotier-one
sleep 5
ip addr add 2602:fed2:fff:ffff:10::1:4/64 dev ***REMOVED***

#
# Start other tunnels...
#
# we use 2602:fed2:fff:ffff:10::/96 for monitoring
# ex. 2602:fed2:fff:ffff:10::$loc:$type
local_ip=$(/sbin/ip -f inet addr show eth0 | sed -En -e 's/.*inet ([0-9.]+).*/\1/p')
loc_id=1
for loc in ${locations[*]}; do
  # OpenVPN
  tun_type=1
  echo Starting OpenVPN for ${loc}...
  systemctl restart "openvpn@${loc}.service"
  sleep 10
  ip link set ovpn-${loc} up
  ip addr add 2602:fed2:fff:ffff:10::${loc_id}:${tun_type}/64 dev ovpn-${loc}

  # EoIP
  ((tun_type++))
  echo Starting EoIP for ${loc}...
  $eoip_tool add name "eoip-${loc}" local "${local_ip}" remote "${tserv_ips[$loc]}" tunnel-id "${eoip_ids[$loc]}"
  sleep 5
  ip link set eoip-${loc} up
  ip addr add 2602:fed2:fff:ffff:10::${loc_id}:${tun_type}/64 dev eoip-${loc}

  # VXLAN
  ((tun_type++))
  echo Starting VXLAN for ${loc}...
  ip link add "vxlan-${loc}" type vxlan id "${vxlan_ids[$loc]}" local "${local_ip}" remote "${tserv_ips[$loc]}" dstport "${vxlan_ports[$loc]}" dev eth0
  ip link set "vxlan-${loc}" up
  ip addr add 2602:fed2:fff:ffff:10::${loc_id}:${tun_type}/64 dev "vxlan-${loc}"

  ((loc_id++))
done