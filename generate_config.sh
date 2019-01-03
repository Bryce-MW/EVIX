#!/bin/bash

#first generate the config
export PYTHONPATH="`pwd`"
/evix/arouteserver/scripts/arouteserver bird --ip-ver 4 -o /etc/bird/bird.conf
/evix/arouteserver/scripts/arouteserver bird --ip-ver 6 -o /etc/bird/bird6.conf

#verify the syntax
bird -p -c /etc/bird/bird.conf

#if config is valid, reload bird
if [ $? -eq 0 ];then
  echo bird configuration is valid
  birdc configure
else
  echo Bird configuration is invalid
fi

#verify the syntax
bird6 -p -c /etc/bird/bird6.conf

#if config is valid, reload bird
if [ $? -eq 0 ];then
  echo bird 6 configuration is valid
  birdc6 configure
else
  echo bird 6 configuration is invalid
fi

