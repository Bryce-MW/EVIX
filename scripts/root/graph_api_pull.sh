#!/bin/bash
# NOTE(bryce): Written by Bryce Wilson on 2020-09-11.
#  * 2020-12-09|>Bryce|>Move out website update

/evix/scripts/root/graph_api_pull_single.sh 1 fremont
/evix/scripts/root/graph_api_pull_single.sh 9 amsterdam
/evix/scripts/root/graph_api_pull_single.sh 3 auckland
/evix/scripts/root/graph_api_pull_single.sh 8 zurich

sleep 2
