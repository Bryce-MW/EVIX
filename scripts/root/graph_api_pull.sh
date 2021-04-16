#!/bin/bash
# NOTE(bryce): Written by Bryce Wilson on 2020-09-11.
#  * 2020-12-09|>Bryce|>Move out website update
#  * 2021-04-16|>Bryce|>Added JSON config

jq -L/evix/scripts -r 'graph_get_ids' secret-config.json |
  xargs -L 1 /evix/scripts/root/graph_api_pull_single.sh

sleep 2
