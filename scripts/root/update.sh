#! /bin/bash
# NOTE(bryce): Written by Bryce Wilson on 2020-09-19
#  * 2020-09-23|>Bryce|>Stash Changes

if ! cd /evix/config/peers; then
  echo "Could not change to /evix/config/peers"
  echo "Are you sure that you are connected to the server?"
  return 1
fi

git add --all
git stash
git checkout master
git pull
git stash pop
git commit -a -m "Updated peers (script)"
git push

if ! cd /evix/config/ccd; then
  echo "Could not change to /evix/config/peers"
  echo "Are you sure that you are connected to the server?"
  return 1
fi

git add --all
git stash
git checkout master
git pull
git stash pop
git commit -a -m "Updated OpenVPN peers (script)"

if ! cd /evix; then
  echo "Could not change to /evix/config/peers"
  echo "Are you sure that you are connected to the server?"
  return 1
fi

git pull
git submodule sync --recursive
git submodule update --remote --init --recursive
