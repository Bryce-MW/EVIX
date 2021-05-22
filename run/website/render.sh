#! /bin/bash

/usr/bin/sass /evix/run/website
/evix/run/website/peers.py > /evix/run/website/peers.html
/usr/bin/rsync -r -v --delete --delete-during  /evix/run/website/ /var/www/evix/ \
  --exclude='static/graphs' --exclude='.well-known' --exclude='participants.json' --exclude='evix.json' \
  --exclude='*.sh' --exclude='peers.jinja.html' --exclude='peers.py' --exclude='peers.jq' --exclude='__pycache__'
