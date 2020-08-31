#! /bin/bash

host=`/evix/scripts/hostname.sh`
ip=`/evix/scripts/ts/ip.sh $host`

function single {
  local port=${3:=4789}
  ip link add vtep$1 type vxlan id $1 local $ip remote $2 dstport $port
  ip link set up vtep$1
  ovs-vsctl add-port vmbr0 vtep$1
}

cat peers.vxlan | xargs -L 1 single
