import subprocess

# Comando para agregar la dirección IP en la interfaz eth1
comando_addr = "ip addr add 10.4.0.1/24 dev eth1"
subprocess.run(comando_addr, shell=True)

# Definir las rutas a agregar
rutas = [
    "10.0.7.0/24",
    "10.0.24.0/24",
    "10.0.25.0/24",	
    "192.168.1.0/24",
    "192.168.2.0/24",
    "192.168.3.0/24",
    "192.168.4.0/24",
    "192.168.5.0/24",
    "192.168.6.0/24",
    "192.168.7.0/24",
    "192.168.8.0/24",
    "192.168.9.0/24",
    "192.168.10.0/24",
    "192.168.11.0/24",
    "192.168.12.0/24",
    "192.168.13.0/24",
    "192.168.14.0/24"
]

# Puerta de enlace y nombre de interfaz comunes para todas las rutas
puerta_enlace = "10.4.0.13"
interfaz = "eth1"

# Agregar la dirección IP en eth1
subprocess.run(comando_addr, shell=True)

# Agregar cada ruta utilizando subprocess
for ruta in rutas:
    comando = f"ip route add {ruta} via {puerta_enlace} dev {interfaz}"
    subprocess.run(comando, shell=True)