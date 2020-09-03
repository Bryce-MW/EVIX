host=`/evix/scripts/hostname.sh`

branch=`git branch | grep '*' | cut -d " " -f2`

git fetch --recurse-submodules

updates=(`git diff --name-only $branch...origin/$branch | grep "config/peers/$host" | cut -d '.' -f2`)

git merge origin/$branch

for update in $updates; do
  /evix/scripts/ts/$update.sh
done

git submodule sync --recursive
