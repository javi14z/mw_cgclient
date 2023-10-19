#!/bin/bash

#Instrucciones de instalacion en: https://github.com/DNSCrypt/dnscrypt-proxy/wiki/Installation-linux

systemctl stop systemd-resolved
systemctl disable systemd-resolved

echo -e "nameserver 127.0.0.1\noptions edns0" > /etc/resolv.conf

/home/cognet/dnscrypt-proxy-linux_x86_64-2.1.5/dnscrypt-proxy -service install
/home/cognet/dnscrypt-proxy-linux_x86_64-2.1.5/dnscrypt-proxy -service start
