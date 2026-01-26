#!/bin/bash

# Network Configuration and Troubleshooting Commands
# Reference: 4_Network_config_&_troubleshooting.md

# ============ Ping ============
# Ensures the destination network or device can be reached

# Ping a domain
ping google.com

# Ping an IP address
ping 8.8.8.8

# Ping with specific count (stop after 4 packets)
ping -c 4 google.com

# ============ NS Lookup ============
# Queries to resolve domain names to IPs and vice versa

# Resolve domain to IP
nslookup google.com

# Resolve IP to domain (reverse lookup)
nslookup 8.8.8.8

# Query specific DNS server
nslookup google.com 8.8.8.8

# ============ Traceroute ============
# Logs each hop the packet visits from source to destination

# Traceroute to domain
traceroute www.google.com

# Traceroute to IP
traceroute 8.8.8.8

# Limit number of hops
traceroute -m 15 google.com

# ============ Host Command ============
# Gets the IP address of a domain

# Resolve domain to IP
host www.google.com

# Verbose output
host -v google.com

# ============ Netstat ============
# Displays routing table and ports info for running processes

# Display all connections
netstat

# Display all listening ports
netstat -l

# Display statistics
netstat -s

# Display network routing table
netstat -r

# Display TCP connections
netstat -t

# Display UDP connections
netstat -u

# Display listening ports with process info
netstat -tulpn

# ============ ARP (Address Resolution Protocol) ============
# Display and modify ARP cache (IP to MAC address mapping)

# Display ARP table
arp

# Display ARP table (alternative format)
arp -a

# Add static ARP entry
sudo arp -s 192.168.1.100 aa:bb:cc:dd:ee:ff

# Delete ARP entry
sudo arp -d 192.168.1.100

# ============ Ifconfig ============
# Sets or displays IP address and netmask of network interface

# Display all network interfaces
ifconfig

# Display specific interface
ifconfig eth0

# Set IP address
sudo ifconfig eth0 192.168.1.100

# Set netmask
sudo ifconfig eth0 netmask 255.255.255.0

# Enable interface
sudo ifconfig eth0 up

# Disable interface
sudo ifconfig eth0 down

# ============ Route ============
# Display and manipulate the routing table

# Display routing table
route

# Display routing table in numeric format
route -n

# Add a route
sudo route add -net 192.168.0.0 netmask 255.255.255.0 gw 192.168.1.1

# Delete a route
sudo route del -net 192.168.0.0 netmask 255.255.255.0

# Add default gateway
sudo route add default gw 192.168.1.1

# ============ IP Command (Modern Alternative) ============

# Display IP addresses
ip addr show

# Display routing table
ip route show

# Add IP address
sudo ip addr add 192.168.1.100/24 dev eth0

# Remove IP address
sudo ip addr del 192.168.1.100/24 dev eth0

# ============ DNS Configuration ============

# View DNS configuration
cat /etc/resolv.conf

# View host entries
cat /etc/hosts

# View name service switch order
cat /etc/nsswitch.conf

echo "Network troubleshooting commands examples completed!"
