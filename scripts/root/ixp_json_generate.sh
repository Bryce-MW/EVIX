#!/bin/bash
# NOTE(bryce): Originally written by Chris, added to git by Bryce Wilson on 2020-09-13.
#  * 2020-11-28|>Bryce|>Cleaned up a bit
#  * 2020-11-29|>Bryce|>Added printing of result for debugging

if JSON=$(/usr/bin/php /evix/scripts/root/ixp_json_generate.php); then
  echo Exit Code OK, updating website
  echo '' >/var/www/evix/participants.json
  echo "$JSON" >/var/www/evix/participants.json
else
  echo "$JSON" | jq -C '.'
  echo Exit code NOT ok, NOT updating website
fi
