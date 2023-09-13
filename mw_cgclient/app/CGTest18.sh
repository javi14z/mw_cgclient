#!/bin/bash

# Ojo, cada maquina cliente tiene un fichero de conf diferente copiado antes 
#/home/cgtid/Resto_sh/CGCopyFile_VPN.sh $firstvm_L $lastvm /home/cgtid/CGConfig/CGConfig_HTTP_L.txt CGConfig.txt && echo "All HTTP_L machines configured"
#/home/cgtid/Resto_sh/CGCopyFile_VPN.sh $(($firstvm_L + 1)) $lastvm /home/cgtid/CGConfig/CGConfig_VIDEO_L.txt CGConfig.txt && echo "All VIDEO_L machines configured"
#/home/cgtid/Resto_sh/CGCopyFile_VPN.sh $(($firstvm_L + 2)) $lastvm /home/cgtid/CGConfig/CGConfig_CLOUD_L.txt CGConfig.txt && echo "All CLOUD_L machines configured"

#Ojo, luego quitar
#cd

<<COMMENT
dropbox_activity () {
  echo "Entro en operaciones Dropbox .."
  # Genera operaciones sobre directorio de ficheros
  MAX_CHANGES=5
  rnd=$RANDOM
  num_ops=$(( rnd % MAX_CHANGES))
  #num_ops=0
  for i in `seq $num_ops`
  do
    echo "Dropbox Crear o borrar fichero $i..."
    del=$(($RANDOM % 2))
    if [ $del == 1 ]
    then
          echo "Dropbox Create file.."
          filesize=$(($RANDOM*16))
          #base64 /dev/urandom | head -c $filesize > "/home/cognet/$own_dir/$(date +%N)"
          base64 /dev/urandom | head -c $filesize > "/home/cognet/Dropbox/$(date +%N)"
    else
          randfile=$(ls /home/cognet/Dropbox | sort -R | tail -1)
          if [ -z $randfile ]; then
                  echo "Dropbox No files"
          else
                  echo "Dropbox Remove file .."
                  #rm /home/cognet/$own_dir/$randfile
                  rm /home/cognet/Dropbox/$randfile
          fi
    fi
    sleep 1
  done

  #~/.dropbox-dist/dropboxd &
  #sleep 2
  #python ~/dropbox.py start 
}

duracion_dropbox=$(egrep "^5" /home/cognet/CGConfig.txt | awk -F"[-,(]" '{print $2}')
echo "Es dropbox >0 $duracion_dropbox"
if [ $duracion_dropbox -eq 0 ]
then
  python dropbox.py stop
else
  python dropbox.py start 
fi

COMMENT

echo 'supercognet' | sudo -S rm /var/lock/.CGOwncloudGB.exclusivelock
Xvfb :19 -screen 0 1024x768x16 > /dev/null &
echo $! > display.pid
export DISPLAY=:19

# Instala por si acaso el demonio de dropbox
#python dropbox.py start -i

# Model NO SE USA
model=$(head -1 /home/cognet/CGConfig.txt | cut -d ':' -f2) #Model used in the simulation
# Slots
intervalNum=$(head -2 /home/cognet/CGConfig.txt | tail -1 | cut -d ':' -f2) #Number of intervals in which the experiments consists
# Duration
testDuration=$(head -3 /home/cognet/CGConfig.txt | tail -1 | cut -d ':' -f2) #Simulation duration
# VPNDuration
vpn_time=$(head -4 /home/cognet/CGConfig.txt | tail -1 | cut -d ':' -f2) #Time for reseting VPN connections
# Ratio de la VPN
ratio=$(head -5 /home/cognet/CGConfig.txt | tail -1 | cut -d ':' -f2) #Percentage applied to vpn_time variable resulting vpn_timeout variable
# ProtocolNum
protocolNum=$(head -6 /home/cognet/CGConfig.txt | tail -1 | cut -d ':' -f2) #Number of different protocols used in the simulation

setupNum=$(echo "$(wc -l /home/cognet/CGConfig.txt | cut -d ' ' -f1) - $protocolNum" | bc)
interface="eth0"

MAX_RAND=32767.0

cat >/dev/null <<FIN
Model:Exponential
Slots:1
Duration:60
VPNDuration:0
Ratio:30
ProtocolNum:6
0-30(15)
1-0(0)
2-0(0)
3-0(0)
4-0(0)
5-0(0)
FIN

