#!/bin/bash

logText=$1
log=$2
initialTime=$3
duration=$4
host=$5

sim=1
cat <<FIN >/dev/null
del=$(($RANDOM % 2))
sleep 20

if [ $del == 1 ]
then
	filesize=$(($RANDOM*512))
	base64 /dev/urandom | head -c $filesize > "/home/cognet/Dropbox/$(date +%N)"
else
	randfile=$(ls /home/cognet/Dropbox | shuf -n 1)
	if [ -z $randfile ]; then
		echo "No files"
	else
		rm /home/cognet/Dropbox/$randfile
	fi
fi
FIN

# Genera operaciones sobre directorio de ficheros
MAX_CHANGES=5
rnd=$RANDOM
num_ops=$(( rnd % MAX_CHANGES))
#num_ops=0
for i in `seq $num_ops` 
do
  del=$(($RANDOM % 2))
  if [ $del == 1 ]
  then
        echo "Create file.."
        filesize=$(($RANDOM*16))
        #base64 /dev/urandom | head -c $filesize > "/home/cognet/$own_dir/$(date +%N)"
	base64 /dev/urandom | head -c $filesize > "/home/cognet/Dropbox/$(date +%N)"
  else
        randfile=$(ls /home/cognet/Dropbox | shuf -n 1)
        if [ -z $randfile ]; then
                echo "No files"
        else
                echo "Remove file .."
                #rm /home/cognet/$own_dir/$randfile
		rm /home/cognet/Dropbox/$randfile
        fi
  fi
  sleep 1
done
sleep 5

~/.dropbox-dist/dropboxd &
sleep 2
#python ~/dropbox.py start && result=OK || result=NOK
python dropbox.py start 

logTextFinal="$logText, $(echo "$(date +%s%N)/1000000000 - $initialTime" | bc -l), dropbox, "

if [ $result == OK ]
then
	printf '%s%s\n' "$logTextFinal" "[OK]" >> $log
else
	printf '%s%s\n' "$logTextFinal" "[NOK]" >> $log
fi

