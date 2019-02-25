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
	exit 0
fi


#NETWORK CONFIG
echo "CHANGING NETWORK TO STATIC IP..."
cat ifcfg-enp0s3 > /etc/sysconfig/network-scripts/ifcfg-enp0s3
echo  "REBOOTING NETWORK ADAPTER..."
systemctl restart network 
echo "NEW IP IS 192.168.20.7/30" > server_config


#SSH CONFIG 
#echo "CHANGING SSH PORT..."
sshd_config > /etc/ssh/sshd_config
echo "NEW SSH PORT IS 50683" >> server_config


#SETTING FIREWALL
echo "SETTING FIREWALL..."
echo "IPTABLES CONFIG..."
yum install iptables.services -y > /dev/null
systemctl stop firewalld.service > /dev/null
systemctl disable firewalld.service
sh iptables_config.sh
systemctl enable iptables.service > /dev/null
systemctl restart iptables.service > /dev/null
echo "DONE.."
echo "FAIL2BAN..."
yum install epel-release -y > /dev/null
yum install fail2ban -y > /dev/null
systemctl start fail2ban > /dev/null
systemctl enable fail2ban > /dev/null
echo "DONE..."


#SETTING CRONTAB
echo "SETTING CRONTAB..."
crontab -r
cat root | crontab -
echo "DONE..."


#INSTALLING NGINX
echo "INSTALLING NGINX..."
yum -y install nginx > /dev/null
systemctl start nginx > /dev/null
systemctl enable nginx > /dev/null
echo "DONE..."
#echo "SETTING SSL..."
#mkdir /etc/nginx/ssl
#chmod 700 /etc/nginx/ssl
#mkdir /etc/nginx/ssl/private
#chmod 700 /etc/nginx/ssl/private
#mkdir /etc/nginx/ssl/certs
#chmod 700 /etc/nginx/ssl/certs
#sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/private/nginx-selfsigned.key -out /etc/nginx/ssl/certs/nginx-selfsigned.crt
#openssl dhparam -out /etc/nginx/ssl/certs/dhparam.pem 2048 > /dev/null
#cat nginx.conf > /etc/nginx/nginx.conf
#cat ssl.conf > /etc/nginx/conf.d/ssl.conf
systemctl restart nginx
echo "DONE..."

#FILE MANEGEMENT
#mkdir /root/sys_scripts
#chmod 700 sys_scripts
#mv update_system.sh /root/sys_scripts/
#mv check_cron_changes.sh /root/sys_scripts/
#mv iptables_config.sh /root/sys_scripts/
#mv change_hashsum.sh /root/sys_scripts/
#mv server_config /root
#rm root
echo "SERVER CONFIGURATION COMPLETED"
