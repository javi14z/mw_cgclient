#!/bin/bash

logText=$1
#logfile-> log
log=$2
initialTime=$3
duration=$4
host=$5
debug=$6

v1=$RANDOM
echo "v1:$v1"
own_secure=$(($v1 % 2))
own_secure=0
echo "own_secure $own_secure"
if [ $own_secure == 0 ]
then
  owncloud="owncloud"
else
  owncloud="ownclouds"
fi

if [ "$debug" == "" ]
then
  output_cmd=" &> /dev/null"
else
  output_cmd=""
fi

externalRand=$(($RANDOM % 2))
externalRand=1
echo "External/Internal owncloud: $externalRand. 0:MW, 1:UPM"
if [ $externalRand == 0 ]
then
  # MW
  own_host="172.16.1.10$host"
  own_dir="mousecloud$host"
  own_lock="/var/lock/.CGOwncloudGB_MW.$host.exclusivelock"
else
  # UPM
  own_host="138.100.156.252"
  own_dir="upmcloud"
  own_lock="/var/lock/.CGOwncloudGB_UPM.exclusivelock"
fi

[ -e $own_dir ] || mkdir $own_dir
echo 'supercognet' | sudo -S rm -f $own_lock

cat << DDD
VARIABLES
-----------
owncloud=$owncloud
own_host=$own_host
own_dir=$own_dir
own_lock=$own_lock
-----------
DDD

sim=1

logTextFinal="$logText, $(echo "$(date +%s%N)/1000000000 - $initialTime" | bc -l), owncloud, "

(
	flock -x -w 10 200 || sim=0

	if [ $sim -eq 0 ]
	then
		printf '%s%s\n' "$logTextFinal" "[~OK]" >> $log
		exit 1
	fi

	#sleep 20
	sleep 5
	num_ops=$(($RANDOM%20))
        #num_ops=0
	for i in `seq $num_ops` 
        do
	  del=$(($RANDOM % 2))
	  if [ $del == 1 ]
	  then
		echo "Create file.."
		filesize=$(($RANDOM))
		base64 /dev/urandom | head -c $filesize > "/home/cognet/$own_dir/$(date +%N)"
	  else
		randfile=$(ls /home/cognet/$own_dir | sort -R | tail -1)
		if [ -z $randfile ]; then
			echo "No files"
		else
			echo "Remove file .."
			rm /home/cognet/$own_dir/$randfile
		fi
	  fi
	  sleep 1
	done
	sleep 5


	#owncloudcmd /home/cognet/mousecloud/ owncloud://mouse:supercognet@172.16.1.10$host/owncloud/remote.php/webdav/ &> /dev/null && result=OK || result=NOK
	#cmd="owncloudcmd --trust /home/cognet/$own_dir/ ${owncloud}://mouse:supercognet@$own_host/owncloud/remote.php/webdav/ $output_cmd  && result=OK || result=NOK"
	cmd="owncloudcmd --trust /home/cognet/$own_dir/ ${owncloud}://mouse:supercognet@$own_host/owncloud/remote.php/webdav/ | tail -10  && result=OK || result=NOK"
	eval $cmd

	logTextFinal="$logText, $(echo "$(date +%s%N)/1000000000 - $initialTime" | bc -l), owncloud, [$result]"
	printf '%s\n' "$logTextFinal"  >> $log


) 200> $own_lock


exit

# -------------------- RESTO NO VALE ------------------------------

if [ $externalRand == 1 ]
then
	sim=1

	logTextFinal="$logText, $(echo "$(date +%s%N)/1000000000 - $initialTime" | bc -l), owncloud, "

	(
		flock -x -w 10 200 || sim=0

		if [ $sim -eq 0 ]
		then
			printf '%s%s\n' "$logTextFinal" "[~OK]" >> $log
			exit 1
		fi

		del=$(($RANDOM % 2))
		#sleep 20
		sleep 5
		if [ $del == 1 ]
		then
			echo "Create file.."
			filesize=$(($RANDOM))
			base64 /dev/urandom | head -c $filesize > "/home/cognet/mousecloud/$(date +%N)"
		else
			randfile=$(ls /home/cognet/mousecloud | sort -R | tail -1)
			if [ -z $randfile ]; then
				echo "No files"
			else
				echo "Remove file .."
				rm /home/cognet/mousecloud/$randfile
			fi
		fi

		#owncloudcmd /home/cognet/mousecloud/ owncloud://mouse:supercognet@172.16.1.10$host/owncloud/remote.php/webdav/ &> /dev/null && result=OK || result=NOK
		#owncloudcmd /home/cognet/mousecloud/ ${owncloud}://mouse:supercognet@172.16.1.10$host/owncloud/remote.php/webdav/ &> /dev/null && result=OK || result=NOK
		owncloudcmd /home/cognet/mousecloud/ ${owncloud}://mouse:supercognet@172.16.1.10$host/owncloud/remote.php/webdav/ $output_cmd  && result=OK || result=NOK
		#result=OK

		logTextFinal="$logText, $(echo "$(date +%s%N)/1000000000 - $initialTime" | bc -l), owncloud, "

		if [ $result == OK ]
		then
		        printf '%s%s\n' "$logTextFinal" "[OK]" >> $log
		else
		        printf '%s%s\n' "$logTextFinal" "[NOK]" >> $log
		fi

	) 200>/var/lock/.CGOwncloudGB.exclusivelock
else
	sim=1

        logTextFinal="$logText, $(echo "$(date +%s%N)/1000000000 - $initialTime" | bc -l), owncloudEx, "

        (
                flock -x -w 10 200 || sim=0

                if [ $sim -eq 0 ]
                then
                        printf '%s%s\n' "$logTextFinal" "[~OK]" >> $log
                        exit 1
                fi

                del=$(($RANDOM % 2))
                #sleep 20
                sleep 5
                if [ $del == 1 ]
                then
			echo "Create file .."
                        filesize=$(($RANDOM))
                        base64 /dev/urandom | head -c $filesize > "/home/cognet/upmcloud/$(date +%N)"
                else
                        randfile=$(ls /home/cognet/upmcloud | sort -R | tail -1)
                        if [ -z $randfile ]; then
                                echo "No files"
                        else
				echo "Remove file .."
                                rm /home/cognet/upmcloud/$randfile
                        fi
                fi

                #owncloudcmd /home/cognet/upmcloud/ owncloud://mouse:supercognet@138.100.156.252/owncloud/remote.php/webdav/ &> /dev/null && result=OK || result=NOK
                owncloudcmd /home/cognet/upmcloud/ ${owncloud}://mouse:supercognet@138.100.156.252/owncloud/remote.php/webdav/ &> /dev/null && result=OK || result=NOK

                logTextFinal="$logText, $(echo "$(date +%s%N)/1000000000 - $initialTime" | bc -l), owncloudEx, "

                if [ $result == OK ]
                then
			printf '%s%s\n' "$logTextFinal" "[OK]" >> $log
                else
                        printf '%s%s\n' "$logTextFinal" "[NOK]" >> $log
                fi

        ) 200>/var/lock/.CGOwncloudGBEX.exclusivelock
fi
