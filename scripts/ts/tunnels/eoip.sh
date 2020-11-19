#! /bin/bash

host=`/evix/scripts/hostname.sh`
ip=`/evix/scripts/ip.sh $host`
ipv6=`/evix/scripts/get-val.sh $host vxlan-ipv6`

# eoip [ OPTIONS ] IFNAME { remote RADDR } { local LADDR } { id TID } fork

function single {
  echo $1 $2
  if [[ $2 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    /evix/run/eoip-single/eoip -4 eoip$1 remote $2 local $ip id $1 fork
  else
    /evix/run/eoip-single/eoip -6 eoip$1 remote $2 local $ipv6 id $1 fork
  fi
  ovs-vsctl add-port vmbr0 eoip$1
}

export -f single
export ip
export ipv6

cat /evix/config/peers/$host.eoip | sed 's/[[:space:]]*$//' | xargs -L 1 bash -c 'single "$@"' single
