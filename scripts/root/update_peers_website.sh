#!/bin/bash

peers=`/usr/bin/python3 /evix/scripts/root/update_peers_website.py`
rm /tmp/ix_peers.html
echo "$peers" > /tmp/ix_peers.html

if grep -Fxq "Failed to connect to database" "/tmp/ix_peers.html"
then
  echo "ERROR in connecting to database"
else
  new=($(md5sum /tmp/ix_peers.html))
#  old=($(md5sum /evix/run/IX-Website/templates/page/ix_peers.html))
  echo $new
#  echo $old
  #if file is new
#  if [ "$new" != "$old" ];then
    cp /tmp/ix_peers.html /evix/run/IX-Website/templates/page/ix_peers.html
    cd /evix/run/IX-Website/
#    git commit -a -m "Updated website (script)"
#    git push
#    /usr/local/bin/staticjinja build --srcpath=templates --static=static --outpath=/var/www/evix/ --globals=globals.yaml
  fi
fi
