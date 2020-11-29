#!/bin/bash

if ! JSON=$(/usr/bin/php /evix/scripts/root/peers-json.php); then
  echo Exit Code OK, updating website
  echo '' >/var/www/evix/participants.json
  echo "$JSON" >/var/www/evix/participants.json
else
  echo "$JSON" | jq -C '.'
  echo Exit code NOT ok, NOT updating website
fi
