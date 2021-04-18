#! /bin/bash
# NOTE(bryce): Written by Bryce Wilson a long time ago and fixed on 2021-02-18
#  * 2021-04-16|>Bryce|>Added JSON config

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
  sleep 2
  brctl addif br10 "$interface"
  exit 0
fi

length=$({
  jq --raw-input 'parse_eoip_cmdline' "/proc/$eoip_ps/cmdline"
  jq --slurp --raw-input 'parse_eoip_config' "/evix/config/peers/$host.eoip"
} |
  jq --slurp '{existing: .[0], new: .[1]} | (.existing - .new) + (.new - .existing) | length')

if ((length > 0)); then
  screen -S eoip -X stuff ^C

  jq --raw-input --raw-output 'split(" ") | "\(.[1]):\(.[0])"' "/evix/config/peers/$host.eoip" |
    xargs -0 -d "\n" screen -dmS eoip /evix/run/eoip/eoip -s /evix/logs/eoip.log "$interface" "$ip"

  sleep 2
  ip link set "$interface" up
  sleep 2
  brctl addif br10 "$interface"
  exit 0
fi

# screen -S eoip -X stuff ^C
# awk '{ print $2 ":" $1}' < /evix/config/peers/fmt.eoip | xargs
# screen -dmS eoip /evix/run/eoip/eoip tun101 72.52.82.6 1.1.1.1:101 2.2.2.2:102 3.3.3.3:104 4.4.4.4:105 5.5.5.5:107 6.6.6.6:109 7.7.7.7:110 8.8.8.8:111 9.9.9.9:112 10.10.10.10:113 11.11.11.11:114 12.12.12.12:119 13.13.13.13:120 14.14.14.14:121
