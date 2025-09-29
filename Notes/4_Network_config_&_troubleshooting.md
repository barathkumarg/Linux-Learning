## CONTENT

1. [Basic Networking Command](#basic-networking-commandhttpswwwgeeksforgeeksorgnetwork-configuration-trouble-shooting-commands-linux)


## [Basic Networking Command](https://www.geeksforgeeks.org/network-configuration-trouble-shooting-commands-linux/)

### Ping

Ensures the destination network or device can be reached from the current network or device
```commandline
ping google.com
```

Checks whether we can reach the google server

### NS lookup
Queries down the given IP to domain name viceversa
```commandline
nslookup google.com

nslookup 32.144.56.4
```
First command resolves the Domain to IP (public & frontend)

Second command resolves to Domain name

### Traceroute
Logs the each and every hops the packet visit from source to destination in the network

```commandline
traceroute www.google.com
```
logs the each server, routers the packet meets in between source to destination

### Host 
Gets the ip address of the domain
```commandline
host www.google.com
```

### Netstat
Displays the routing table, ports info for the running process in the server
```commandline
netstat
```

### ARP
The ARP (Address Resolution Protocol) command is used to display and modify ARP cache, which contains the mapping of IP address to MAC address. The system’s TCP/IP stack uses ARP in order to determine the MAC address associated with an IP address.
```commandline
arp
```

### ifconfig
The ifconfig(Interface Configuration) is a utility in an operating system that is used to set or display the IP address and netmask of a network interface
```commandline
ifconfig
```

### [Route](https://www.geeksforgeeks.org/what-is-routing/)
The Route Command tool helps us display and manipulate the routing table in Linux.
```commandline
route
```
