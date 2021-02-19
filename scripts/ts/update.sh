#! /bin/bash
# NOTE(bryce): Written by Bryce Wilson on 2020-08-31
#  * 2020-09-01|>Bryce|>Allow automatic branch changing
#  * 2020-09-02|>Bryce|>Recurse submodules
#  * 2020-09-01|>Bryce|>Ensure old git versions work and that the script works wherever it is called
#  * 2020-09-18|>Bryce|>Peers config is now a separate repo
#  * 2020-09-19|>Bryce|>Submodules are now updated properly
#  * 2020-11-18|>Bryce|>Attempted to fix EoIP
#  * 2021-02-14|>Bryce|>Remove git now that ansible is used

for script in /evix/scripts/ts/tunnels/*; do
  $script
done

exit 0
