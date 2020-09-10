#! /bin/bash

host=$1

hostfile=/evix/config/hosts/$host

exec 6< "$hostfile"
read -r name <&6
read -r hostname <&6
read -r port <&6

dig $hostname +short
