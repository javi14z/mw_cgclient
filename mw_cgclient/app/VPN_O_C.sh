# /bin/bash
opcion=$1

if [ $opcion = "O" ]
then echo "supercognet" | sudo -S openvpn --config /home/cognet/vpnUPM/client.conf --writepid /home/cognet/openvpn.pid &
elif [ $opcion = "C" ]
then PID=$(cat /home/cognet/openvpn.pid)
echo "supercognet" | sudo -S kill $PID
echo "supercognet" | sudo -S rm /home/cognet/openvpn.pid
else echo "incorrect option"
fi

