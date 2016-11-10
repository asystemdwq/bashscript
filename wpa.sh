#!/bin/bash
sodo -s
echo "Welcom to MW's Clonezilla Live, You need to Input your username & password to connect the WIFI."
echo -n "Enter your username:"
read name
echo -n "OK, now let's enter your password:"
read passwd
echo "Welcome $name come to MW's Clonezilla"
if [ -f /etc/wpa_config.conf ]; then
	rm -r -f /etc/wpa_config.conf
fi
touch /etc/wpa_config.conf
echo "ctrl_interface=/var/run/wpa_supplicant" >> /etc/wpa_config.conf
echo "network={" >> /etc/wpa_config.conf
echo "ssid=\"RSP-EE\"" >> /etc/wpa_config.conf
echo "key_mgmt=WPA-EAP" >> /etc/wpa_config.conf
echo "phase2=\"auth=MSCHAPV2\"" >> /etc/wpa_config.conf
echo "identity=\"$name\"" >> /etc/wpa_config.conf
echo "password=\"$passwd\"" >> /etc/wpa_config.conf
echo "}" >> /etc/wpa_config.conf
wpa_supplicant -c /etc/wpa_config.conf -i wlan0 -u -f /var/log/wap.log -P /var/run/wpa.pid &
ifconfig wlan0 up
dhclient wlan0
clonezilla

