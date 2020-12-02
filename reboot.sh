#! /bin/bash

host=$(/evix/scripts/hostname.sh)

git -C /evix submodule update --init --recursive

if [ "$(/evix/scripts/get-val.sh "$host" is-ts)" == "true" ]; then

  /evix/scripts/ts/tunnels/vxlan.sh
  /evix/scripts/ts/eoip-new.sh

  xargs -n 1 ovs-vsctl add-port vmbr0 </evix/config/ports/"$host".ports

  ip link set up vmbr0

  if [ "$host" != "fmt" ]; then
    ip link add EVIX-FMT type vxlan id 10 local any remote 72.52.82.6 dstport 5000 learning rsc
    ip link set up EVIX-FMT
    ovs-vsctl add-port vmbr0 EVIX-FMT
  else
    hosts=("/evix/config/hosts"/*)
    for hoststring in "${hosts[@]}"; do
      exec 6<"$hoststring"
      read -r name <&6
      read -r hostname <&6
      read -r port <&6

      if [ "$(/evix/scripts/get-val.sh "$host" is-ts)" ] && [ "$hostname" != "fmt" ]; then
        ip=$(dig "$hostname" +short)
        ip link add EVIX-"$hostname" type vxlan id 10 local any remote "$ip" dstport 5000 learning rsc
      fi
    done
  fi
fi

if [ -f "/evix/config/reboot/$host.sh" ]; then
  /evix/config/reboot/"$host".sh
fi
