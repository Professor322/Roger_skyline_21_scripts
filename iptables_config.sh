#!bin/bash
export IPT="iptables"

#clean all tables
$IPT -t filter -F
$IPT -t nat -F
$IPT -t mangle -F
#delete user chains
$IPT -t filter -X
$IPT -t nat -X
$IPT -t mangle -X
#default settings
$IPT -P INPUT DROP
$IPT -P FORWARD DROP
$IPT -P OUTPUT ACCEPT
#check new connections
$IPT -N new_conn
$IPT -A new_conn -p tcp -m conntrack --ctstate NEW -m limit --limit 42/s --limit-burst 21 -j ACCEPT
$IPT -A new_conn -j DROP
#accept established connections and check new
$IPT -A INPUT -p all -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
$IPT -A INPUT -p all -m conntrack --ctstate NEW -j new_conn
$IPT -A INPUT -p tcp -m connlimit --connlimit-above 10 -j REJECT --reject-with tcp-reset
#open ports
$IPT -A INPUT -p tcp -m conntrack --ctstate NEW -m multiport --dports 50683,80,443  -j ACCEPT
$IPT -A INPUT -p tcp -m multiport --dport 25,110,995,143,993 -j ACCEPT
$IPT -A INPUT -p udp --dport 53 -j ACCEPT
$IPT -A INPUT -m recent --rcheck --seconds 3600 --hitcount 10 --rttl -j RETURN
#prerouting mangle
$IPT -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP
$IPT -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
$IPT -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65000 -j DROP
$IPT -t mangle -A PREROUTING -p icmp -j DROP
#ssh brutforce
$IPT -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --set
$IPT -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 10 -j DROP

/sbin/iptables-save > /etc/sysconfig/iptables
