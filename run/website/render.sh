#! /bin/bash

/usr/bin/sass /evix/run/website
/usr/bin/rsync -r -v --delete --del /evix/run/website/ /var/www/evix/new/ --exclude=static/graphs --exclude='*.jinja.html'
