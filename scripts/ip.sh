#! /bin/bash

host=$1

host_file=/evix/config/hosts/$host

exec 6<"$host_file"
read -r name <&6
read -r hostname <&6
read -r port <&6

dig "$hostname" +short
