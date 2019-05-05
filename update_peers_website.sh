#!/bin/bash

peers=`/usr/bin/php /evix/scripts/update_peers_website.php`
echo "$peers" > /tmp/ix_peers.html

if grep -Fxq "Failed to connect to database" "/tmp/ix_peers.html"
then
  echo "ERROR in connecting to database"
else
  new=($(md5sum /tmp/ix_peers.html))
  old=($(md5sum /evix/IX-Website/templates/page/ix_peers.html))
  echo $new
  echo $old
  #if file is new
  if [ "$new" != "$old" ];then
    cp /tmp/ix_peers.html /evix/IX-Website/templates/page/ix_peers.html
    cd /evix/IX-Website/
    /usr/local/bin/staticjinja build --srcpath=templates --static=static --outpath=/var/www/evix/ --globals=globals.yaml
  fi
fi
