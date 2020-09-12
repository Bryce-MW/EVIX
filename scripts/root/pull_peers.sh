#!/bin/bash

if [ "$EUID" -eq 0 ]
  then echo "ERROR.  You are root.  Please run as the EVIX user"
  exit
fi

SUCCESS=1
  #generate yaml from database
  PEERS=$(/usr/bin/php /evix/scripts/root/pull_users.php)
  mv /etc/arouteserver/clients.yml /etc/arouteserver/clients.yml.bak
  echo "$PEERS" > /etc/arouteserver/clients.yml

  #generate config
  cd /evix/run/arouteserver/
  export PYTHONPATH="`pwd`"
  /evix/run/arouteserver/scripts/arouteserver bird --ip-ver 4 --local-files-dir /etc/bird --use-local-files header  -o /tmp/bird.conf
  /evix/run/arouteserver/scripts/arouteserver bird --ip-ver 6 --local-files-dir /etc/bird --use-local-files header -o /tmp/bird6.conf

  new=($(md5sum /tmp/bird.conf))
  old=($(md5sum /evix/config/bird/bird.conf))

  #if file is new
  if [ "$new" != "$old" ];then
    echo md5 has changed... updating bird
    #validate config
    /usr/sbin/bird -p -c /tmp/bird.conf

    #if config is valid, reload bird
    if [ $? -eq 0 ];then
      echo bird configuration is valid
      mv /tmp/bird.conf /evix/config/bird/
      sed -i -e 's/rs_as = 137933/rs_as = {{ rs_asn }}/g' /evix/config/bird/bird.conf
      sed -i -e 's/local as 137933/local as {{ rs_asn }}/g' /evix/config/bird/bird.conf
      SUCCESS=1
    else
      echo Bird configuration is invalid
      SUCCESS=0
    fi
  fi

  new=($(md5sum /tmp/bird6.conf))
  old=($(md5sum /evix/config/bird/bird6.conf))

  #if file is new
  if [ "$new" != "$old" ];then

   #validate config
    /usr/sbin/bird6 -p -c /tmp/bird6.conf

    #if config is valid, reload bird
    if [ $? -eq 0 ];then
      echo bird 6 configuration is valid
      mv /tmp/bird6.conf /evix/config/bird/
      sed -i -e 's/rs_as = 137933/rs_as = {{ rs_asn }}/g' /evix/config/bird/bird6.conf
      sed -i -e 's/local as 137933/local as {{ rs_asn }}/g' /evix/config/bird/bird6.conf
      SUCCESS=1
    else
      echo Bird 6 configuration is invalid
      SUCCESS=0
    fi
  fi

    /usr/bin/ansible-playbook /evix/config/playbooks/push_bird.yml
  fi