declare -A intervals #Array of the number of experiments configured at the CGConfig file. After the reading it contains the time per each experiment of each interval.
declare -A durations #Array of the duration of each experiment ordered by intervals.
declare -A timesNext #Array of the scheduled time for each protocol arranged by the model defined, in this case exponential. [0..5]
declare -A durationsNext #Array of the duration of the experiment of each protocol [0..5]

declare -A logNumberPerProtocol #Array of the number of times a has lauched per interval and protocol.

#echo "model $model, intervalNum, $intervalNum, testDuration $testDuration, vpn_time $vpn_time, ration $ratio, protocolNum $protocolNum, setupNum, $setupNum, interface $interface"

rm -rf logs
mkdir logs
log="logs/d_$(echo $HOSTNAME)_$(date +%s).txt" #Simulation log
echo "Log $(date +'%d-%m-%Y')" > $log
echo "Interval, Hostname, IP, Protocol, Host, Initial_Time, End_time, URL, Result" >> $log
logFinalTable="logs/d_$(echo $HOSTNAME)_resultTable_$(date +%s).txt" #Simulation log result table

rm -rf dom_bak
mkdir dom_bak
mv net_logs.* dom_bak
mv conex_dom* dom_bak
mv socks_vacios_dom* dom_bak

fich_cnt_srv="fich_cnt_srv"
cp /dev/null $fich_cnt_srv

cp /dev/null debug.netlog

#echo "#DOM log $(date +'%d-%m-%Y')" > dom_logs/dom_log.txt

#exp="log_exp_$(echo $HOSTNAME).txt" #Experiment's log
#echo "Experiment nº$(echo $log)" > $exp
#echo "C_IP, S_IP, C_PORT, S_PORT, PROTO, FIRST, LAST, LABEL" >> $exp

vpn_semaphore=0 #Initialize VPN semaphore

#Reading CGConfig.txt
for ((i=0; i<$protocolNum; i++))
do
	protocol=$(head -$(($setupNum + 1 + i)) /home/cognet/CGConfig.txt | tail -1 | cut -d '-' -f1)
	echo "protocol: $protocol"
	for ((j=0; j<$intervalNum; j++))
	do
		intervals[$((intervalNum*i + j))]=$(head -$(($setupNum + 1 + i)) /home/cognet/CGConfig.txt | tail -1 | cut -d '-' -f$((2+j)) | cut -d '(' -f1)
		echo ">>> leyendo intervals $(head -$(($setupNum + 1 + i)) /home/cognet/CGConfig.txt | tail -1 | cut -d '-' -f$((2+j)) | cut -d '(' -f1)"
		if [ ${intervals[$((intervalNum*i + j))]} -ne 0 ]
        	then
			intervals[$((intervalNum*i + j))]=$(echo "scale=3; ($testDuration/$intervalNum)/${intervals[$((intervalNum*i + j))]}" | bc)
        	else
                	intervals[$((intervalNum*i + j))]=0 # Redundant
        	fi
		durations[$((intervalNum*i + j))]=$(head -$(($setupNum + 1 + i)) /home/cognet/CGConfig.txt | tail -1 | cut -d '-' -f$((2+j)) | cut -d '(' -f2 | cut -d ')' -f1)
		echo ">>> leyendo durations $(head -$(($setupNum + 1 + i)) /home/cognet/CGConfig.txt | tail -1 | cut -d '-' -f$((2+j)) | cut -d '(' -f2 | cut -d ')' -f1)"
		logNumberPerProtocol[$((intervalNum*i + j))]=0
		echo "logNumberPerProtocol $((intervalNum*i + j))  ${logNumberPerProtocol[$((intervalNum*i + j))]}"
	done
done

echo ">>> INTERVALS: ${intervals[*]}"
echo ">>> durations: ${durations[*]}"
echo ">>> logNumberPerProtocol: ${logNumberPerProtocol[*]}"


#Simulation
if [ $vpn_time -ne 0 ]
then
	vpn_timeout=$(echo "scale=2;$(date +%s) + $vpn_time * (1 + $(echo "($RANDOM % (2 * $ratio + 1)) - $ratio" | bc) / 100)" | bc)
	/home/cognet/VPN_O_C.sh O
	while [ $vpn_semaphore -ne 1 ]
	do
		if [ "$(echo 'supercognet' | sudo -S tail -n1 /var/log/openvpn | cut -d ' ' -f6-)" == "Initialization Sequence Completed" -o "$(echo 'supercognet' | sudo -S tail -n1 /var/log/openvpn | cut -d ' ' -f7-)" == "Initialization Sequence Completed" ]
		then
			vpn_semaphore=1
			echo "VPN O"
		else
			sleep 1
			echo "me estoy abriendo"
		fi
	done

