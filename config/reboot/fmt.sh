ip -4 route delete 206.81.104.0/24
ip -4 route add 206.81.104.0/24 dev vmbr0 src 206.81.104.1 pref high
ip addr add 2602:fed2:fc0:c8::1/44 dev ens18
ip -6 route add ::/0 via 2602:fed2:fc0::1
