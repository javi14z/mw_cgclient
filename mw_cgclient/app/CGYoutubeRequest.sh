#!/bin/bash

LINEAS=$(wc -l ./YoutubeLinksv4.txt | cut -d ' ' -f1)
SELECTION=$((${RANDOM} % $LINEAS + 1))
LINK=$(sed "${SELECTION}q;d" ./YoutubeLinksv4.txt)

logText=$1
log=$2
initialTime=$3
duration=$4
host=$5

python selenium-test_video.py "$LINK" $duration && result=OK || result=NOK

logTextFinal="$logText, $(echo "$(date +%s%N)/1000000000 - $initialTime" | bc -l), $LINK, "

if [ $result == OK ]
then
        printf '%s%s\n' "$logTextFinal" "[OK]" >> $log
else
        printf '%s%s\n' "$logTextFinal" "[NOK]" >> $log
fi
