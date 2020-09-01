host=`/evix/scripts/hostname.sh`

git fetch

git diff --name-only bryce-update...origin/bryce-update | grep '\.peers' | cut -d '.' -f1 | xargs bash -c "/evix/scripts/$0"
