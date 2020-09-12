#!/bin/bash

/evix/scripts/generate-graphs-test.sh 1 fremont
/evix/scripts/generate-graphs-test.sh 9 amsterdam
/evix/scripts/generate-graphs-test.sh 3 auckland
/evix/scripts/generate-graphs-test.sh 8 zurich
sleep 2
cd /evix/IX-Website/
/usr/local/bin/staticjinja build --srcpath=templates --static=static --outpath=/var/www/evix/ --globals=globals.yaml
