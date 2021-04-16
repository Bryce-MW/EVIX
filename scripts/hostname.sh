#! /bin/bash
# NOTE(bryce): Written by Bryce Wilson on 2020-08-30
#  * 2020-08-31|>Bryce|>Fixed bugs
#  * 2020-11-28|>Bryce|>Made some changes that I don't fully understand
#  * 2020-12-01|>Bryce|>Fixed an issue caused by not understanding what I did
#  * 2021-04-16|>Bryce|>Moved to a pure JQ solution for the new config

{
  \ip -json -br addr | jq '[.[].addr_info | .[].local]'
  jq -L/evix/scripts -r '[.hosts | .[] | {(.primary_ipv4 // empty): .short_name}] | add' /evix/secret-config.json
} |
jq -s -r '.[1][.[0][]] // empty' # This is really clever!
  # It takes the IP to host mappings, indexes it by all of the IPs, only return those that are not null which should
  # always be the hostname. Outputs nothing if it can't be found
