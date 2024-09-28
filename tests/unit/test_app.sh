#!/bin/bash

#FNR (File Number Record) is the current record number in the current input file. (>=) is "greater than equal" to the line number. 
public_ip=$(host myip.opendns.com resolver1.opendns.com | awk 'FNR>=6 {print $4}')

url="${public_ip}:5000"

#The (-c 1) option specifies that only one packet should be sent
#(-F'*') defines a new field separator in awk. Any value(s) before the the first occurence of the separator will be $1
#(awk -F'time=| ') splits the line by both time= ('time=...') and spaces ('...| ')
net_millisec=$(ping -c 1 google.com | awk -F'time=' 'FNR==2 {print $2}' | awk '{print $1}')
net_packet=$(ping -c 1 "$url" | awk 'FNR==5 {print $6}')


#Checking if net_millisec is not equal(-ne) to 0 (indicating a response time)
#Checking if the net_packet is not-empty (-n)
if [[ $net_millisec -ne 0 && -n $net_packet ]]
then
	echo $'\n'"It took "$net_millisec"ms to reach $url and there was $net_packet data packet loss."
else 
	echo $'\n'"Your website can not be reached. Check your configuration."
fi
