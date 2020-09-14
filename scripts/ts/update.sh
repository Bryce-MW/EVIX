host=`/evix/scripts/hostname.sh`

branch=`git branch | grep '*' | cut -d " " -f2`

git -C /evix fetch --recurse-submodules

updates=(`git -C /evix diff --name-only $branch...origin/$branch | grep "config/peers/$host" | cut -d '.' -f2`)

git -C /evix merge origin/$branch

for update in $updates; do
  /evix/scripts/ts/$update.sh
done

git -C /evix submodule sync --recursive