fi

#vpn_timeout=$(echo "scale=2;$(date +%s) + $vpn_time * (1 + $(echo "($RANDOM % (2 * $ratio + 1)) - $ratio" | bc) / 100)" | bc)
#echo "supercognet" | sudo /home/cognet/VPN_O_C.sh O && echo "Se ha abierto la VPN" >> $log && echo "Se ha abierto la VPN" >> $exp


# Lanzamiento de Servicios

cnt_veces=0

#intervalNum -> Slots
for ((i=0; i<$intervalNum; i++))
do
	initialTime=$(date +%s)
	echo "Slot $i - Time $initialTime ---------" >> $log
	echo ">>> Slot $i - Initial_Time $initialTime ---------" 

	#Calculating initial times for the interval
	echo ">>> Calculating timesNext and durationsNext for the slot $i"
	for((j=0; j<$protocolNum; j++))
	do
		if (( $(echo "${intervals[$((intervalNum*j + i))]} != 0" | bc) ))
		then
			#timesNext[$j]=$(echo "$initialTime + ((-${intervals[$((intervalNum*j + i))]})*l(($RANDOM + 1)/32769))" | bc -l) #Randomizing intervals
			#timesNext[$j]=$(echo "$initialTime + ${intervals[$((intervalNum*j + i))]}" | bc)
			timesNext[$j]=$initialTime
                else
                	timesNext[$j]=$((initialTime*2)) #So large jump in time that the experiment will never be launched if the number of experiments is equal to 0
		fi
		if [ ${durations[$((intervalNum*j + i))]} == X ]
		then
			durationsNext[$j]=X
		else
			#durationsNext[$j]=$(echo "(-${durations[$((intervalNum*j + i))]})*l(($RANDOM + 1)/32769)" | bc -l) #Randomizing durations
			durationsNext[$j]=${durations[$((intervalNum*j + i))]}
		fi
	done
	echo ">>> timesNext ${timesNext[*]}"
	echo ">>> durationNext ${durationsNext[*]}"

	menor=${timesNext[0]}
	protocolNext=0
	nextMenor=-1
	protocolNextNext=-1

	#(1 day / numer of intervals) cycle
	while [ $(date +%s) -lt $((initialTime + testDuration/intervalNum)) ]
	do
		echo ">>> Lanzando nuevo ciclo de servicios en segundo: $(date +%s). Tope de tiempo $((initialTime + testDuration/intervalNum)) "
		for((j=0; j<$protocolNum; j++)) #Choose the two earlier executing protocols
        	do
			if (( $(echo "${timesNext[$j]} <= $menor" | bc) ))
			then
				if [ $protocolNext -ne $j ]
				then
					nextMenor=$menor
					protocolNextNext=$protocolNext
					menor=${timesNext[$j]}
					protocolNext=$j
				fi
			elif (( $(echo "${timesNext[$j]} <= $nextMenor" | bc) ))
                        then
				nextMenor=${timesNext[$j]}
				protocolNextNext=$j
			elif (( $(echo "$nextMenor == -1" | bc) ))
			then
				nextMenor=${timesNext[$j]}
				protocolNextNext=$j
			fi
		done
		echo ">>> menor $menor, nextMenor $nextMenor, protocolNext $protocolNext, protocolNextNext $protocolNextNext"
		
		echo ">>> Hora Actual $(date +%s). Esperando llegar a $menor para empezar a lanzar servicio ..."
		while (( $(echo "$(date +%s) < $menor" | bc) ))
		do
			echo ">>> Espero 1seg ...."
			if [ $vpn_time -ne 0 ]
			then
				if [ $(date +%s) -gt $(echo "$vpn_timeout/1" | bc) ]
				then
					vpn_timeout=$(echo "scale=2;$(date +%s) + $vpn_time * (1 + $(echo "($RANDOM % (2 * $ratio + 1)) - $ratio" | bc) / 100)" | bc)
					/home/cognet/VPN_O_C.sh C
					while [ $vpn_semaphore -ne 0 ]
					do
				        	if [ "$(echo 'supercognet' | sudo -S tail -n1 /var/log/openvpn | cut -d ' ' -f6-)" == "SIGTERM[hard,] received, process exiting" -o "$(echo 'supercognet' | sudo -S tail -n1 /var/log/openvpn | cut -d ' ' -f7-)" == "SIGTERM[hard,] received, process exiting" ]
						then
							vpn_semaphore=0
							echo "VPN C"
						else
							sleep 1
							echo "estoy cerrandome"
						fi
					done
					/home/cognet/VPN_O_C.sh O
					while [ $vpn_semaphore -ne 1 ]
        				do
						if [ "$(echo 'supercognet' | sudo -S tail -n1 /var/log/openvpn | cut -d ' ' -f6-)" == "Initialization Sequence Completed" -o "$(echo 'supercognet' | sudo -S tail -n1 /var/log/openvpn | cut -d ' ' -f7-)" == "Initialization Sequence Completed" ]
                				then
                        				vpn_semaphore=1
							echo "VPN O"
                				else
                        				sleep 1
							echo "estoy abriendome"
                				fi
        				done
				fi
				#vpn_timeout=$(echo "scale=2;$(date +%s) + $vpn_time * (1 + $(echo "($RANDOM % (2 * $ratio + 1)) - $ratio" | bc) / 100)" | bc)
				#echo "supercognet" | sudo /home/cognet/VPN_O_C.sh C && echo "Se ha cerrado la VPN" >> $log && echo "Se ha cerrado la VPN" >> $exp && echo "supercognet" | sudo /home/cognet/VPN_O_C.sh O && echo "Se ha abierto la VPN" >> $log && echo "Se ha abierto la VPN" >> $exp
			fi
			sleep 1
		done

		# Factor porcentual de duracion (videos locales y remotos)
		media=$( echo "$MAX_RAND/2"|bc )
		fact_duration=$( echo "1.0 + ( $RANDOM - $media)/$MAX_RAND" | bc -l )
		echo "fact_duration $fact_duration"

		echo ">>> Creando SERVICIO para protocolNext $protocolNext .."
		# SERVICIOS
		if [ $(date +%s) -lt $((initialTime + testDuration/intervalNum)) ]
		then
			echo ">>> indice logNumberPerProtocol $((intervalNum*protocolNext + i))"
			echo ">>> duration en X ${intervals[$((intervalNum*protocolNext + i))]}"
			echo ">>> duration en num =${durationsNext[$protocolNext]}"
			service_start=$(echo "(-${intervals[$protocolNext]})*0.15*l(($RANDOM + 1)/32769)*1000000" | bc -l) 
			echo "service_start $service_start"

			echo ">>>  random duration X $(echo "(-${intervals[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769)" | bc -l) "
			if [ $protocolNext == 0 ]
			then #HTTP_LOCAL
				echo ">>> Ejecutando HTTP_LOCAL"
				logNumberPerProtocol[$((intervalNum*protocolNext + i))]=$((${logNumberPerProtocol[$((intervalNum*protocolNext + i))]} + 1))
				host=$((($RANDOM % 3) + 1))
				logText="$i, $HOSTNAME, $(echo $(ifconfig $interface) | cut -d ' ' -f7 | cut -d ':' -f2), $protocolNext, $host, $(echo "$menor - $initialTime" | bc -l)"

				if [ ${durations[$((intervalNum*protocolNext + i))]} == X ]
				then
					#duration=$(echo "(-${intervals[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769)" | bc -l) #Randomizing duration
					duration=${intervals[$((intervalNum*protocolNext + i))]}
					echo "HTTP_LOCAL" >> $fich_cnt_srv
					(date; /home/cognet/usleep $service_start; date; bash /home/cognet/CGApacheRequest_x.sh  ) &
					#timesNext[$protocolNext]=$(echo "$menor + ((-${intervals[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769))" | bc -l) #Randomizing duration
					timesNext[$protocolNext]=$(echo "$menor + ${intervals[$((intervalNum*protocolNext + i))]}" | bc)

					durationsNext[$protocolNext]=X
				else
					duration=${durationsNext[$protocolNext]}
                                	#/home/cognet/CGApacheRequest.sh "$logText" "$log" "$initialTime" "$duration" "$host" &
					echo "HTTP_LOCAL" >> $fich_cnt_srv
					(date; /home/cognet/usleep $service_start; date; bash /home/cognet/CGApacheRequest_x.sh  ) &
					#timesNext[$protocolNext]=$(echo "$menor + ((-${intervals[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769))" | bc -l) #Randomizing duration
					timesNext[$protocolNext]=$(echo "$menor + ${intervals[$((intervalNum*protocolNext + i))]}" | bc)

					#durationsNext[$protocolNext]=$(echo "(-${durations[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769)" | bc -l) #Randomizing duration
					durationsNext[$protocolNext]=${durations[$((intervalNum*protocolNext + i))]}

				fi
				cnt_veces=$((cnt_veces + 1))
				menor=$nextMenor
				protocolNext=$protocolNextNext
				nextMenor=-1
				protocolNextNext=-1
			elif [ $protocolNext == 1 ]
			then #OWNCLOUD
				echo ">>> Ejecutando OWNCLOUD"
                        	#echo $protocolNext - $menor + $protocolNextNext - $nextMenor
				logNumberPerProtocol[$((intervalNum*protocolNext + i))]=$((${logNumberPerProtocol[$((intervalNum*protocolNext + i))]} + 1))
				host=$((($RANDOM % 3) + 1))
                        	logText="$i, $HOSTNAME, $(echo $(ifconfig $interface) | cut -d ' ' -f7 | cut -d ':' -f2), $protocolNext, $host, $(echo "$menor - $initialTime" | bc -l)"
				#echo "(echo $(ifconfig $interface) | cut -d ' ' -f7 | cut -d ':' -f2) 172.16.1.103 80" >> $exp

                        	if [ ${durations[$((intervalNum*protocolNext + i))]} == X ]
                        	then
                                	#duration=$(echo "(-${intervals[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769)" | bc -l) #Randomizing duration
					duration=${intervals[$((intervalNum*protocolNext + i))]}
                                	#/home/cognet/CGOwncloud.sh "$logText" "$log" "$initialTime" "$duration" "$host" &
					echo "OWNCLOUD_LOCAL" >> $fich_cnt_srv
                                	(date; /home/cognet/usleep $service_start; date; bash /home/cognet/CGOwncloud_x.sh "$logText" "$log" "$initialTime" "$duration" "$host") &
	                                #timesNext[$protocolNext]=$(echo "$menor + ((-${intervals[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769))" | bc -l) #Randomizing duration
					timesNext[$protocolNext]=$(echo "$menor + ${intervals[$((intervalNum*protocolNext + i))]}" | bc)

	                                durationsNext[$protocolNext]=X
                        	else
	                                duration=${durationsNext[$protocolNext]}
	                                #/home/cognet/CGOwncloud.sh "$logText" "$log" "$initialTime" "$duration" "$host" &
					echo "OWNCLOUD_LOCAL" >> $fich_cnt_srv
                                	(date; /home/cognet/usleep $service_start; date; bash /home/cognet/CGOwncloud_x.sh "$logText" "$log" "$initialTime" "$duration" "$host") &
	                                #timesNext[$protocolNext]=$(echo "$menor + ((-${intervals[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769))" | bc -l) #Randomizing duration
					timesNext[$protocolNext]=$(echo "$menor + ${intervals[$((intervalNum*protocolNext + i))]}" | bc)

	                                #durationsNext[$protocolNext]=$(echo "(-${durations[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769)" | bc -l) #Randomizing duration
					durationsNext[$protocolNext]=${durations[$((intervalNum*protocolNext + i))]}

        	                fi

                	        menor=$nextMenor
                        	protocolNext=$protocolNextNext
	                        nextMenor=-1
        	                protocolNextNext=-1
			elif [ $protocolNext == 2 ]
			then #VIDEO LOCAL
				echo ">>> Ejecutando VIDEO_LOCAL"
        	                #echo $protocolNext - $menor + $protocolNextNext - $nextMenor
				logNumberPerProtocol[$((intervalNum*protocolNext + i))]=$((${logNumberPerProtocol[$((intervalNum*protocolNext + i))]} + 1))
                        	host=$((($RANDOM % 3) + 1))
	                        logText="$i, $HOSTNAME, $(echo $(ifconfig $interface) | cut -d ' ' -f7 | cut -d ':' -f2), $protocolNext, $host, $(echo "$menor - $initialTime" | bc -l)"
				#echo "(echo $(ifconfig $interface) | cut -d ' ' -f7 | cut -d ':' -f2) 172.16.1.10$host 8080" >> $exp

                	        if [ ${durations[$((intervalNum*protocolNext + i))]} == X ]
                        	then
	                                #duration=$(echo "(-${intervals[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769)" | bc -l) #Randomizing duration
					duration=${intervals[$((intervalNum*protocolNext + i))]}
					duration=$( echo "$duration * $fact_duration" | bc)

                	                #/home/cognet/CGCvlc.sh "$logText" "$log" "$initialTime" "$duration" "$host" &
					#(date; /home/cognet/usleep $service_start; date; /home/cognet/CGCvlc_x.sh "$logText" "$log" "$initialTime" "$duration" "$host";date ) &
					echo "VIDEO_LOCAL" >> $fich_cnt_srv
					(date; /home/cognet/usleep $service_start; date; bash /home/cognet/CGCvlc_x.sh "$logText" "$log" "$initialTime" "$duration" "$host";date ) &
                        	        #timesNext[$protocolNext]=$(echo "$menor + ((-${intervals[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769))" | bc -l) #Randomizing duration
					timesNext[$protocolNext]=$(echo "$menor + ${intervals[$((intervalNum*protocolNext + i))]}" | bc)

	                                durationsNext[$protocolNext]=X
        	                else
                	                duration=${durationsNext[$protocolNext]}
					duration=$( echo "$duration * $fact_duration" | bc)
                        	        #/home/cognet/CGCvlc.sh "$logText" "$log" "$initialTime" "$duration" "$host" &
					#(date; /home/cognet/usleep $service_start; date; /home/cognet/CGCvlc_x.sh "$logText" "$log" "$initialTime" "$duration" "$host";date ) &
					echo "VIDEO_LOCAL" >> $fich_cnt_srv
					(date; /home/cognet/usleep $service_start; date; bash /home/cognet/CGCvlc_x.sh "$logText" "$log" "$initialTime" "$duration" "$host";date ) &
                                	#timesNext[$protocolNext]=$(echo "$menor + ((-${intervals[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769))" | bc -l) #Randomizing duration
					timesNext[$protocolNext]=$(echo "$menor + ${intervals[$((intervalNum*protocolNext + i))]}" | bc)

	                                #durationsNext[$protocolNext]=$(echo "(-${durations[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769)" | bc -l) #Randomizing duration
					durationsNext[$protocolNext]=${durations[$((intervalNum*protocolNext + i))]}

                	        fi

	                        menor=$nextMenor
        	                protocolNext=$protocolNextNext
                	        nextMenor=-1
                        	protocolNextNext=-1
			elif [ $protocolNext == 3 ]
			then #YOUTUBE
				echo ">>> Ejecutando VIDEO_REMOTO"
                	        #echo $protocolNext - $menor + $protocolNextNext - $nextMenor
				logNumberPerProtocol[$((intervalNum*protocolNext + i))]=$((${logNumberPerProtocol[$((intervalNum*protocolNext + i))]} + 1))
	                        host=$((($RANDOM % 3) + 1))
        	                logText="$i, $HOSTNAME, $(echo $(ifconfig $interface) | cut -d ' ' -f7 | cut -d ':' -f2), $protocolNext, $host, $(echo "$menor - $initialTime" | bc -l)"
				#echo "(echo $(ifconfig $interface) | cut -d ' ' -f7 | cut -d ':' -f2) * 443" >> $exp
                        	if [ ${durations[$((intervalNum*protocolNext + i))]} == X ]
	                        then
        	                        #duration=$(echo "(-${intervals[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769)" | bc -l) #Randomizing duration
					duration=${intervals[$((intervalNum*protocolNext + i))]}
					duration=$( echo "$duration * $fact_duration" | bc)
                        	        #/home/cognet/CGYoutubeRequest.sh "$logText" "$log" "$initialTime" "$duration" "$host" &
					#(date; /home/cognet/usleep $service_start; date; /home/cognet/CGWebVideo_x.sh $duration video_links.txt  ) &
					echo "VIDEO_REMOTO" >> $fich_cnt_srv
					(date; /home/cognet/usleep $service_start; date; bash /home/cognet/CGWebVideo_x.sh $duration video_links.txt  )  &
                                	#timesNext[$protocolNext]=$(echo "$menor + ((-${intervals[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769))" | bc -l) #Randomizing duration
					timesNext[$protocolNext]=$(echo "$menor + ${intervals[$((intervalNum*protocolNext + i))]}" | bc)

        	                        durationsNext[$protocolNext]=X
	                        else
        	                        duration=${durationsNext[$protocolNext]}
					duration=$( echo "$duration * $fact_duration" | bc)
                	                #/home/cognet/CGYoutubeRequest.sh "$logText" "$log" "$initialTime" "$duration" "$host" &
					#(date; /home/cognet/usleep $service_start; date; /home/cognet/CGWebVideo_x.sh $duration video_links.txt  ) &
					echo "VIDEO_REMOTO" >> $fich_cnt_srv
					(date; /home/cognet/usleep $service_start; date; bash /home/cognet/CGWebVideo_x.sh $duration video_links.txt  )  &
                        	        #timesNext[$protocolNext]=$(echo "$menor + ((-${intervals[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769))" | bc -l) #Randomizing duration
					timesNext[$protocolNext]=$(echo "$menor + ${intervals[$((intervalNum*protocolNext + i))]}" | bc)

	                                #durationsNext[$protocolNext]=$(echo "(-${durations[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769)" | bc -l) #Randomizing duration
					durationsNext[$protocolNext]=${durations[$((intervalNum*protocolNext + i))]}

	                        fi

        	                menor=$nextMenor
                	        protocolNext=$protocolNextNext
                        	nextMenor=-1
	                        protocolNextNext=-1
			elif [ $protocolNext == 4 ]
			then #HTTP_REMOTO
				echo ">>> Ejecutando WEB_REMOTO"
	                        #echo $protocolNext - $menor + $protocolNextNext - $nextMenor
				logNumberPerProtocol[$((intervalNum*protocolNext + i))]=$((${logNumberPerProtocol[$((intervalNum*protocolNext + i))]} + 1))
				host=$((($RANDOM % 3) + 1))
                        	logText="$i, $HOSTNAME, $(echo $(ifconfig $interface) | cut -d ' ' -f7 | cut -d ':' -f2), $protocolNext, $host, $(echo "$menor - $initialTime" | bc -l)"

	                        if [ ${durations[$((intervalNum*protocolNext + i))]} == X ]
        	                then
					#duration=$(echo "(-${intervals[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769)" | bc -l) #Randomizing duration
					duration=${intervals[$((intervalNum*protocolNext + i))]}
                                	#/home/cognet/CGRandomRequest.sh "$logText" "$log" "$initialTime" "$duration" "$host" &
					echo "WEB_REMOTO" >> $fich_cnt_srv
					(date; /home/cognet/usleep $service_start; date; bash /home/cognet/CGWebVideo_x.sh 0 web_links.txt  ) &
	                                #timesNext[$protocolNext]=$(echo "$menor + ((-${intervals[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769))" | bc -l) #Randomizing duration
					timesNext[$protocolNext]=$(echo "$menor + ${intervals[$((intervalNum*protocolNext + i))]}" | bc)

                	                durationsNext[$protocolNext]=X
                        	else
                                	duration=${durationsNext[$protocolNext]}
	                                #/home/cognet/CGRandomRequest.sh "$logText" "$log" "$initialTime" "$duration" "$host" &
					echo "WEB_REMOTO" >> $fich_cnt_srv
					(date; /home/cognet/usleep $service_start; date; bash /home/cognet/CGWebVideo_x.sh 0 web_links.txt  ) &
        	                        #timesNext[$protocolNext]=$(echo "$menor + ((-${intervals[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769))" | bc -l) #Randomizing duration
					timesNext[$protocolNext]=$(echo "$menor + ${intervals[$((intervalNum*protocolNext + i))]}" | bc)

	                                #durationsNext[$protocolNext]=$(echo "(-${durations[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769)" | bc -l) #Randomizing duration
					durationsNext[$protocolNext]=${durations[$((intervalNum*protocolNext + i))]}

                	        fi

	                        menor=$nextMenor
        	                protocolNext=$protocolNextNext
                	        nextMenor=-1
                        	protocolNextNext=-1
			elif [ $protocolNext == 5 ]
			then #DROPBOX
				echo ">>> Ejecutando CLOUD_REMOTO"
                	        #echo $protocolNext - $menor + $protocolNextNext - $nextMenor
				logNumberPerProtocol[$((intervalNum*protocolNext + i))]=$((${logNumberPerProtocol[$((intervalNum*protocolNext + i))]} + 1))
				host=$((($RANDOM % 3) + 1))
        	                logText="$i, $HOSTNAME, $(echo $(ifconfig $interface) | cut -d ' ' -f7 | cut -d ':' -f2), $protocolNext, $host, $(echo "$menor - $initialTime" | bc -l)"

	                        if [ ${durations[$((intervalNum*protocolNext + i))]} == X ]
        	                then
					#duration=$(echo "(-${intervals[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769)" | bc -l) #Randomizing duration
					duration=${intervals[$((intervalNum*protocolNext + i))]}
                                	#/home/cognet/CGDropbox.sh "$logText" "$log" "$initialTime" "$duration" &
					#(date; /home/cognet/usleep $service_start; date; bash -l /home/cognet/CGDropbox_x.sh "$logText" "$log" "$initialTime" "$duration" ) &
					echo "DROPBOX_REMOTO" >> $fich_cnt_srv
					(date; /home/cognet/usleep $service_start; date; dropbox_activity )  &
	                                #timesNext[$protocolNext]=$(echo "$menor + ((-${intervals[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769))" | bc -l) #Randomizing duration
					timesNext[$protocolNext]=$(echo "$menor + ${intervals[$((intervalNum*protocolNext + i))]}" | bc)

	                                durationsNext[$protocolNext]=X
        	                else
                	                duration=${durationsNext[$protocolNext]}
	                                #/home/cognet/CGDropbox.sh "$logText" "$log" "$initialTime" "$duration" &
					#(date; /home/cognet/usleep $service_start; date; bash -l /home/cognet/CGDropbox_x.sh "$logText" "$log" "$initialTime" "$duration" ) &
					echo "DROPBOX_REMOTO" >> $fich_cnt_srv
					(date; /home/cognet/usleep $service_start; date; dropbox_activity )  &
        	                        #timesNext[$protocolNext]=$(echo "$menor + ((-${intervals[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769))" | bc -l) #Randomizing duration
					timesNext[$protocolNext]=$(echo "$menor + ${intervals[$((intervalNum*protocolNext + i))]}" | bc)

	                                #durationsNext[$protocolNext]=$(echo "(-${durations[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769)" | bc -l) #Randomizing duration
					durationsNext[$protocolNext]=${durations[$((intervalNum*protocolNext + i))]}

                	        fi

	                        menor=$nextMenor
        	                protocolNext=$protocolNextNext
                	        nextMenor=-1
                        	protocolNextNext=-1
			fi
			#
			#echo "menor $menor, protocolNext $protocolNext, nextMenor $nextMenor, protocolNextNext $protocolNextNext"
		fi
	done
done

echo ">>> cnt_veces $cnt_veces"


while [ $(ps aux | egrep "cognet/selenium|bin/vlc" | wc -l) -gt 1 ]
do
	echo "esperando que finalicen todos los chromium (Video y Web) ..."
	sleep 2
done

#Espero 1 min antes de apagar el dropbox por si hay sincro pendiente
sleep 60
python /home/cognet/dropbox.py stop

#Cierro VPN
if [ $vpn_time -ne 0 ]
then
	#vpn_timeout=$(echo "scale=2;$(date +%s) + $vpn_time * (1 + $(echo "($RANDOM % (2 * $ratio + 1)) - $ratio" | bc) / 100)" | bc)
        /home/cognet/VPN_O_C.sh C
	while [ $vpn_semaphore -ne 0 ]
        do
        	if [ "$(echo 'supercognet' | sudo -S tail -n1 /var/log/openvpn | cut -d ' ' -f6-)" == "SIGTERM[hard,] received, process exiting" -o "$(echo 'supercognet' | sudo -S tail -n1 /var/log/openvpn | cut -d ' ' -f7-)" == "SIGTERM[hard,] received, process exiting" ]
                then
                	vpn_semaphore=0
			echo "VPN C"
                else
                        sleep 1
			echo "estoy cerrandome"
                fi
        done
fi

#echo "supercognet" | sudo /home/cognet/VPN_O_C.sh C && echo "Se ha cerrado la VPN" >> $log && echo "Se ha cerrado la VPN" >> $exp

# Volcado de logs
echo "Results (Protocol\Interval)" >> $logFinalTable
echo "" >> $logFinalTable

for ((i=-1; i<$protocolNum; i++))
do
	resultText=""
	if [ $i -eq -1 ]
	then
		for ((j=0; j<$intervalNum; j++))
	        do
        	        resultText="$resultText\t$j"
        	done
		echo -e "$resultText" >> $logFinalTable
	else
		resultText="$resultText$i"
        	for ((j=0; j<$intervalNum; j++))
	        do
        		resultText="$resultText\t${logNumberPerProtocol[$((intervalNum*i + j))]}"
        	done
		echo -e "$resultText" >> $logFinalTable
	fi
done


PID_VIDEO=$(cat /home/cognet/display.pid)
echo "supercognet" | sudo -S kill $PID_VIDEO
echo "supercognet" | sudo -S rm /home/cognet/display.pid
