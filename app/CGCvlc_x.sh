#!/bin/bash

logText=$1
log=$2
initialTime=$3
duration=$4
host=$5

if [ $# -ne 5 ]
then
        echo "Error. usage:$0 logText logfile initilTime duration(required) host:1/2/3 (101,102,103)"
        exit 1
fi


#Convert to int
duration=$( echo "($duration+0.5)/1" | bc  )

v1=$RANDOM
echo "v1:$v1"
vlc_secure=$(($v1 % 2))
echo "vlc_secure $vlc_secure"
if [ $vlc_secure == 0 ]
then
  http="http"
  port=8080
else
  http="https"
  port=8089
fi


externalRand=$(($RANDOM % 2))
#externalRand=1
echo "External/Internal vlc: $externalRand. 0:UPM, 1:MW"
if [ $externalRand == 1 ]
then
  # MW
  vlc_host="vmcgserver10$host"
  #vlc_host="172.16.1.10$host"
  #vlc_host="172.16.1.10$host"
  #for server in 192.168.159.10$host 172.16.1.10$host
  for server in $vlc_host
  do
    acceso_ok=$(ping -c 2 $server | grep time | wc -l)
    if [ $acceso_ok -gt 1 ]
    then
	vlc_host=$server
	echo "server contactado $server"
	break
    fi
  done
  echo "server definitivo  $vlc_host"

else
  # UPM
  vlc_host="138.100.156.252"
fi

echo "server FINAL  $vlc_host $http"

#cvlc -q ${http}://${vlc_host}:$port --sout '#display{novideo,noaudio}' vlc://quit && result=OK || result=NOK
echo ">>>>>>> " cvlc --run-time $duration  ${http}://${vlc_host}:$port --sout '#display{novideo,noaudio}' vlc://quit
cvlc   --run-time $duration ${http}://${vlc_host}:$port --sout '#display{novideo,noaudio}' vlc://quit 

logTextFinal="$logText, $(echo "$(date +%s%N)/1000000000 - $initialTime" | bc -l), cvlc, "
printf '%s%s\n' "$logTextFinal" "$result" >> $log

