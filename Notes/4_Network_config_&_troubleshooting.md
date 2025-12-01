## CONTENT

1. [Basic Networking Command](#basic-networking-commandhttpswwwgeeksforgeeksorgnetwork-configuration-trouble-shooting-commands-linux)
2. [DNS](dns)
3. [IP Tables](ip-tables)
4. [Cron job](cron-job)

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

## DNS
- The host info stored in `/etc/hosts` file, with IP and name entry
![](../media/Network/dns_1.png)
- Used to resolve the IP dynamically DNS used, it will look upon `/etc/resolv.conf` for resolution

e.g.
```commandline
nameserver <dns server>
```

- First the entry looks on hosts file then resolve file
- The order decided by the file `/etc/nsswitch.conf`, can change the order if required 

- DNS server resolution
![](../media/Network/dns_2.png)

- DNS Search
- ![](../media/Network/dns_3.png)


## IP Tables
iptables is a firewall built into Linux.

It controls what network traffic is allowed in or out of your computer or server.

### To install
```bash
sudo apt install iptables
```

### To check the rules
```commandline
sudo iptables -L
```

The above lists the chain of rules to be followed

```commandline
Chain INPUT - accept the connection/rules be followed

Chain OUTPUT - Control passed to another server 
```

## Applying rules

- To accept the TCP Connection from the client ip

![](../media/Network/iptables-1.png)

- To drop the connection from all other servers

![](../media/Network/iptables-2.png)

- Some examples

![](../media/Network/iptables-3.png)

- To insert the rule on the top use `-I` instead of `-A`


- To Delete
```commandline
iptables -D OUTPUT <rule no>
```

## CRON JOB 

- A scheduler helps to schedule the specific (task/command) to be executed for the defined time

![](../media/Network/cron-1.png)

```commandline
Note: No sudo was recommended to execute via a ron job

      To schedule the job in every interval  - use step value (/)
```

- To inspect the cron job ran successfully check in syslog 
