#! /bin/bash

/usr/bin/sass /evix/run/website/main.scss /evix/run/website/main.css
/usr/bin/rsync -r -v --delete --del /evix/run/website/ /var/www/evix/new/
