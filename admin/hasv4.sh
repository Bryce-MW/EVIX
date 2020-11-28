#! /bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <asn>"
  echo "Please provide the ASN which you would like to check"
fi

output=$(whois -h whois.radb.net -i origin "$1" | grep "route:")

if [[ $output ]]; then
  echo "$output"
else
  echo "No IPv4 route objects exist for $1"
fi
