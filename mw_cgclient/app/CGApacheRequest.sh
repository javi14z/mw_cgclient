#!/bin/bash

logText=$1
log=$2
initialTime=$3
duration=$4
host=$5

python selenium-test.py "http://172.16.1.10$host" $duration && result="OK" || result="NOK"

logTextFinal="$logText, $(echo "$(date +%s%N)/1000000000 - $initialTime" | bc -l), http://172.16.1.10$host, "

if [ $result == OK ]
then
	printf '%s%s\n' "$logTextFinal" "[OK]" >> $log
else
	printf '%s%s\n' "$logTextFinal" "[NOK]" >> $log
fi
