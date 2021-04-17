#! /bin/bash
# NOTE(bryce): Written by Bryce Wilson on 2020-08-30
#  * 2020-11-28|>Bryce|>Made some minor fixes
#  * 2021-04-16|>Bryce|>Switched to use entirely JQ with the new config system

jq -r --arg host "$1" '.hosts[$host].primary_ipv4' /evix/secret-config.json
