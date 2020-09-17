#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ];then
  echo "To use this script run ./generateOpenVPN.sh <asn> <ipv4/noipv4> <ipv6>"
  echo "Where <asn> is the ASN Number of the pending peer in the database"
  echo
  echo "On a sucessful run, the peer's status in the database should be updated and an IP/IPv6 assigned"
  echo "The changed database will prompt a reconfiguration of BIRD and a re-generation of the website"
  exit
fi

cd /evix/run/openvpn-ca/
./easyrsa build-client-full as_$1 nopass <<< "password"
res=$?
if [ $res -eq 0 ];then
  if [ "$2" != "noipv4" ]; then
    echo "ifconfig-push $2 255.255.255.0
    ifconfig-ipv6-push $3/64 ::" > /evix/config/ccd/as_$1
    echo "Certificate Generated... pushing to tunnel servers."
  else
    echo "ifconfig-ipv6-push $3/64 ::" > /evix/config/ccd/as_$1
    echo "Certificate Generated... pushing to tunnel servers."
  fi
  /usr/bin/ansible-playbook /evix/config/playbooks/push_ccd.yml
  res=$?
  if [ $res -eq 0 ];then
    echo "CCD file pushed.  Credentials are:"
    echo "Server CA:"
    cat /evix/run/openvpn-ca/pki/ca.crt
    echo
    echo "User cert:"
    cat /evix/run/openvpn-ca/pki/issued/as_$1.crt
    echo
    echo "User key:"
    cat /evix/run/openvpn-ca/pki/private/as_$1.key
  fi
fi

cd /evix
git add --all
