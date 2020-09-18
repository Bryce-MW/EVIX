#!/bin/bash

JSON=`/usr/bin/php /evix/scripts/peers-json.php`

if [ $? -eq 0 ];then
  echo Exit Code OK, updating website
  echo '' >  /var/www/evix/participants.json
  echo $JSON > /var/www/evix/participants.json
else
  echo Exit code NOT ok, NOT updating website
fi
