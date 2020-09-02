#! /bin/bash

host=`/evix/scripts/hostname.sh`
ip=`/evix/scripts/ts/ip.sh $host`
ipv6=`/evix/scripts/get-val.sh $host vxlan-ipv6`
port_d=`/evix/scripts/get-val.sh $host vxlan-port`


function single {
  local port=${3:-$port_d}
  if [[ $2 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    ip link add vtep$1 type vxlan id $1 local $ip remote $2 dstport $port
  else
    ip link add vtep$1 type vxlan id $1 local $ipv6 remote $2 dstport $port
  fi
  ip link set up vtep$1
  ovs-vsctl add-port vmbr0 vtep$1
}

export -f single
export port_d
export ip
export ipv6

cat /evix/config/peers/$host.vxlan | xargs -L 1 bash -c 'single "$@"' single
