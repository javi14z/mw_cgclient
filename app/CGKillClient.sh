#!/bin/bash

echo supercognet | sudo -S killall owncloudcmd
echo supercognet | sudo -S killall python
echo supercognet | sudo -S killall /usr/bin/vlc

for i in $(ps -ef | grep ./CG | grep -v ./CGKillClient | awk '{print $2}'); do kill $i;done
for i in $(ps -ef | grep chrome | awk '{print $2}'); do kill $i;done
for i in $(ps -ef | grep chromium | awk '{print $2}'); do kill $i;done
for i in $(ps -ef | grep chromium-browse | awk '{print $2}'); do kill $i;done
sleep 2

for i in $(ps -ef | grep ./CG | grep -v ./CGKillClient | awk '{print $2}'); do kill $i;done
for i in $(ps -ef | grep chrome | awk '{print $2}'); do kill $i;done
for i in $(ps -ef | grep chromium | awk '{print $2}'); do kill $i;done
for i in $(ps -ef | grep chromium-browse | awk '{print $2}'); do kill $i;done

sleep 2
for i in $(ps -ef | grep ./CG | grep -v ./CGKillClient | awk '{print $2}'); do kill -9 $i;done
for i in $(ps -ef | grep chrome | awk '{print $2}'); do kill -9 $i;done
for i in $(ps -ef | grep chromium | awk '{print $2}'); do kill -9 $i;done
for i in $(ps -ef | grep chromium-browse | awk '{print $2}'); do kill -9 $i;done
sleep 2
for i in $(ps -ef | grep ./CG | grep -v ./CGKillClient | awk '{print $2}'); do kill -9 $i;done
for i in $(ps -ef | grep chrome | awk '{print $2}'); do kill -9 $i;done
for i in $(ps -ef | grep chromium | awk '{print $2}'); do kill -9 $i;done
for i in $(ps -ef | grep chromium-browse | awk '{print $2}'); do kill -9 $i;done
#echo supercognet | sudo -S killall /bin/bash

python dropbox.py stop &
sleep 10
for i in $(ps -ef | grep "dropbox-dist" | awk '{print $2}'); do kill $i; sleep 5; kill $i; sleep 5; kill -9 $i;done
