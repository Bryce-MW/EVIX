ip -4 route delete 206.81.104.0/24
ip -4 route add 206.81.104.0/24 dev br10 src 206.81.104.1 pref high
ip addr add 2602:fed2:fc0:c8::1/44 dev ens18
ip -6 route add ::/0 via 2602:fed2:fc0::1

#ip link add vtep123 vxlan id 123 remote 104.218.61.207 local 72.52.82.6
#ip link add vtep1234 vxlan id 1234 remote 93.158.213.143 local 72.52.82.6 srcport 0 0 dstport 500 ageing 300
#ip link set vtep123 up
#ip link set vtep1234 up
#ovs-vsctl add-port vmbr0 vtep123
#ovs-vsctl add-port vmbr0 vtep1234
