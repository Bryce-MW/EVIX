#!/bin/bash

JSON=`/usr/bin/php /evix/scripts/peers-json.php`

#if config is valid, reload bird
if [ $? -eq 0 ];then
  echo Exit Code OK, updating website
  rm /var/www/html/participants.json
  echo $JSON > /var/www/html/participants.json
else
  echo Exit code NOT ok, NOT updating website
fi
