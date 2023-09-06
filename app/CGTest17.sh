#!/bin/bash
cd
echo 'supercognet' | sudo -S rm /var/lock/.CGOwncloudGB.exclusivelock
Xvfb :19 -screen 0 1024x768x16 > /dev/null &
echo $! > display.pid

model=$(head -1 /home/cognet/CGConfig.txt | cut -d ':' -f2) #Model used in the simulation
intervalNum=$(head -2 /home/cognet/CGConfig.txt | tail -1 | cut -d ':' -f2) #Number of intervals in which the experiments consists
testDuration=$(head -3 /home/cognet/CGConfig.txt | tail -1 | cut -d ':' -f2) #Simulation duration
vpn_time=$(head -4 /home/cognet/CGConfig.txt | tail -1 | cut -d ':' -f2) #Time for reseting VPN connections
ratio=$(head -5 /home/cognet/CGConfig.txt | tail -1 | cut -d ':' -f2) #Percentage applied to vpn_time variable resulting vpn_timeout variable
protocolNum=$(head -6 /home/cognet/CGConfig.txt | tail -1 | cut -d ':' -f2) #Number of different protocols used in the simulation
setupNum=$(echo "$(wc -l /home/cognet/CGConfig.txt | cut -d ' ' -f1) - $protocolNum" | bc)
interface="eth0"
declare -A intervals #Array of the number of experiments configured at the CGConfig file. After the reading it contains the time per each experiment of each interval.
declare -A durations #Array of the duration of each experiment ordered by intervals.
declare -A timesNext #Array of the scheduled time for each protocol arranged by the model defined, in this case exponential. [0..5]
declare -A durationsNext #Array of the duration of the experiment of each protocol [0..5]

declare -A logNumberPerProtocol #Array of the number of times a has lauched per interval and protocol.

export DISPLAY=:19

log="d_$(echo $HOSTNAME)_$(date +%s).txt" #Simulation log
echo "Log $(date +'%d-%m-%Y')" > $log
echo "Inverval, Hostname, IP, Protocol, Host, Initial_Time, End_time, URL, Result" >> $log
logFinalTable="d_$(echo $HOSTNAME)_resultTable_$(date +%s).txt" #Simulation log result table
rm -rf dom_logs
mkdir dom_logs
rm -rf net_logs
mkdir net_logs

#echo "#DOM log $(date +'%d-%m-%Y')" > dom_logs/dom_log.txt

#exp="log_exp_$(echo $HOSTNAME).txt" #Experiment's log
#echo "Experiment nº$(echo $log)" > $exp
#echo "C_IP, S_IP, C_PORT, S_PORT, PROTO, FIRST, LAST, LABEL" >> $exp

vpn_semaphore=0 #Initialize VPN semaphore

#Reading CGConfig.txt
for ((i=0; i<$protocolNum; i++))
do
	protocol=$(head -$(($setupNum + 1 + i)) /home/cognet/CGConfig.txt | tail -1 | cut -d '-' -f1)
	for ((j=0; j<$intervalNum; j++))
	do
		intervals[$((intervalNum*i + j))]=$(head -$(($setupNum + 1 + i)) /home/cognet/CGConfig.txt | tail -1 | cut -d '-' -f$((2+j)) | cut -d '(' -f1)
		if [ ${intervals[$((intervalNum*i + j))]} -ne 0 ]
        	then
			intervals[$((intervalNum*i + j))]=$(echo "scale=3; ($testDuration/$intervalNum)/${intervals[$((intervalNum*i + j))]}" | bc)
        	else
                	intervals[$((intervalNum*i + j))]=0 # Redundant
        	fi
		durations[$((intervalNum*i + j))]=$(head -$(($setupNum + 1 + i)) /home/cognet/CGConfig.txt | tail -1 | cut -d '-' -f$((2+j)) | cut -d '(' -f2 | cut -d ')' -f1)
		logNumberPerProtocol[$((intervalNum*i + j))]=0
	done
