#!/bin/bash

if [ -z "$1" ];then
  echo "To use this script run ./approve_peer.sh <asn>"
  echo "Where <asn> is the ASN Number of the pending peer in the database"
  echo
  echo "You may also run this script with the first argument as 'pending' to display all pending peers"
  echo
  echo "On a sucessful run, the peer's status in the database should be updated and an IP/IPv6 assigned"
  echo "The changed database will prompt a reconfiguration of BIRD and a re-generation of the website"
  exit
fi

/usr/bin/php /evix/scripts/approve_peer.php $1
res=$?
if [ $res -eq 0 ];then
  echo
  echo database updated successfully, generating BIRD configs...
  /evix/scripts/pull_peers.sh
elif [ $res -eq 2 ];then
  echo
  echo ERROR: No available IP address for peer, NOT reloading BIRD
elif [ $res -eq 3 ];then
  echo
  echo "Please re-run this script like ./approve_peer.sh <asn> to run the approval"
else
  echo
  echo An error has occured updating the database, NOT reloading BIRD
fi
