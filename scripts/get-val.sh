#! /bin/bash
# NOTE(bryce): Written by Bryce Wilson on 2020-08-30
#  * 2020-11-28|>Bryce|>Minor fix of syntax

host=$1
key=$2

grep "$key=" "/evix/config/key-value/$host.conf" | cut -d '=' -f2
