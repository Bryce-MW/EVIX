#!/bin/bash

#first generate the config
PYTHONPATH="$(pwd)"
export PYTHONPATH
/evix/run/arouteserver/scripts/arouteserver bird --ip-ver 4 -o /etc/bird/bird.conf
/evix/run/arouteserver/scripts/arouteserver bird --ip-ver 6 -o /etc/bird/bird6.conf

#if config is valid, reload bird
if ! bird -p -c /etc/bird/bird.conf; then
  echo bird configuration is valid
  birdc configure
else
  echo Bird configuration is invalid
fi

#if config is valid, reload bird
if ! bird6 -p -c /etc/bird/bird6.conf; then
  echo bird 6 configuration is valid
  birdc6 configure
else
  echo bird 6 configuration is invalid
fi
