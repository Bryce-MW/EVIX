#! /bin/bash

sass /evix/run/website/main.scss /evix/run/website/main.css
rsync -r /evix/run/website /var/www/evix/new
