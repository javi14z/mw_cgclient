#!/bin/bash


if [ $# -ne 2 ]
then
  echo "Usage $0  duration URL_file"
  echo "duration 0: web, duration 10: 10 secs of video playing" 
  exit 1
fi

procs=$(ps -ef | grep chromium | grep -v "defunct" | wc -l )
if [ "$procs" -gt 15 ]
then
        # Too many processes
        echo "Too many chromium processes: $procs"
        exit 1
else
        echo "Chromium processes: $procs"
fi


duration=$1
link_file=$2

# Genera como salida 
#conex_dom_IP_PID_ini_t:fin_t.txt
#socks_vacios_dom_IP_PID_ini_t:fin_t.txt

#LINEAS=$(wc -l ./links.txt | cut -d ' ' -f1)
LINEAS=$(wc -l ${link_file} | cut -d ' ' -f1)
SELECTION=$((${RANDOM} % $LINEAS + 1))
#LINK=$(sed "${SELECTION}q;d" ./links.txt)
link=$(sed "${SELECTION}q;d" ${link_file})

#Convert to int
duration=$( echo "($duration+0.5)/1" | bc  )

if [ $duration -eq 0 ]
then
  service="web"
else
  service="video"
fi

if [ "$sevice" != "video" ]
then
	Xvfb :19 -screen 0 1024x768x16 > /dev/null &
	export DISPLAY=:19
else
	Xvfb :99 -screen 0 1024x768x16  &
	export DISPLAY=:99
fi

#debug
cat <<FIN >/dev/null
LINK="https://youtu.be/HqcQvetKvwg?list=RDHqcQvetKvwg"
LINK="https://www.youtube.com/watch?v=JyfeBHAfpZQ"
LINK="https://youtu.be/JyfeBHAfpZQ"
LINK="https://www.etsisi.upm.es"
LINK=https://youtu.be/HVedKwYov8I
LINK="https://www.elpais.com"
FIN

#bash -xv  ./selenium.sh $link $duration
echo ">>>>>bash  ./selenium.sh $link $duration"
bash  ./selenium.sh $link $duration


