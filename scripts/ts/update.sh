#! /bin/bash

for script in /evix/scripts/ts/tunnels/*; do
  $script
done

exit 0
