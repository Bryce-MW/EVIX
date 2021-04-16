#!/bin/bash
# NOTE(bryce): Written by Bryce Wilson on 2020-09-14
#  * 2020-12-01|>Bryce|>Remove static VXLAN tunnel and add IPs as needed
#  * 2020-12-02|>Bryce|>Add static tunnel to FRA
#  * 2021-04-16|>Bryce|>IP commands are handled elsewhere

#ip -4 address add 206.81.104.253/24 dev br10
#ip -6 address add 2602:fed2:fff:ffff::253/64 dev br10
#ip link add EVIX-FRA type vxlan id 11 local 93.158.213.143 remote 193.148.249.93 dstport 5000 learning rsc
#ip link set up EVIX-FRA
