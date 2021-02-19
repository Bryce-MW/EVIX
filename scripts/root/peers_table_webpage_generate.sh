#!/bin/bash
# NOTE(bryce): Written by Chris a long time ago and added to git by Bryce Wilson on 2020-11-09
#  * Before 2020-11-09|>Bryce|>Switched to using the python script rather than the PHP script Chris wrote
#  * 2020-11-28|>Bryce|>Removed unused code (see git history)

peers=$(/usr/bin/python3 /evix/scripts/root/peers_table_webpage_generate.py)
rm /tmp/ix_peers.html
echo "$peers" >/tmp/ix_peers.html

if grep -Fxq "Failed to connect to database" "/tmp/ix_peers.html"; then
  echo "ERROR in connecting to database"
else
  cat /tmp/ix_peers.html
  cp /tmp/ix_peers.html /evix/run/IX-Website/templates/page/ix_peers.html
fi
