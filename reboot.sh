#! /bin/bash

host=`/evix/scripts/hostname.sh`

git -C /evix submodule update --init --recursive

if [ "`/evix/scripts/get-val.sh $host is-ts`" == "true" ]; then

  /evix/scripts/ts/vxlan.sh
  /evix/scripts/ts/eoip.sh

  xargs -n 1 ovs-vsctl add-port vmbr0 < /evix/config/ports/$host.ports

  ip link set up vmbr0

fi

if [ -f "/evix/config/reboot/$hostname.sh" ]; then
  /evix/config/reboot/$hostname.sh
fi