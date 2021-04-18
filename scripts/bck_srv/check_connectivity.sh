#!/bin/bash
# NOTE(alex): Written by Alex on 2021-03-14
# Check connectivity to our Route Servers over tunnels
#  * 2021-03-14|>Alex|>Initial version
#  * 2021-04-16|>Bryce|>Added JSON config

STATE_FILE_DIR="/tmp/evix_monitoring"
WEBHOOK_URL=$(jq -r '.monitoring.webhook_url' /evix/secret-config.json)

host=$(/bin/hostname -s)
route_servers=("2602:fed2:fff:ffff::1" "2602:fed2:fff:ffff::253")

# Let's be careful
alias rm='rm -I'

# Create directory to store state files in case it doesn't exist
mkdir -p "$STATE_FILE_DIR"

interfaces=$(basename -a /sys/class/net/{eoip,vxlan,ovpn,zt}*)

send_alert() {
  curl -X POST \
    -H "Content-Type: application/json" \
    -d "{\"username\": \"$host\", \"content\": \"$1\"}" \
    $WEBHOOK_URL
}

for if in $interfaces; do
  for rs in ${route_servers[*]}; do
    state_file="$STATE_FILE_DIR/ping.$if.to.$rs.failed"
    date
    ping6 -q -c 3 -I $if $rs
    if [ $? -ne 0 ]; then
      if [ ! -f "$state_file" ]; then
        send_alert ":exclamation: Route Server $rs could not be reached via $if."
        touch "$state_file"
      fi
    elif [ -f "$state_file" ]; then
      send_alert ":white_check_mark: Route Server $rs is reachable via $if again."
      rm "$state_file"
    fi
  done
done
