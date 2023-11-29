#!/bin/bash

# Check if the DDOS_SERVER environment variable is defined
if [ -z "$ddosserver" ]; then
  echo "An IP address was not provided for the server. Make sure to set the ddosserver environment variable. Run export ddosserver=¨ip¨"
  exit 1
fi

# Use the DDOS_SERVER environment variable as the attack server's address
ddosserver_ip="$ddosserver"

# Check if enough arguments are provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <duration>"
  exit 1
fi

duration="$1"

# Create a directory for storing Vegeta logs
mkdir -p /home/cognet/logs/vegeta

# Run the load test and save the results in results.bin
(echo "GET https://$ddosserver:8080" ; echo "Host: $ddosserver_ip") | vegeta attack -duration="$duration"s | tee /home/cognet/logs/vegeta/results.bin

# Generate a JSON report from the results
vegeta report -type=json /home/cognet/logs/vegeta/results.bin > /home/cognet/logs/vegeta/metrics.json

# Generate an HTML graph from the results
cat /home/cognet/logs/vegeta/results.bin | vegeta plot > /home/cognet/logs/vegeta/plot.html

# Generate a histogram report from the results
cat /home/cognet/logs/vegeta/results.bin | vegeta report -type="hist[0,100ms,200ms,300ms]" > /home/cognet/logs/vegeta/histogram.txt
