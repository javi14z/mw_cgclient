#!/bin/bash

logText=$1
log=$2
initialTime=$3
duration=$4
host=$5

cvlc -q http://172.16.1.10$host:8080 --sout '#display{novideo,noaudio}' vlc://quit && result=OK || result=NOK

logTextFinal="$logText, $(echo "$(date +%s%N)/1000000000 - $initialTime" | bc -l), cvlc, "

if [ $result == OK ]
then
	printf '%s%s\n' "$logTextFinal" "[OK]" >> $log
else
	printf '%s%s\n' "$logTextFinal" "[NOK]" >> $log
fi