done

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
			sleep 0
			echo "me estoy abriendo"
		fi
	done

fi
#vpn_timeout=$(echo "scale=2;$(date +%s) + $vpn_time * (1 + $(echo "($RANDOM % (2 * $ratio + 1)) - $ratio" | bc) / 100)" | bc)
#echo "supercognet" | sudo /home/cognet/VPN_O_C.sh O && echo "Se ha abierto la VPN" >> $log && echo "Se ha abierto la VPN" >> $exp
for ((i=0; i<$intervalNum; i++))
do
	initialTime=$(date +%s)
	#Calculating initial times for the interval
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
	menor=${timesNext[0]}
	protocolNext=0
	nextMenor=-1
	protocolNextNext=-1
	echo "Interval $i - Time $initialTime ---------" >> $log
	#(1 day / numer of intervals) cycle
	while [ $(date +%s) -lt $((initialTime + testDuration/intervalNum)) ]
	do
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

		while (( $(echo "$(date +%s) < $menor" | bc) ))
		do
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
							sleep 0
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
                        				sleep 0
							echo "estoy abriendome"
                				fi
        				done
				fi
				#vpn_timeout=$(echo "scale=2;$(date +%s) + $vpn_time * (1 + $(echo "($RANDOM % (2 * $ratio + 1)) - $ratio" | bc) / 100)" | bc)
				#echo "supercognet" | sudo /home/cognet/VPN_O_C.sh C && echo "Se ha cerrado la VPN" >> $log && echo "Se ha cerrado la VPN" >> $exp && echo "supercognet" | sudo /home/cognet/VPN_O_C.sh O && echo "Se ha abierto la VPN" >> $log && echo "Se ha abierto la VPN" >> $exp
			fi
			sleep 0
		done
		if [ $(date +%s) -lt $((initialTime + testDuration/intervalNum)) ]
		then
			if [ $protocolNext == 0 ]
			then #HTTP_LOCAL
				logNumberPerProtocol[$((intervalNum*protocolNext + i))]=$((${logNumberPerProtocol[$((intervalNum*protocolNext + i))]} + 1))
				host=$((($RANDOM % 3) + 1))
				logText="$i, $HOSTNAME, $(echo $(ifconfig $interface) | cut -d ' ' -f7 | cut -d ':' -f2), $protocolNext, $host, $(echo "$menor - $initialTime" | bc -l)"

				if [ ${durations[$((intervalNum*protocolNext + i))]} == X ]
				then
					#duration=$(echo "(-${intervals[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769)" | bc -l) #Randomizing duration
					duration=${intervals[$((intervalNum*protocolNext + i))]}
					/home/cognet/CGApacheRequest.sh "$logText" "$log" "$initialTime" "$duration" "$host" &
					#timesNext[$protocolNext]=$(echo "$menor + ((-${intervals[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769))" | bc -l) #Randomizing duration
					timesNext[$protocolNext]=$(echo "$menor + ${intervals[$((intervalNum*protocolNext + i))]}" | bc)

					durationsNext[$protocolNext]=X
				else
					duration=${durationsNext[$protocolNext]}
                                	/home/cognet/CGApacheRequest.sh "$logText" "$log" "$initialTime" "$duration" "$host" &
					#timesNext[$protocolNext]=$(echo "$menor + ((-${intervals[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769))" | bc -l) #Randomizing duration
					timesNext[$protocolNext]=$(echo "$menor + ${intervals[$((intervalNum*protocolNext + i))]}" | bc)

					#durationsNext[$protocolNext]=$(echo "(-${durations[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769)" | bc -l) #Randomizing duration
					durationsNext[$protocolNext]=${durations[$((intervalNum*protocolNext + i))]}

				fi

				menor=$nextMenor
				protocolNext=$protocolNextNext
				nextMenor=-1
				protocolNextNext=-1
			elif [ $protocolNext == 1 ]
			then #OWNCLOUD
                        	#echo $protocolNext - $menor + $protocolNextNext - $nextMenor
				logNumberPerProtocol[$((intervalNum*protocolNext + i))]=$((${logNumberPerProtocol[$((intervalNum*protocolNext + i))]} + 1))
				host=$((($RANDOM % 3) + 1))
                        	logText="$i, $HOSTNAME, $(echo $(ifconfig $interface) | cut -d ' ' -f7 | cut -d ':' -f2), $protocolNext, $host, $(echo "$menor - $initialTime" | bc -l)"
				#echo "(echo $(ifconfig $interface) | cut -d ' ' -f7 | cut -d ':' -f2) 172.16.1.103 80" >> $exp

                        	if [ ${durations[$((intervalNum*protocolNext + i))]} == X ]
                        	then
                                	#duration=$(echo "(-${intervals[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769)" | bc -l) #Randomizing duration
					duration=${intervals[$((intervalNum*protocolNext + i))]}
                                	/home/cognet/CGOwncloud.sh "$logText" "$log" "$initialTime" "$duration" "$host" &
	                                #timesNext[$protocolNext]=$(echo "$menor + ((-${intervals[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769))" | bc -l) #Randomizing duration
					timesNext[$protocolNext]=$(echo "$menor + ${intervals[$((intervalNum*protocolNext + i))]}" | bc)

	                                durationsNext[$protocolNext]=X
                        	else
	                                duration=${durationsNext[$protocolNext]}
	                                /home/cognet/CGOwncloud.sh "$logText" "$log" "$initialTime" "$duration" "$host" &
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
        	                #echo $protocolNext - $menor + $protocolNextNext - $nextMenor
				logNumberPerProtocol[$((intervalNum*protocolNext + i))]=$((${logNumberPerProtocol[$((intervalNum*protocolNext + i))]} + 1))
                        	host=$((($RANDOM % 3) + 1))
	                        logText="$i, $HOSTNAME, $(echo $(ifconfig $interface) | cut -d ' ' -f7 | cut -d ':' -f2), $protocolNext, $host, $(echo "$menor - $initialTime" | bc -l)"
				#echo "(echo $(ifconfig $interface) | cut -d ' ' -f7 | cut -d ':' -f2) 172.16.1.10$host 8080" >> $exp

                	        if [ ${durations[$((intervalNum*protocolNext + i))]} == X ]
                        	then
	                                #duration=$(echo "(-${intervals[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769)" | bc -l) #Randomizing duration
					duration=${intervals[$((intervalNum*protocolNext + i))]}
                	                /home/cognet/CGCvlc.sh "$logText" "$log" "$initialTime" "$duration" "$host" &
                        	        #timesNext[$protocolNext]=$(echo "$menor + ((-${intervals[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769))" | bc -l) #Randomizing duration
					timesNext[$protocolNext]=$(echo "$menor + ${intervals[$((intervalNum*protocolNext + i))]}" | bc)

	                                durationsNext[$protocolNext]=X
        	                else
                	                duration=${durationsNext[$protocolNext]}
                        	        /home/cognet/CGCvlc.sh "$logText" "$log" "$initialTime" "$duration" "$host" &
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
                	        #echo $protocolNext - $menor + $protocolNextNext - $nextMenor
				logNumberPerProtocol[$((intervalNum*protocolNext + i))]=$((${logNumberPerProtocol[$((intervalNum*protocolNext + i))]} + 1))
	                        host=$((($RANDOM % 3) + 1))
        	                logText="$i, $HOSTNAME, $(echo $(ifconfig $interface) | cut -d ' ' -f7 | cut -d ':' -f2), $protocolNext, $host, $(echo "$menor - $initialTime" | bc -l)"
				#echo "(echo $(ifconfig $interface) | cut -d ' ' -f7 | cut -d ':' -f2) * 443" >> $exp
                        	if [ ${durations[$((intervalNum*protocolNext + i))]} == X ]
	                        then
        	                        #duration=$(echo "(-${intervals[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769)" | bc -l) #Randomizing duration
					duration=${intervals[$((intervalNum*protocolNext + i))]}
                        	        /home/cognet/CGYoutubeRequest.sh "$logText" "$log" "$initialTime" "$duration" "$host" &
                                	#timesNext[$protocolNext]=$(echo "$menor + ((-${intervals[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769))" | bc -l) #Randomizing duration
					timesNext[$protocolNext]=$(echo "$menor + ${intervals[$((intervalNum*protocolNext + i))]}" | bc)

        	                        durationsNext[$protocolNext]=X
	                        else
        	                        duration=${durationsNext[$protocolNext]}
                	                /home/cognet/CGYoutubeRequest.sh "$logText" "$log" "$initialTime" "$duration" "$host" &
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
	                        #echo $protocolNext - $menor + $protocolNextNext - $nextMenor
				logNumberPerProtocol[$((intervalNum*protocolNext + i))]=$((${logNumberPerProtocol[$((intervalNum*protocolNext + i))]} + 1))
				host=$((($RANDOM % 3) + 1))
                        	logText="$i, $HOSTNAME, $(echo $(ifconfig $interface) | cut -d ' ' -f7 | cut -d ':' -f2), $protocolNext, $host, $(echo "$menor - $initialTime" | bc -l)"

	                        if [ ${durations[$((intervalNum*protocolNext + i))]} == X ]
        	                then
					#duration=$(echo "(-${intervals[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769)" | bc -l) #Randomizing duration
					duration=${intervals[$((intervalNum*protocolNext + i))]}
                                	/home/cognet/CGRandomRequest.sh "$logText" "$log" "$initialTime" "$duration" "$host" &
	                                #timesNext[$protocolNext]=$(echo "$menor + ((-${intervals[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769))" | bc -l) #Randomizing duration
					timesNext[$protocolNext]=$(echo "$menor + ${intervals[$((intervalNum*protocolNext + i))]}" | bc)

                	                durationsNext[$protocolNext]=X
                        	else
                                	duration=${durationsNext[$protocolNext]}
	                                /home/cognet/CGRandomRequest.sh "$logText" "$log" "$initialTime" "$duration" "$host" &
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
                	        #echo $protocolNext - $menor + $protocolNextNext - $nextMenor
				logNumberPerProtocol[$((intervalNum*protocolNext + i))]=$((${logNumberPerProtocol[$((intervalNum*protocolNext + i))]} + 1))
				host=$((($RANDOM % 3) + 1))
        	                logText="$i, $HOSTNAME, $(echo $(ifconfig $interface) | cut -d ' ' -f7 | cut -d ':' -f2), $protocolNext, $host, $(echo "$menor - $initialTime" | bc -l)"

	                        if [ ${durations[$((intervalNum*protocolNext + i))]} == X ]
        	                then
					#duration=$(echo "(-${intervals[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769)" | bc -l) #Randomizing duration
					duration=${intervals[$((intervalNum*protocolNext + i))]}
                                	/home/cognet/CGDropbox.sh "$logText" "$log" "$initialTime" "$duration" &
	                                #timesNext[$protocolNext]=$(echo "$menor + ((-${intervals[$((intervalNum*protocolNext + i))]})*l(($RANDOM + 1)/32769))" | bc -l) #Randomizing duration
					timesNext[$protocolNext]=$(echo "$menor + ${intervals[$((intervalNum*protocolNext + i))]}" | bc)

	                                durationsNext[$protocolNext]=X
        	                else
                	                duration=${durationsNext[$protocolNext]}
	                                /home/cognet/CGDropbox.sh "$logText" "$log" "$initialTime" "$duration" &
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
		fi
	done
done

python /home/cognet/dropbox.py stop

while [ $(ps aux | grep "python /home/cognet/selenium" | wc -l) -gt 1 ]
do
	sleep 0
done

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
                        sleep 0
			echo "estoy cerrandome"
                fi
        done
fi

#echo "supercognet" | sudo /home/cognet/VPN_O_C.sh C && echo "Se ha cerrado la VPN" >> $log && echo "Se ha cerrado la VPN" >> $exp

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
