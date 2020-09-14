#! /bin/bash

#bird_servers=(fmt ams)
bird_servers=fmt

hosts=("/evix/config/hosts"/$bird_servers)

for host in $hosts; do
  exec 6< "$host"
  read -r name <&6
  read -r hostname <&6
  read -r port <&6
  ssh -p $port $hostname birdc show protocols all | egrep -e 'BGP.*?master' -e "Neighbor address" -e "Neighbor AS" | paste -d " " - - - | egrep -o -w "(up|start|down|[0-9]{0,3}\.[0-9]{0,3}\.[0-9]{0,3}\.[0-9]{0,3}|[0-9]+\'|[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2})" | paste -d " " - - - - | python3 /evix/scripts/root/peers-status.py 4 "$name"
  ssh -p $port $hostname birdc6 show protocols all | egrep -e 'BGP.*?master' -e "Neighbor address" -e "Neighbor AS" | paste -d " " - - - | egrep -o -w "(up|start|down|([a-f0-9:]+:+)+[a-f0-9]+|[0-9]+\'|[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2})" | paste -d " " - - - - | python3 /evix/scripts/root/peers-status.py 6 "$name"
done
