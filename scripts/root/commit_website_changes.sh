#! /bin/bash
# NOTE(bryce): Written by Bryce Wilson on 2020-12-09

if ! cd /evix/run/IX-Website/; then
  echo "Could not change to /evix/run/IX-Website/"
  echo "Are you running this script from the server?"
fi

/usr/local/bin/staticjinja build --srcpath=templates --static=static --outpath=/var/www/evix/ --globals=globals.yaml
