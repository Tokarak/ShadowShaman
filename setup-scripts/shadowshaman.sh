#!/bin/sh

# This script is aimed to work on AsusWRT-Merlin
# Please install ShadowSockets-libev as a dependency
echo "SHADOWSHAMAN – Please report issues and/or contribute in:\nhttps://github.com/Tokarak/ShadowShaman"
if [[ $EUID > 0 ]] # checks for root
  then echo "Please run as root"
  exit
fi

clear
ip=$(curl icanhazip.com)
echo -e $"\e[32mWhich IP? (server=?)\n1) $ip (recommended for connection from WAN)\n2) Local or custom IP (e.g 192.168.0.1)"
read local

if [ "$local" == "1" ] ; then
    : # ip already obtained
elif [ "$local" == "2" ] ; then
	echo -e $"\e[32mWhat is your Local IP?\e[39m"
	read ip
else
    echo -e $"\e[31mWrong input! Exiting.\e[39m"
    exit 1
fi

echo -e $"\e[32mEnter your port. Default \e[31m443\e[39m (enter)"
read port
if [ "$port" == "" ] ; then
    port=443
elif [ "$port" -gt "65535" ] ; then
    echo -e $"\e[31mPort can't be larger than 65535! Exiting\e[39m"
    exit 1
elif [ "$port" == "22" ] ; then
    echo -e $"\e[31mCan't use SSH port! Exiting\e[39m"
    exit 1
fi

echo -e $"\e[32mWhich encryption?\n1) chacha20-ietf-poly1305 (fastest)\n2) xchacha20-ietf-poly1305 (fastest/recommended - ubuntu 18 only!)\n3) chacha20-ietf\n4) chacha20\n5) aes-256-cfb (good standard encryption)\n6) aes-256-gcm\n7) aes-256-ctr\n8) custom method value"
read mtd
if [ "$mtd" == "1" ] ; then
    method=chacha20-ietf-poly1305
elif [ "$mtd" == "2" ] ; then
	method=xchacha20-ietf-poly1305
elif [ "$mtd" == "3" ] ; then
	method=chacha20-ietf
elif [ "$mtd" == "4" ] ; then
	method=chacha20
elif [ "$mtd" == "5" ] ; then
	method=aes-256-cfb
elif [ "$mtd" == "6" ] ; then
	method=aes-256-gcm
elif [ "$mtd" == "7" ] ; then
	method=aes-256-ctr
elif [ "$mtd" == "8" ] ; then
  echo "\e[32Please enter method string:"
  read method
else
    echo -e $"\e[31mWrong input! Exiting.\e[39m"
    exit 1
fi

echo -e $"\e[32mYour password?\e[39m"
read password
echo
echo "Creating helper scripts in /usr/bin ..."
cd /usr/bin
SS="shadowsocks-start"
touch $SS

cat <<EOM >$SS
#!/bin/sh
# shadowshaman start script
ss-server -p $port -s $ip -k $password -m $method -f /etc/ss-server.pid
EOM

SStop="shadowsocks-stop"
/bin/cat <<EOM >$SStop
#!/bin/sh
# shadowshaman stop script
kill -9 $(cat /etc/sss.pid)
EOM

chmod 755 shadowsocks-start
chmod 755 shadowsocks-stop

shadowsocks-start

url="ss://$(echo -n "$method:$password@$ip:$port" | base64)"

clear
echo -e "===================Shadowshaman=0.1e==================="
echo -e "\nShadowsocks started! \e[32m$ip:$port\e[39m.\n"
echo -e "Helper scripts created: /usr/bin/shadowsocks-start and ***-stop\n"
echo -e "Want to modify the config again? Either rerun the script, or manually edit /usr/bin/shadowsocks-start."
echo -e "\nYour URI:\n\e[32m$url\e[39m"
echo -e "Working with shadowsocks windows client and Outline!"
echo -e "\nRun \e[31mshadowsocks-stop \e[39mto stop.\n"
echo -e "You need to manually restart shadowshaman after reboot.\n"
echo -e "(Tip: use a cronjob.)\n"
echo -e "================original script by AYMJND==============\n"
echo -e "===================updated by Tokarak=================="
