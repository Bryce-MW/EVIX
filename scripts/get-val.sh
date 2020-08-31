#! /bin/bash

host=$1
key=$2

grep "$key=" /evix/config/key-value/$host.conf | cut -d '=' -f2
