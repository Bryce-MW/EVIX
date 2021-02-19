#! /bin/bash

host=$(/evix/scripts/hostname.sh)
ip=$(/evix/scripts/ip.sh "$host")
interface=$(/evix/scripts/get-val.sh "$host" eoip-interface)

eoip_ps=$(pgrep -x eoip)

if [ "$eoip_ps" == "" ]; then
  mkdir -p /evix/logs
  jq --raw-input --raw-output 'split(" ") | "\(.[1]):\(.[0])"' "/evix/config/peers/$host.eoip" |
  xargs -0 -d "\n" screen -dmS eoip /evix/run/eoip/eoip -s /evix/logs/eoip.log "$interface" "$ip"

  sleep 2
  ip link set "$interface" up
  brctl addif br10 "$interface"
  exit 0
fi

length=$({
  jq --raw-input 'split("\u0000") | .[5:] | reduce .[] as $item ([]; if (.[-1] | length) == 1 then .[:-1] + [[.[-1][0], $item]] else . + [[$item]] end) | map({id: .[1], ip: .[0]})' "/proc/$eoip_ps/cmdline"
  jq --slurp --raw-input 'split("\n") | map(select(length > 0)) | map(split(" ")) | map({id: .[0], ip: .[1]})' "/evix/config/peers/$host.eoip"
} |
jq --slurp '{existing: .[0], new: .[1]} | (.existing - .new) + (.new - .existing) | length')

if (( length > 0 )); then
  screen -S eoip -X stuff ^C

  jq --raw-input --raw-output 'split(" ") | "\(.[1]):\(.[0])"' "/evix/config/peers/$host.eoip" |
  xargs -0 -d "\n" screen -dmS eoip /evix/run/eoip/eoip -s /evix/logs/eoip.log "$interface" "$ip"
fi

# screen -S eoip -X stuff ^C
# awk '{ print $2 ":" $1}' < /evix/config/peers/fmt.eoip | xargs
# screen -dmS eoip /evix/run/eoip/eoip tun101 72.52.82.6 185.158.255.2:101 192.30.89.140:102 45.77.27.154:104 209.197.181.234:105 103.24.179.172:107 220.132.81.245:109 128.14.155.222:110 44.135.193.138:111 213.238.183.1:112 155.138.217.166:113 190.210.230.107:114 123.253.141.19:119 45.77.6.77:120 171.60.145.30:121 185.225.207.1:123 64.62.151.115:124 198.204.254.131:125 103.139.190.1:127 45.85.195.67:128 110.44.168.130:129 200.73.54.202:103 5.196.146.57:106
