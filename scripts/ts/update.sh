host=`/evix/scripts/hostname.sh`

branch=`git branch --show-current`

git fetch --recurse-submodules -j 8

updates=(`git diff --name-only $branch...origin/$branch | grep "config/peers/$host" | cut -d '.' -f2`)

git merge origin/$branch

for update in $updates; do
  /evix/scripts/ts/$update.sh
done

git submodule sync --recursive
