#! /bin/bash

/usr/bin/sass /evix/run/website/main.scss /evix/run/website/main.css
/usr/bin/rsync -r /evix/run/website /var/www/evix/new
