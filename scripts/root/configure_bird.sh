#!/bin/bash

if [ `whoami` != 'evix' ]; then
   echo "Only configure bird as EVIX please!"
   exit 1
fi

SUCCESS=1
  #generate yaml from database
  PEERS=$(/usr/bin/php /evix/scripts/root/pull_users.php)
  mv /etc/arouteserver/clients.yml /etc/arouteserver/clients.yml.bak
  echo "$PEERS" > /etc/arouteserver/clients.yml

  #generate config
  cd /evix/run/arouteserver/
  export PYTHONPATH="`pwd`"
  /evix/run/arouteserver/scripts/arouteserver bird --ip-ver 4 -o /tmp/bird.conf
  /evix/run/arouteserver/scripts/arouteserver bird --ip-ver 6 -o /tmp/bird6.conf

    #validate config
    bird -p -c /tmp/bird.conf

    #if config is valid, reload bird
    if [ $? -eq 0 ];then
      echo bird configuration is valid
      mv /tmp/bird.conf /etc/bird/bird.conf
      birdc configure
      SUCCESS=1
    else
      echo Bird configuration is invalid
      SUCCESS=0
    fi

   #validate config
    bird6 -p -c /tmp/bird6.conf

    #if config is valid, reload bird
    if [ $? -eq 0 ];then
      echo bird 6 configuration is valid
      mv /tmp/bird6.conf /etc/bird/bird6.conf
      SUCCESS=1
      birdc6 configure
    else
      echo Bird 6 configuration is invalid
      SUCCESS=0
    fi
