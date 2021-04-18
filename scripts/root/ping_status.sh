#! /bin/bash
# NOTE(bryce): Witten by Bryce Wilson on 2021-01-01
#  * 2021-01-01|>Bryce|>Modified from peer_bird_status.sh
#  * 2021-02-19|>Bryce|>Add reconnect flag
#  * 2021-04-16|>Bryce|>Added JSON config

user=$(jq -r '.database.user' /evix/secret-config.json)
password=$(jq -r '.database.password' /evix/secret-config.json)
database=$(jq -r '.database.database' /evix/secret-config.json)

jq -r --compact-output '.hosts[] | select(.roles | contains(["rs"])) | {hostname, ssh_port}' /evix/secret-config.json |
  while read -r line; do
    hostname=$(jq -r '.hostname' <<<"$line")
    port=$(jq -r '.ssh_port' <<<"$line")
    mysql --user "$user" --password="$password" --batch --reconnect "$database" <<<"SELECT ip FROM ips" 2>/dev/null |
      tail -n+2 |
      ssh -p "$port" "$hostname" "xargs -n 1 -P 0 bash -c 'ping -c 5 -i 0.2 -n -w 5 \$0 >/dev/null 2>&1 && echo yes \$0 || echo no \$0'" |
      /evix/scripts/root/ping_status.py
  done
