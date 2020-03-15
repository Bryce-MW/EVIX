#!/bin/bash

/usr/bin/php /evix/scripts/graph.php 11 fremont
sleep 2
/usr/bin/php /evix/scripts/graph.php 21 amsterdam
sleep 2
/usr/bin/php /evix/scripts/graph.php 35 auckland
cd /evix/IX-Website/
/usr/local/bin/staticjinja build --srcpath=templates --static=static --outpath=/var/www/evix/ --globals=globals.yaml
