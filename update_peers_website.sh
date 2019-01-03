#!/bin/bash

peers=`/usr/bin/php /evix/scripts/update_peers_website.php`
echo "$peers" > /tmp/ix_peers.html

new=($(md5sum /tmp/ix_peers.html))
old=($(md5sum /evix/IX-website/templates/page/ix_peers.html))
echo $new
echo $old
#if file is new
if [ "$new" != "$old" ];then
  mv /tmp/ix_peers.html /evix/IX-website/templates/page/ix_peers.html
  cd /evix/IX-website/
  /usr/local/bin/staticjinja build --srcpath=templates --static=static --outpath=/var/www/html/ --globals=globals.yaml
fi
