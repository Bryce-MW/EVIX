#!/bin/bash
# NOTE(alex): Written by Alex on 2021-02-28
# Performs some monitoring tasks
#  * 2021-02-28|>Alex|>Initial version

STATE_FILE_DIR="/tmp/evix_monitoring"
WEBHOOK_URL="***REMOVED***"

host=$(/evix/scripts/hostname.sh)
bridge="br10"
source "/evix/config/key-value/$host.conf"

# Let's be careful
alias rm='rm -I'

send_alert () {
  curl -X POST \
    -H "Content-Type: application/json" \
    -d "{\"username\": \"$host\", \"content\": \"$1\"}" \
    $WEBHOOK_URL
}

if [ "$1" = "--test" ]; then
  send_alert "Keep calm - just a test"
  exit 0
fi

# Create directory to store state files in case it doesn't exist
mkdir -p "$STATE_FILE_DIR"

#
# Are all our services running?
#
for service in ${services[@]}; do
  state_file="$STATE_FILE_DIR/$service.not.running"
  systemctl is-active --quiet "$service"
  if [ $? -ne 0 -a ! -f "$state_file" ]; then
    send_alert "Service $service is not running."
    touch "$state_file" 
  elif [ -f "$state_file" ]
    rm "$state_file"
  fi
done

# eoip is not (yet) running as a service
if [ "$is-ts" = "true" ]; then
  state_file="$STATE_FILE_DIR/eoip.not.running"
  eoip_ps=$(pgrep -x eoip)
  if [ "$eoip_ps" == "" -a ! -f "$state_file" ]; then
    send_alert "eoip is not running."
    touch "$state_file" 
  elif [ -f "$state_file" ]
    rm "$state_file"
  fi
fi

#
# Are all required interfaces bridged? (tunnel servers only)
#
if [ "$is-ts" = "true" ]; then
  vxlan-interfaces=$(basename -a /sys/class/net/vtep*)
  backbone-interfaces=$(basename -a /sys/class/net/EVIX*)
  for i in $vxlan-interfaces $backbone-interfaces $eoip-interface $ovpn-interface $zt-interface; do
    state_file="$STATE_FILE_DIR/$i.not.on.bridge"
    if [[ "$(readlink /sys/class/net/$i/brport/bridge)" != *br10 ]] && [ ! -f "$state_file" ]; then
      send_alert "$i is not added to $bridge."
      touch "$state_file" 
    elif [ -f "$state_file" ]
      rm "$state_file"
    fi
  done
fi
