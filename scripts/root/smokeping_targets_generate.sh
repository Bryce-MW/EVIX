#!/bin/bash
# NOTE(alex): Written by Alex on 2021-03-15
#  * 2021-03-15|>Alex|>Update smokeping config and tweak permissions

TMPDIR="/tmp"
SMOKEPING_CONF_DIR="/evix/config/smokeping/config.d"
CONF_FILE_NAME="peers.conf"

SMOKEPING_DATA_DIR="/var/lib/smokeping"

date=$(date +%s)

oldconf="$SMOKEPING_CONF_DIR/$CONF_FILE_NAME"
newconf="$TMPDIR/$date_$CONF_FILE_NAME"

# Generate new config
/usr/bin/python3 /evix/scripts/root/smokeping_targets_generate.py > "$newconf"

# Check if the config has changed
if ! cmp -s "$oldconf" "$newconf"; then
  mv -f "$newconf" "$oldconf"
  touch "$SMOKEPING_CONF_DIR/../config"
else
  rm "$newconf"
fi

# HACK: Fix permissions for smokeping's RRD files
# these need to be writeable by both, smokeping and the webserver
sudo chown -R smokeping:www-data "$SMOKEPING_DATA_DIR"
sudo chmod -R g+w "$SMOKEPING_DATA_DIR"
