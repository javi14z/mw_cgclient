#!/bin/bash

# Verifica si la variable de entorno DDOS_SERVER está definida
if [ -z "$ddosserver" ]; then
  echo "La variable de entorno DDOS_SERVER no está definida. Ejecuta export ddosserver=¨ip¨"
  exit 1
fi

# Utiliza la variable de entorno DDOS_SERVER como la dirección del servidor de ataque
ddosserver_ip="$ddosserver"

# Ejecuta la prueba de carga y guarda los resultados en results.bin
(echo "GET https://$ddosserver:8080" ; echo "Host: $ddosserver_ip") | vegeta attack -duration=10s | tee results.bin

# Genera un informe JSON a partir de los resultados
vegeta report -type=json results.bin > metrics.json

# Genera un gráfico HTML a partir de los resultados
cat results.bin | vegeta plot > plot.html

# Genera un informe de histograma a partir de los resultados
cat results.bin | vegeta report -type="hist[0,100ms,200ms,300ms]"
