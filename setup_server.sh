RED='\033[0;31m'         #  ${RED}
GREEN='\033[0;32m'      #  ${GREEN}
GRAY='\033[0;37m'       #  ${GRAY}  
CYAN='\033[0;36m'       #  ${CYAN}

#CREATING SUDO USER
if [ -n "$1" ]
then
	if adduser hey 2>&1 | grep "Permission denied" > /dev/null
	then
		echo "${RED}YOU SHOULD BE ROOT OR SUDO TO RUN THIS SCRIPT${GRAY}"
		exit 0
	fi
	echo  "ADDING NEW USER..."
	echo  "ENTER NEW PASSWORD:"
	passwd $1 2> /dev/null
	echo  "MAKING HIM SUDO..."
	usermod -aG wheel $1
	echo 	" ${GREEN}DONE...${GRAY}"
else
	echo "${RED}TYPE THE USER NAME YOU WOULD LIKE TO CREATE AND ADD TO SUDO GROUP${GRAY}"
	exit 0
fi


#NETWORK CONFIG
echo "CHANGING NETWORK TO STATIC IP..."
cat ifcfg-enp0s3 > /etc/sysconfig/network-scripts/ifcfg-enp0s3
echo  "REBOOTING NETWORK ADAPTER..."
systemctl restart network 
echo "NEW IP IS $(cat ifcfg-enp0s3 | grep IPADDR | awk -F '=' '{print $2}')" > server_config
echo "MASK IS $(cat ifcfg-enp0s3 | grep MASK | awk -F '=' '{print $2}')" >> server_config
echo "${GREEN}DONE...${GRAY}"


#SSH CONFIG 
echo "CHANGING SSH PORT..."
sshd_config > /etc/ssh/sshd_config
echo "NEW SSH PORT IS 50683" >> server_config
echo "${GREEN}DONE...${GRAY}"


#SETTING FIREWALL
echo "SETTING FIREWALL..."
echo "IPTABLES CONFIG..."
yum install iptables.services -y > /dev/null
systemctl stop firewalld.service > /dev/null
systemctl disable firewalld.service > /dev/null
sh iptables_config.sh
systemctl enable iptables.service > /dev/null
systemctl restart iptables.service > /dev/null
echo "${GREEN}DONE..${GRAY}"
echo "FAIL2BAN..."
yum install epel-release -y > /dev/null
yum install fail2ban -y > /dev/null
systemctl enable fail2ban > /dev/null
echo "${GREEN}DONE...${GRAY}"


#SETTING CRONTAB
echo "SETTING CRONTAB..."
crontab -r
cat root | crontab - > /dev/null
echo "${GREEN}DONE...${GRAY}"


#INSTALLING NGINX
echo "INSTALLING NGINX..."
yum -y install nginx > /dev/null
systemctl start nginx > /dev/null
systemctl enable nginx > /dev/null
echo "${GREEN}DONE...${GRAY}"
echo "SETTING SSL..."
mkdir /etc/nginx/ssl
chmod 700 /etc/nginx/ssl
mkdir /etc/nginx/ssl/private
chmod 700 /etc/nginx/ssl/private
mkdir /etc/nginx/ssl/certs
chmod 700 /etc/nginx/ssl/certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/private/nginx-selfsigned.key -out /etc/nginx/ssl/certs/nginx-selfsigned.crt
echo "DHPARAM KEY..."
openssl dhparam -out /etc/nginx/ssl/certs/dhparam.pem 2048 2> /dev/null
cat nginx.conf > /etc/nginx/nginx.conf
cat ssl.conf > /etc/nginx/conf.d/ssl.conf
systemctl restart nginx
echo "${GREEN}DONE...${GRAY}"

#FILE MANEGEMENT
mkdir /root/sys_scripts
mkdir /root/config_files
chmod 700 /root/config_files
chmod 700 /root/sys_scripts
mv ifcfg-enp0s3 /root/config_files/
mv nginx.conf /root/config_files/
mv sshd_config /root/config_files/
mv ssl.conf /root/config_files/
mv update_system.sh /root/sys_scripts/
mv check_cron_changes.sh /root/sys_scripts/
mv iptables_config.sh /root/sys_scripts/
mv change_hashsum.sh /root/sys_scripts/
mv server_config /root
rm root
echo "${CYAN}SERVER CONFIGURATION COMPLETED${GRAY}"
