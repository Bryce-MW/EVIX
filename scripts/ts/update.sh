host=`/evix/scripts/hostname.sh`

git -C /evix pull --recurse-submodules

for $script in /evix/scripts/ts/tunnels/*; do
  $script
done

git -C /evix submodule sync --recursive
git -C /evix submodule update --remote --init --recursive
