#! /bin/bash

# TODO(bryce): This is deprecated and should be removed shortly. It was for the daemon that did not work. I am keeping
#  it  as it may be helpful for when we use the better system.

host=$(/evix/scripts/hostname.sh)
ip=$(/evix/scripts/ip.sh "$host")
ipv6=$(/evix/scripts/get-val.sh "$host" vxlan-ipv6)

# eoip [ OPTIONS ] IFNAME { remote RADDR } { local LADDR } { id TID } fork

function single() {
  echo "$1" "$2"
  if [[ $2 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    /evix/run/eoip-single/eoip -4 eoip"$1" remote "$2" local "$ip" id "$1" fork
  else
    /evix/run/eoip-single/eoip -6 eoip"$1" remote "$2" local "$ipv6" id "$1" fork
  fi
  ovs-vsctl add-port vmbr0 eoip"$1"
}

export -f single
export ip
export ipv6

sed 's/[[:space:]]*$//' /evix/config/peers/"$host".eoip | xargs -L 1 bash -c 'single "$@"' single
