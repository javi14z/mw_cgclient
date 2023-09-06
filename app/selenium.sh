#!/bin/bash
if [ $# -ne 2 ]
then
  echo "Usage $0 URL_file duration"
  echo "duration 0: web, duration 10: 10 secs of video playing" 
  exit 1
fi

link=$1
duration=$2
echo "Access: $link $duration"

# Genera como salida 
#conex_dom_IP_PID_ini_t:fin_t.txt
#socks_vacios_dom_IP_PID_ini_t:fin_t.txt

r=$RANDOM
net_logs="net_logs.$r.$$"
rm -rf $net_logs
mkdir $net_logs

# OJO!!!!!!!
cd $net_logs

#rm log_performance.*
#rm dom_log_test.txt
#rm socks_vacios.txt
for i in dom_logs net_logs
do
        rm -rf $i
        mkdir $i
done

ini_t=`date +"%s"`
python selenium-test_web_video_alb.py "$link" "$duration" 
fin_t=`date +"%s"`


ip=`hostname -I | awk '{print $1}'`
echo "IP: $ip"
conex=conex_dom_${ip}_$$_${ini_t}:${fin_t}.txt
sockets_vacios=socks_vacios_dom_${ip}_$$_${ini_t}:${fin_t}.txt

#python ~/lee_netlog_selenium-test_video_alb.py net_logs/*  $conex &>/dev/null

echo "DEBUG netlog lee_netlog_selenium-test_video_alb.py " net_logs/* >> debug.netlog
python lee_netlog_selenium-test_video_alb.py net_logs/*  $conex >> debug.netlog
echo "DEBUG END ------------" >> debug.netlog

mv socks_vacios.txt ${sockets_vacios}



