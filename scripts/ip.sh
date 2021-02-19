#! /bin/bash
# NOTE(bryce): Written by Bryce Wilson on 2020-08-30
#  * 2020-11-28|>Bryce|>Made some minor fixes

host=$1

host_file=/evix/config/hosts/$host

exec 6<"$host_file"
read -r name <&6
read -r hostname <&6
read -r port <&6

dig "$hostname" +short
