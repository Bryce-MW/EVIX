#! /bin/bash

/usr/bin/sass /evix/run/website
/evix/run/website/peers.py > /evix/run/website/peers.html
/usr/bin/rsync -r -v --delete --del /evix/run/website/ /var/www/evix/new/ --exclude=static/graphs
