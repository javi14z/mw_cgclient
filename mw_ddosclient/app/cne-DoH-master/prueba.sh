#! /bin/bash

#We have to go to the directory where floodoh.py is located
cd /home/cognet/dohpack
rm -r results.txt

#Killing all the tmux process that are running
pkill -f tmux

#Lists of servers
echo List of servers. The default server in the script is the first, you can change for one of these:
echo https://www.aa.net.uk/legal/dohdot-disclaimer/
echo https://alidns.com/
echo https://dns.brahma.world
echo https://www.digitale-gesellschaft.ch
echo https://xtom.com/

#We ask about the connection number and server
echo MW number?
read mwnumber
echo Connection number?
read number
echo Server?
read server

#Launch floodoh.py
##python floodoh.py $number www.nominum.com A $server
##The name of connections can be changed (100,1000,100000...) and you can choose the server dns over https changing the parameter $server

for (( i=1; i<=$mwnumber; i++ ))
do	
	tmux new -s "remote$i" -d
	tmux send-keys -t "remote$i" "python floodoh.py $number www.nominum.com A $server >> results.txt" Enter
done


#tmux new -s "remote1" -d
#tmux send-keys -t "remote1" "python floodoh.py $number www.nominum.com A $server > results.txt" Enter
#tmux new -s "remote2" -d
#tmux send-keys -t "remote2" "python floodoh.py $number www.nominum.com A $server >> results.txt" Enter
#tmux new -s "remote3" -d
#tmux send-keys -t "remote3" "python floodoh.py $number www.nominum.com A $server >> results.txt" Enter
#tmux new -s "remote4" -d
#tmux send-keys -t "remote4" "python floodoh.py $number www.nominum.com A $server >> results.txt" Enter
#tmux new -s "remote5" -d
#tmux send-keys -t "remote5" "python floodoh.py $number www.nominum.com A $server >> results.txt" Enter
