#! /bin/bash
# NOTE(bryce): Written by Bryce Wilson on 2020-09-19
#  * 2020-09-23|>Bryce|>Stash Changes
#  * 2021-02-21|>Alex|>Remove directories no longer tracked in git

if ! cd /evix; then
  echo "Could not change to /evix/config"
  echo "Are you sure that you are connected to the server?"
  return 1
fi

git stash
git pull
git submodule sync --recursive
git submodule update --remote --init --recursive
git stash pop
