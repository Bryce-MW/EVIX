#! /bin/bash

host=$(/evix/scripts/hostname.sh)
local_ip=$(/evix/scripts/ip.sh "$host")

git -C /evix submodule update --init --recursive

if [ -f "/evix/config/reboot/$host.sh" ]; then
  /evix/config/reboot/"$host".sh
fi

if [ "$(/evix/scripts/get-val.sh "$host" is-ts)" == "true" ]; then

  brctl addbr br10
  brctl stp br10 on

  /evix/scripts/ts/tunnels/vxlan.sh
  /evix/scripts/ts/eoip-new.sh

  xargs -n 1 brctl addif br10 </evix/config/ports/"$host".ports

  if [ "$host" != "fmt" ]; then
    ip link add EVIX type vxlan id 10 local "$local_ip" remote 72.52.82.6 dstport 5000 learning rsc
  else
    ip link add EVIX type vxlan id 10 local "$local_ip" dstport 5000 learning rsc
  fi
  ip link set up EVIX
  brctl addif br10 EVIX

  hosts=("/evix/config/hosts"/*)
  for hoststring in "${hosts[@]}"; do
    host_short=$(basename "$hoststring")
    exec 6<"$hoststring"
    read -r name <&6
    read -r hostname <&6
    read -r port <&6

    if [ "$(/evix/scripts/get-val.sh "$host" is-ts)" ] && [ "$host_short" != "$host" ]; then
      if [[ "$hostname" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        ip="$hostname"
      else
        ip=$(dig "$hostname" +short)
      fi
      bridge fdb append 00:00:00:00:00:00 dev EVIX dst "$ip"
    fi
  done

  ip link set up br10
fi

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
