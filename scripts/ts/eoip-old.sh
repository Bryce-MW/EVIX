#! /bin/bash

host=$(/evix/scripts/hostname.sh)
ip=$(/evix/scripts/ip.sh "$host")
interface=$(/evix/scripts/get-val.sh "$host" eoip-interface)

screen -S eoip -X stuff ^C
awk '{ print $2 ":" $1 }' </evix/config/peers/"$host".eoip | xargs screen -dmS eoip /evix/run/eoip/eoip "$interface" "$ip"
sleep 5
ip link set up "$interface"
