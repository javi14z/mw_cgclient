#!/bin/bash

# Verifica si la variable de entorno DDOS_SERVER está definida
if [ -z "$ddosserver" ]; then
  echo "La variable de entorno DDOS_SERVER no está definida. Ejecuta export ddosserver=¨ip¨"
  exit 1
fi

# Utiliza la variable de entorno DDOS_SERVER como la dirección del servidor de ataque
ddosserver_ip="$ddosserver"

# Verifica si se proporcionan suficientes argumentos
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <duration>"
  exit 1
fi

duration="$1"

mkdir -p /home/cognet/logs/vegeta

# Ejecuta la prueba de carga y guarda los resultados en results.bin
(echo "GET https://$ddosserver:8080" ; echo "Host: $ddosserver_ip") | vegeta attack -duration="$duration"s | tee /home/cognet/logs/vegeta/results.bin

# Genera un informe JSON a partir de los resultados
vegeta report -type=json /home/cognet/logs/vegeta/results.bin > /home/cognet/logs/vegeta/metrics.json

# Genera un gráfico HTML a partir de los resultados
cat /home/cognet/logs/vegeta/results.bin | vegeta plot > /home/cognet/logs/vegeta/plot.html

# Genera un informe de histograma a partir de los resultados
cat /home/cognet/logs/vegeta/results.bin | vegeta report -type="hist[0,100ms,200ms,300ms]" > /home/cognet/logs/vegeta/histogram.txt
