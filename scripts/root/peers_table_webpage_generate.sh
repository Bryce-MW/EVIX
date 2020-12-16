#!/bin/bash
# NOTE(bryce): Written by Bryce Wilson on 2020-11-09 (likely originally written by Chris before it was ported to the
#  current git repo)
#  * 2020-11-28|>Bryce|>Removed unused code (see git history)

peers=$(/usr/bin/python3 /evix/scripts/root/update_peers_website.py)
rm /tmp/ix_peers.html
echo "$peers" >/tmp/ix_peers.html

if grep -Fxq "Failed to connect to database" "/tmp/ix_peers.html"; then
  echo "ERROR in connecting to database"
else
  new=$(md5sum /tmp/ix_peers.html)
  echo "$new"
  cp /tmp/ix_peers.html /evix/run/IX-Website/templates/page/ix_peers.html
fi