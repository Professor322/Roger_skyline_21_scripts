RED='\033[0;31m'         #  ${RED}
GREEN='\033[0;32m'      #  ${GREEN}
GRAY='\033[0;37m'       #  ${GRAY}  
CYAN='\033[0;36m'       #  ${CYAN}

#CREATING SUDO USER
if [ -n "$1" ]
then
	if adduser hey 2>&1 | grep "Permission denied" > /dev/null
	then
		printf "${RED}YOU SHOULD BE ROOT OR SUDO TO RUN THIS SCRIPT${GRAY}\n"
		exit 0
	fi
	printf  "ADDING NEW USER...\n"
	printf  "ENTER NEW PASSWORD:"
	passwd $1 2> /dev/null
	printf  "MAKING HIM SUDO...\n"
	usermod -aG wheel $1
	printf 	" ${GREEN}DONE...${GRAY}\n\n"
else
	printf "${RED}TYPE THE USER NAME YOU WOULD LIKE TO CREATE AND ADD TO SUDO GROUP${GRAY}\n"
	exit 0
fi


#NETWORK CONFIG
printf "CHANGING NETWORK TO STATIC IP...\n"
cat ifcfg-enp0s3 > /etc/sysconfig/network-scripts/ifcfg-enp0s3
printf  "REBOOTING NETWORK ADAPTER...\n"
systemctl restart network 
printf "NEW IP IS $(cat ifcfg-enp0s3 | grep IPADDR | awk -F '=' '{print $2}')\n" > server_config
printf "MASK IS $(cat ifcfg-enp0s3 | grep MASK | awk -F '=' '{print $2}')\n" >> server_config
printf "${GREEN}DONE...${GRAY}\n\n"


#SSH CONFIG 
printf "CHANGING SSH PORT...\n"
sshd_config > /etc/ssh/sshd_config
printf "NEW SSH PORT IS 50683\n" >> server_config
printf "${GREEN}DONE...${GRAY}\n\n"


#SETTING FIREWALL
printf "SETTING FIREWALL...\n"
printf "IPTABLES CONFIG...\n"
yum install iptables.services -y > /dev/null
systemctl stop firewalld.service > /dev/null
systemctl disable firewalld.service > /dev/null
sh iptables_config.sh
systemctl enable iptables.service > /dev/null
systemctl restart iptables.service > /dev/null
printf "${GREEN}DONE..${GRAY}\n\n"
printf "FAIL2BAN...\n"
yum install epel-release -y > /dev/null
yum install fail2ban -y > /dev/null
systemctl enable fail2ban > /dev/null
printf "${GREEN}DONE...${GRAY}\n\n"


#SETTING CRONTAB
printf "SETTING CRONTAB...\n"
crontab -r
cat root | crontab - > /dev/null
printf "${GREEN}DONE...${GRAY}\n\n"


#INSTALLING NGINX
printf "INSTALLING NGINX...\n"
yum -y install nginx > /dev/null
systemctl start nginx > /dev/null
systemctl enable nginx > /dev/null
printf "${GREEN}DONE...${GRAY}\n\n"
printf "SETTING SSL...\n"
mkdir /etc/nginx/ssl
chmod 700 /etc/nginx/ssl
mkdir /etc/nginx/ssl/private
chmod 700 /etc/nginx/ssl/private
mkdir /etc/nginx/ssl/certs
chmod 700 /etc/nginx/ssl/certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/private/nginx-selfsigned.key -out /etc/nginx/ssl/certs/nginx-selfsigned.crt
printf "DHPARAM KEY...\n"
openssl dhparam -out /etc/nginx/ssl/certs/dhparam.pem 2048 2> /dev/null
cat nginx.conf > /etc/nginx/nginx.conf
cat ssl.conf > /etc/nginx/conf.d/ssl.conf
systemctl restart nginx
printf "${GREEN}DONE...${GRAY}\n\n"

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
printf "${CYAN}SERVER CONFIGURATION IS COMPLETED${GRAY}\n\n"
