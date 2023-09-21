#!/bin/bash

# Ejecuta la prueba de carga y guarda los resultados en results.bin
sudo vegeta attack -targets=vegeta-config.txt -duration=10s | tee results.bin

# Genera un informe JSON a partir de los resultados
vegeta report -type=json results.bin > metrics.json

# Genera un gráfico HTML a partir de los resultados
cat results.bin | vegeta plot > plot.html

# Genera un informe de histograma a partir de los resultados
cat results.bin | vegeta report -type="hist[0,100ms,200ms,300ms]"
