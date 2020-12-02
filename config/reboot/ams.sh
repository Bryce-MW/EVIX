ip -4 address add 206.81.104.253/24 dev br10
ip -6 address add 2602:fed2:fff:ffff::253/64 dev br10

#ip link add vtep1234 type vxlan id 1234 local 93.158.213.143 remote 72.52.82.6 dstport 500
#ip link set up vtep1234
