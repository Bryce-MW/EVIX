host=`/evix/scripts/hostname.sh`

branch=`git branch | grep '*' | cut -d " " -f2`

git fetch -C /evix --recurse-submodules

updates=(`git diff -C /evix --name-only $branch...origin/$branch | grep "config/peers/$host" | cut -d '.' -f2`)

git merge -C /evix origin/$branch

for update in $updates; do
  /evix/scripts/ts/$update.sh
done

git submodule sync -C /evix --recursive
