#! /bin/bash

hosts=("/evix/config/hosts"/*)

ips=`ip -br addr | egrep -o -e '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' -e '([a-f0-9:]+:+)+[a-f0-9]+'`

host=""

for host in $hosts; do
  exec 6< "$host"
  read -r name <&6
  read -r hostname <&6
  read -r port <&6

  for ip in $ips; do
    if [ $ip == "`dig $hostname +short`" ]; then
      host=$host
    fi
  done

done

if [ host == "" ]; then
  exit -1
done
