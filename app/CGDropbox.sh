#!/bin/bash

logText=$1
log=$2
initialTime=$3
duration=$4
host=$5

sim=1

del=$(($RANDOM % 2))
sleep 20

if [ $del == 1 ]
then
	filesize=$(($RANDOM*512))
	base64 /dev/urandom | head -c $filesize > "/home/cognet/Dropbox/$(date +%N)"
else
	#randfile=$(ls /home/cognet/Dropbox | sort -R | tail -1)
	randfile=$(ls /home/cognet/Dropbox | shuf -n 1)
	if [ -z $randfile ]; then
		echo "No files"
	else
		rm /home/cognet/Dropbox/$randfile
	fi
fi

python3 dropbox.py start && result=OK || result=NOK

logTextFinal="$logText, $(echo "$(date +%s%N)/1000000000 - $initialTime" | bc -l), dropbox, "

if [ $result == OK ]
then
	printf '%s%s\n' "$logTextFinal" "[OK]" >> $log
else
	printf '%s%s\n' "$logTextFinal" "[NOK]" >> $log
fi

