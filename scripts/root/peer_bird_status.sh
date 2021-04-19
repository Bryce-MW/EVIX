#! /bin/bash
# NOTE(bryce): Witten by Bryce Wilson on 2020-09-11
#  * 2020-11-28|>Bryce|>Improve readability of long pipelines
#  * 2021-04-16|>Bryce|>Added JSON config

jq -r --compact-output '.hosts[] | select(.roles | contains(["rs"])) | {name, hostname, ssh_port}' /evix/secret-config.json |
  while read -r line; do
    name=$(jq -r '.name' <<<"$line")
    hostname=$(jq -r '.hostname' <<<"$line")
    port=$(jq -r '.ssh_port' <<<"$line")
    ssh -n -p "$port" "$hostname" birdc show protocols all | tail -n +3 | head -n -1 |
      jq --slurp --raw-input --raw-output 'parse_bird' |
      python3 /evix/scripts/root/warn_disconnection.py 4 "$name"
    ssh -n -p "$port" "$hostname" birdc6 show protocols all | tail -n +3 | head -n -1 |
      jq --slurp --raw-input --raw-output 'parse_bird' |
      python3 /evix/scripts/root/warn_disconnection.py 6 "$name"
  done
