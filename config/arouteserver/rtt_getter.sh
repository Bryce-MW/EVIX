#!/bin/bash

# This is just an example!
#
# This script sends 3 ping to the peer and returns the avg value.

peer_ip="$1"

if [ -z "$peer_ip" ]; then
  echo None
  exit
fi

if [[ "$peer_ip" =~ ":" ]]; then
  ping_ping6="ping6"
else
  ping_ping6="ping"
fi

data="$($ping_ping6 -c 3 -i 0.2 -n -q -W 2 "$peer_ip" 2>&1)"

if echo "$data" | grep "0 received" &>/dev/null; then
  # no replies from peer
  echo None
  exit
fi

avg=$(echo "$data" | grep "rtt min/avg/max/mdev" | grep -E -o " [0-9\.\/]+ ms" | cut -d '/' -f 2)
echo "$avg"
