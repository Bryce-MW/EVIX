#! /bin/bash

cd /evix/config/peers
git commit -a -m "Updated peers (script)"
git push

cd /evix/config/ccd
git add --all
git commit -a -m "Updated OpenVPN peers (script)"cd /evix/config/peers
git commit -a -m "Updated peers (script)"
git push

cd /evix/config/ccd
git add --all
git commit -a -m "Updated OpenVPN peers (script)"

cd /evix
git pull
git submodule sync --recursive
git submodule update --remote --init --recursive
