#!/bin/bash

# Install iptables
apt -y install iptables

# Install iptables-persistent
apt -y install iptables-persistent
systemctl enable netfilter-persistent

# Flush/Delete firewall rules
iptables -F
iptables -X
iptables -Z

# Βlock null packets (DoS)
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

# Block syn-flood attacks (DoS)
iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP

# Block XMAS packets (DoS)
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP

# Allow internal traffic on the loopback device
iptables -A INPUT -i lo -j ACCEPT

# Allow ssh access
iptables -A INPUT -p tcp -m tcp --dport 62111 -j ACCEPT

# Allow established connections
iptables -I INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
  
# Allow outgoing connections
iptables -P OUTPUT ACCEPT
  
# Set default deny firewall policy
iptables -P INPUT DROP

# Import the bad ip database to block the bad ip addresses.

_input=/bin/lib/sh/MK3S/data/badips.db
IPT=/sbin/iptables
$IPT -N droplist
egrep -v "^#|^$" x | while IFS= read -r ip
do
	$IPT -A droplist -i eth1 -s $ip -j LOG --log-prefix " Taloss IP BlockList  "
	$IPT -A droplist -i eth1 -s $ip -j DROP
done < "$_input"
# Drop it 
$IPT -I INPUT -j droplist
$IPT -I OUTPUT -j droplist
$IPT -I FORWARD -j droplist

# Save rules
iptables-save > /etc/iptables/rules.v4