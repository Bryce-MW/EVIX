#!/bin/bash
# NOTE(bryce): Written by Bryce Wilson long ago and added to git on 2020-09-03
#  * 2020-09-19|>Bryce|>Add static tunnel to other servers
#  * 2020-12-01|>Bryce|>Add VXLAN mesh
#  * 2020-12-05|>Bryce|>Add static tunnel to VAN
#  * 2021-02-15|>Bryce|>Fix issue with unneeded routes being added

ip -4 route delete 206.81.104.0/24
ip -4 address add 206.81.104.1/24 dev br10
ip -6 address add 2602:fed2:fff:ffff::1/64 dev br10
ip addr add 2602:fed2:fc0:c8::1/44 dev ens18
ip -6 route add ::/0 via 2602:fed2:fc0::1
ip route add 206.81.104.0/24 dev br10

ip link add EVIX-VAN type vxlan id 11 local 72.52.82.6 remote 104.218.61.207 dstport 5000 learning rsc
ip link set up EVIX-VAN

ip route delete 2602:fed2:fff:ffff::/64 dev ens19
ip route delete 2602:fed2:fff:ffff::/64 dev EVIX-VAN
