#!/bin/bash

Xvfb :19 -screen 0 1024x768x16 > /dev/null &
export DISPLAY=:19

procs=$(ps -ef | grep chromium | grep -v "defunct" | wc -l )
if [ "$procs" -gt 15 ]
then
	# Too many processes
	echo "Too many chromium processes: $procs"
	exit 1
else
	echo "Chromium processes: $procs"
fi

duration_web=0

# http/https secure=1
secure=$(($RANDOM % 2))
if [ $secure == 0 ]
then
  http="http"
  port=7080
else
  http="https"
  port=7443
fi

# MW server
servers=3
mwhost=$(( ($RANDOM % servers)+1 ))

# Servidor Web: MW o UPM-Lab
externalRand=$(($RANDOM % 2))
if [ $externalRand == 1 ]
then
  # MW
  host="172.16.1.10${mwhost}"
else
  # UPM. snowstorm
  host="138.100.156.252"
fi

# Pagina.
max_pag=18
page_num=$(($RANDOM % max_pag+1))
page=pag_${page_num}.html

#debug
#http=http
#host="138.100.156.252"
#port=7080

link="${http}://${host}:${port}/${page}"

bash -xv  ./selenium.sh $link 0
