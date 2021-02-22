#!/bin/bash
# NOTE(bryce): Originally written by Chris, added to git by Bryce Wilson on 2020-09-11.
#  * 2020-11-28|>Bryce|>Fix some of the logic

alias bgpq4=/usr/local/bin/bgpq4

if [ "$EUID" -eq 0 ]; then
  echo "ERROR.  You are root.  Please run as the EVIX user"
  exit
fi

SUCCESS=1

#generate config
if ! cd /evix/run/arouteserver/; then
  echo "Failed to change to /evix/run/arouteserver/"
  echo "Are you running the script on the server?"
fi

PYTHONPATH="$(pwd)"
export PYTHONPATH

mv /etc/arouteserver/clients.yml /etc/arouteserver/clients.yml.bak
/evix/run/arouteserver/scripts/arouteserver clients-from-euroix 756 -i /var/www/evix/participants.json --guess-custom-bgp-communities switch_name --merge-from-peeringdb as-set max-prefix -o /evix/run/arouteserver/clients.yml

new=$(md5sum /etc/arouteserver/clients.yml | cut -f1 -d' ') # I don't understand why cut needs to be required. Someone should put in a pull request to allow --quiet to remove names
old=$(md5sum /etc/arouteserver/clients.yml.bak | cut -f1 -d' ')
if [ "$new" != "$old" ]; then
  /evix/run/arouteserver/scripts/arouteserver bird --target-version 1.6.8 --ip-ver 4 --local-files-dir /etc/bird --use-local-files header -o /tmp/bird.conf
  /evix/run/arouteserver/scripts/arouteserver bird --target-version 1.6.8 --ip-ver 6 --local-files-dir /etc/bird --use-local-files header -o /tmp/bird6.conf
else
  exit 0
fi

SUCCESS=1

new=$(md5sum /tmp/bird.conf | cut -f1 -d' ')
old=$(md5sum /evix/config/bird/bird.conf | cut -f1 -d' ')
new6=$(md5sum /tmp/bird6.conf | cut -f1 -d' ')
old6=$(md5sum /evix/config/bird/bird6.conf | cut -f1 -d' ')

#if file is new
if [ "$new" != "$old" ] || [ "$new6" != "$old6" ]; then
  echo "MD5 has changed... updating bird"
  ansible-playbook /evix/config/playbooks/local_bird.yml

  #if config is valid, reload bird
  if /usr/sbin/bird -p -c /tmp/bird_local.conf; then
    echo "Bird configuration is valid"
    mv /tmp/bird.conf /evix/config/bird/
  else
    echo "Bird configuration is invalid"
    SUCCESS=0
  fi

  #if config is valid, reload bird
  if /usr/sbin/bird6 -p -c /tmp/bird6_local.conf; then
    echo "Bird6 configuration is valid"
    mv /tmp/bird6.conf /evix/config/bird/
  else
    echo "Bird6 configuration is invalid"
    SUCCESS=0
  fi
fi

if [ "$SUCCESS" == "0" ]; then
  echo "Config failed"
else
  ansible-playbook /evix/config/playbooks/push_bird.yml
fi
