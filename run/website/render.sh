#! /bin/bash

mkdir -p /var/www/evix/new
rm -rf /var/www/evix/new/*
cp -r /evix/run/website/* /var/www/evix/new/
cd /var/www/evix/new || exit
sass ./main.scss
