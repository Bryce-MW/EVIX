#! /bin/bash

host=`/evix/scripts/hostname.sh`

if [ "`/evix/scripts/get-value $host is-ts`" == "true" ]; then

  /evix/scripts/ts/vxlan.sh
  /evix/scripts/ts/eoip.sh

  xargs -n 1 ovs-vsctl add-port vmbr0 < /evix/config/ports/$host.ports

done
