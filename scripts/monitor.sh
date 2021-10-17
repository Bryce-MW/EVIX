#!/bin/bash
# NOTE(alex): Written by Alex on 2021-02-28
# * Performs some monitoring tasks
#  * 2021-02-28|>Alex|>Initial version
#  * 2021-04-16|>Bryce|>Added JSON config

STATE_FILE_DIR="/tmp/evix_monitoring"
WEBHOOK_URL=$(jq -r '.monitoring.webhook_url' /evix/secret-config.json)

host=$(/evix/scripts/hostname.sh)
bridge="br10"

is_ts=$(jq -r --arg host "$host" '.hosts[$host].roles | any(.=="ts")' /evix/secret-config.json)
is_rs=$(jq -r --arg host "$host" '.hosts[$host].roles | any(.=="rs")' /evix/secret-config.json)
is_admin=$(jq -r --arg host "$host" '.hosts[$host].roles | any(.=="admin")' /evix/secret-config.json)

# Let's be careful
alias rm='rm -I'

send_alert() {
  curl -X POST \
    -H "Content-Type: application/json" \
    -d "{\"username\": \"$host\", \"content\": \"$1\"}" \
    "$WEBHOOK_URL"
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
services=$(jq -r --arg host "$host" '.hosts[$host].services | join(" ")' /evix/secret-config.json)
for service in $services; do
  state_file="$STATE_FILE_DIR/$service.not.running"
  if ! systemctl is-active --quiet "$service"; then
    if [ ! -f "$state_file" ]; then
      send_alert ":exclamation: Service $service is not running."
      touch "$state_file"
    fi
  elif [ -f "$state_file" ]; then
    send_alert ":white_check_mark: Service $service is running again."
    rm "$state_file"
  fi
done

# eoip is not (yet) running as a service
if [ "$is_ts" = "true" ]; then
  state_file="$STATE_FILE_DIR/eoip.not.running"
  eoip_ps=$(pgrep -x eoip)
  if [ "$eoip_ps" == "" ]; then
    if [ ! -f "$state_file" ]; then
      send_alert ":exclamation: eoip is not running."
      touch "$state_file"
    fi
  elif [ -f "$state_file" ]; then
    send_alert ":white_check_mark: eoip running again."
    rm "$state_file"
  fi
fi

#
# Are all required interfaces bridged? (tunnel servers only)
#
if [ "$is_ts" = "true" ]; then
  vxlan_interfaces=$(basename -a /sys/class/net/vtep*)
  backbone_interfaces=$(basename -a /sys/class/net/EVIX*)
  eoip_interface=$(jq --arg host "$host" -r '.hosts[$host].eoip_interface' /evix/secret-config.json)
  ovpn_interface=$(jq --arg host "$host" -r '.hosts[$host].ovpn_interface' /evix/secret-config.json)
  is_zt=$(jq -r --arg host "$host" '.hosts[$host].roles | any(.=="zt-endpoint")' /evix/secret-config.json)
  if [ "$is_zt" = "true" ]; then
    zt_interface=$(jq -r '.zt.network_interface' /evix/secret-config.json)
  fi
  for i in $vxlan_interfaces $backbone_interfaces $eoip_interface $ovpn_interface $zt_interface; do
    state_file="$STATE_FILE_DIR/$i.not.on.bridge"
    if [[ "$(readlink /sys/class/net/$i/brport/bridge)" != *br10 ]]; then
      /sbin/brctl addif "$bridge" "$i"
      if [ $? -eq 0 ]; then
        send_alert ":yellow_square: $i was not added to $bridge. I fixed that for you."
      elif [ ! -f "$state_file" ]; then
        send_alert ":exclamation: $i is not added to $bridge."
        touch "$state_file"
      fi
    elif [ -f "$state_file" ]; then
      send_alert ":white_check_mark: $i has been added to $bridge."
      rm "$state_file"
    fi
  done
fi
