#!/bin/bash

# IPTables Firewall Configuration
# Reference: 4_Network_config_&_troubleshooting.md

# IPTables is a firewall built into Linux
# Controls what network traffic is allowed in or out

# ============ Installation ============

# Install iptables on Debian/Ubuntu
sudo apt install iptables

# Install iptables on CentOS/RHEL
sudo yum install iptables

# ============ Basic Commands ============

# View all rules
sudo iptables -L

# View all rules with line numbers
sudo iptables -L -n --line-numbers

# View INPUT chain rules
sudo iptables -L INPUT -n

# View OUTPUT chain rules
sudo iptables -L OUTPUT -n

# View FORWARD chain rules
sudo iptables -L FORWARD -n

# ============ Add Rules (Append) ============

# Accept TCP connections from specific IP
sudo iptables -A INPUT -p tcp -s 192.168.1.100 -j ACCEPT

# Accept SSH connections (port 22)
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Accept HTTP connections (port 80)
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Accept HTTPS connections (port 443)
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Drop connections from specific IP
sudo iptables -A INPUT -p tcp -s 192.168.1.50 -j DROP

# Accept established connections
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# ============ Insert Rules (Insert at Top) ============

# Insert rule at the beginning (use -I instead of -A)
sudo iptables -I INPUT -p tcp -s 192.168.1.100 -j ACCEPT

# Insert rule at specific position
sudo iptables -I INPUT 1 -p tcp --dport 22 -j ACCEPT

# ============ Delete Rules ============

# Delete rule from OUTPUT chain (by number)
sudo iptables -D OUTPUT 1

# Delete specific rule
sudo iptables -D INPUT -p tcp -s 192.168.1.50 -j DROP

# Flush all rules in INPUT chain
sudo iptables -F INPUT

# Flush all rules
sudo iptables -F

# ============ Set Default Policy ============

# Set default INPUT policy to DROP
sudo iptables -P INPUT DROP

# Set default OUTPUT policy to ACCEPT
sudo iptables -P OUTPUT ACCEPT

# Set default FORWARD policy to DROP
sudo iptables -P FORWARD DROP

# ============ Common Rule Examples ============

# Allow loopback traffic
sudo iptables -A INPUT -i lo -j ACCEPT

# Allow ping (ICMP)
sudo iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

# Allow specific port range
sudo iptables -A INPUT -p tcp --dport 8000:9000 -j ACCEPT

# Allow UDP DNS (port 53)
sudo iptables -A INPUT -p udp --dport 53 -j ACCEPT

# ============ Save and Restore Rules ============

# Save rules to file
sudo iptables-save > /etc/iptables/rules.v4

# Restore rules from file
sudo iptables-restore < /etc/iptables/rules.v4

# Make rules persistent (Debian/Ubuntu)
sudo apt install iptables-persistent

# For persistence, edit /etc/iptables/rules.v4

# ============ Chain Management ============

# Create custom chain
sudo iptables -N CUSTOM_CHAIN

# Delete custom chain
sudo iptables -X CUSTOM_CHAIN

# Rename chain (not directly supported, create new and migrate)

# ============ Advanced Rules ============

# Allow traffic from specific source to specific destination
sudo iptables -A INPUT -p tcp -s 192.168.1.100 -d 192.168.1.1 --dport 22 -j ACCEPT

# Log dropped packets
sudo iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "Dropped: "

# Match by MAC address
sudo iptables -A INPUT -m mac --mac-source 00:11:22:33:44:55 -j ACCEPT

# Match by state
sudo iptables -A INPUT -m state --state NEW,ESTABLISHED -j ACCEPT

# ============ NAT (Network Address Translation) ============

# Enable port forwarding
sudo iptables -t nat -A PREROUTING -p tcp --dport 8080 -j REDIRECT --to-port 80

# Masquerade outgoing packets
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

echo "IPTables firewall examples completed!"
