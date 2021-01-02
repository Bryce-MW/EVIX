#! /bin/bash
# NOTE(bryce): Witten by Bryce Wilson on 2021-01-01
#  * 2021-01-01|>Bryce|>Modified from peer_bird_status.sh

#ping_servers=(fmt ams)
ping_servers=(fmt)

hosts=("/evix/config/hosts/${ping_servers[@]}")

for host in "${hosts[@]}"; do
  exec 6<"$host"
  read -r name <&6
  read -r hostname <&6
  read -r port <&6
  mysql --user evix --password=***REMOVED*** --batch evix <<<"select ip from ips" 2>/dev/null |
    tail -n+2 |
    ssh -p "$port" "$hostname" "xargs -n 1 -P 0 bash -c 'ping -c 5 -i 0.2 -n -w 5 \$0 >/dev/null && echo yes \$0 || echo no \$0'" |
    ./ping_status.py
done
