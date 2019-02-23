#CREATING SUDO USER
if [ -n "$1" ]
then
	if adduser hey 2>&1 | grep "Permission denied" > /dev/null
	then
		echo "YOU SHOULD BE ROOT OR SUDO TO RUN THIS SCRIPT"
		exit 0
	fi
	echo  "ADDING NEW USER..."
	echo  "ENTER NEW PASSWORD:"
	passwd $1
	echo  "MAKING HIM SUDO..."
	usermod -aG wheel $1
	echo 	"DONE..."
else
	echo "TYPE THE USER NAME YOU WOULD LIKE TO CREARTE AND ADD TO SUDO GROUP"
fi


#NETWORK CONFIG
echo "CHANGING NETWORK TO STATIC IP..."
ifcfg-enp0s3 > /etc/sysconfig/network-scripts/ifcfg-enp0s3
echo  "REBOOTING NETWORK ADAPTER..."
ifdown	enp0s3
ifup	enp0s3
echo "NEW IP IS 192.168.20.7/30" > server_config


#SSH CONFIG
echo "CHANGING SSH CONFIGURATION..."
sshd_config > /etc/ssh/sshd_config
echo "NEW SSH PORT IS 50683" >> server_config


#SETTING FIREWALL
echo "SETTING FIREWALL..."
echo "IPTABLES CONFIG..."
sh iptables_config.sh
echo "DONE.."
echo "FAIL2BAN..."
yum install epel-release -y > /dev/null
yum install fail2ban -y > /dev/null
systemctl start fail2ban
systemctl enable fail2ban > /dev/null
echo "DONE..."


#SETTING CRONTAB
echo "SETTING CRONTAB..."
crontab -r
cat root | crontab -
echo "DONE..."


#INSTALLING NGINX
echo "INSTALLING NGINX..."
yum -y install nginx
systemctl start nginx
systemctl enable nginx > /dev/null
echo "DONE..."
echo "SETTING SSL..."
mkdir /etc/nginx/ssl
chmod 700
mkdir /etc/nginx/ssl/private
chmod 700
mkdir /etc/nginx/ssl/certs
chmod 700
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/private/nginx-selfsigned.key -out /etc/nginx/ssl/certs/nginx-selfsigned.crt
openssl dhparam -out /etc/nginx/ssl/certs/dhparam.pem 2048 > /dev/null
cat nginx.conf > /etc/nginx/nginx.conf
cat ssl.conf > /etc/nginx/conf.d/ssl.conf
systemctl restart nginx
echo "DONE..."

#FILE MANEGEMENT
mkdir /root/scripts
chmod 700 scripts
mv update_system.sh /root/scripts/
mv check_cron_changes.sh /root/scripts/
mv iptables_config.sh /root/scripts/
mv change_hashsum.sh /root/scripts/
mv server_config /root
rm root
echo "SERVER CONFIGURATION COMPLETED"
