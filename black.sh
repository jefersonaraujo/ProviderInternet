#! /bin/bash

for ip in $(cat blacklist);do

#echo $ip
iptables -A INPUT -s $ip -j DROP

done

