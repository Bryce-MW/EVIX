#!/bin/bash
# NOTE(bryce): Originally written by Chris, added to git by Bryce Wilson on 2020-09-11.

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "To use this script run $0 <asn> <ipv4/noipv4> <ipv6>"
  echo "Where <asn> is the ASN Number of the pending peer in the database"
  echo
  echo "On a sucessful run, the peer's status in the database should be updated and an IP/IPv6 assigned"
  echo "The changed database will prompt a reconfiguration of BIRD and a re-generation of the website"
  exit
fi

if ! cd /evix/run/openvpn-ca/; then
  echo "Could not change to /evix/run/openvpn-ca/"
  echo "Are you sure that you are running on the server?"
fi

if ./easyrsa build-client-full as_"$1" nopass <<<"password"; then
  if [ "$2" != "noipv4" ]; then
    echo "ifconfig-push $2 255.255.255.0
    ifconfig-ipv6-push $3/64 ::" >/evix/config/ccd/as_"$1"
    echo "Certificate Generated... pushing to tunnel servers."
  else
    echo "ifconfig-ipv6-push $3/64 ::" >/evix/config/ccd/as_"$1"
    echo "Certificate Generated... pushing to tunnel servers."
  fi

  if /usr/bin/ansible-playbook /evix/config/playbooks/push_ccd.yml; then
    echo "CCD file pushed.  Credentials are:"
  fi
  echo "Server CA:"
  cat /evix/run/openvpn-ca/pki/ca.crt
  echo
  echo "User cert:"
  cat /evix/run/openvpn-ca/pki/issued/as_"$1".crt
  echo
  echo "User key:"
  cat /evix/run/openvpn-ca/pki/private/as_"$1".key
fi
