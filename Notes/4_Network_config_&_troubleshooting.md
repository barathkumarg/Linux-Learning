## CONTENT

1. [Basic Networking Command](#basic-networking-commandhttpswwwgeeksforgeeksorgnetwork-configuration-trouble-shooting-commands-linux)
2. [DNS](dns)
3. [IP Tables](ip-tables)
4. [Cron job](cron-job)
5. [SSL]

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

A scheduler helps to schedule specific tasks/commands to be executed at defined times. There are three main job schedulers in Linux:

### **1. CRON - Run on Minutes and Hours**

**Purpose:** Repeating jobs at regular intervals (runs every minute if configured)

**Granularity:** Minute, Hour, Day, Month, Day of Week

**When to use:** 
- Recurring tasks (backups, cleanup, monitoring)
- Tasks that run frequently (multiple times per day/hour/minute)

**Configuration File:** `/etc/crontab` (system-wide) or user crontab (individual)

#### Basic Syntax:
```
Minute  Hour  Day  Month  DayOfWeek  User  Command
  0-59   0-23  1-31  1-12    0-6      name  /path/to/command
  (Sun=0)
```

**Example:** Run backup every day at 6:35 AM
```
35 6 * * * root /usr/bin/backup.sh
```

**Breakdown:**
- `35` = 35th minute (6:35 AM)
- `6` = 6th hour (6 AM)
- `*` = Every day
- `*` = Every month
- `*` = Every day of week
- `root` = Run as root user
- `/usr/bin/backup.sh` = Command to execute

#### Crontab Management Commands:

**View cron jobs:**
```bash
crontab -l              # View current user's cron jobs
crontab -l -u username # View specific user's cron jobs (root only)
```

**Edit cron jobs:**
```bash
crontab -e              # Edit current user's crontab
crontab -e -u username # Edit specific user's crontab (root only)
EDITOR=nano crontab -e  # Use specific editor
```

**Display usage:**
```bash
cat /etc/crontab        # View system-wide crontab
less /etc/cron.d/       # View all system cron jobs
```

**Remove cron jobs:**
```bash
crontab -r              # Remove all current user's jobs
crontab -r -u username # Remove all jobs for specific user
```

#### Cron Job Syntax Examples:

| Requirement | Syntax | Example |
|---|---|---|
| Every 15 minutes | `*/15 * * * *` | `*/15 * * * * /path/to/script.sh` |
| Every hour | `0 * * * *` | `0 * * * * /path/to/script.sh` |
| Every day at 2:30 AM | `30 2 * * *` | `30 2 * * * /path/to/script.sh` |
| Every Monday at 9:00 AM | `0 9 * * 1` | `0 9 * * 1 /path/to/script.sh` |
| Every 1st of month | `0 0 1 * *` | `0 0 1 * * root /path/to/script.sh` |
| Weekdays (Mon-Fri) at 5 PM | `0 17 * * 1-5` | `0 17 * * 1-5 /path/to/backup.sh` |
| Multiple times: 1 AM & 1 PM | `0 1,13 * * *` | `0 1,13 * * * /path/to/script.sh` |

#### Step Values (/) Examples:
- `*/5` = Every 5 units
- `*/2 * * * *` = Every 2 hours
- `*/3` in day field = Every 3 days

#### Production Usage Pattern:

**1. Create a backup script:** `/usr/local/bin/backup.sh`
```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
tar czf /backups/app_backup_$DATE.tar.gz /var/app/data
find /backups -name 'app_backup_*.tar.gz' -mtime +7 -delete  # Keep 7 days
```

**2. Set up crontab for specific user:**
```bash
sudo crontab -e -u appuser
```

**3. Add the job (runs daily at 2 AM):**
```
0 2 * * * /usr/local/bin/backup.sh >> /var/log/backup.log 2>&1
```

**4. Monitor logs:**
```bash
tail -f /var/log/backup.log
journalctl -u cron      # Check systemd logs
```

#### Important Notes:
```
⚠️  Never use sudo inside crontab - set cron to run as appropriate user
📝  No sudo was recommended to execute via a cron job directly
🔍  To inspect cron jobs that ran successfully, check syslog:
    /var/log/syslog or /var/log/cron or journalctl
🔄  Use step value (/) to schedule jobs at regular intervals
```

---

### **2. ANACRON - Run on Days, Weeks, Months, and Years**

**Purpose:** Repeating jobs based on days/weeks/months/years (not time-based)

**Granularity:** Day, Week, Month, Year

**When to use:** 
- Laptop/desktop maintenance (may not be always on)
- Non-critical background tasks that don't need exact time
- Tasks that should run even if system was powered off during scheduled time

**Key Difference from Cron:** 
- Cron skips jobs if system is off at scheduled time
- Anacron runs skipped jobs as soon as system boots up

**Configuration File:** `/etc/anacrontab` or `/etc/cron.d/`

#### Anacron Syntax:
```
Period Delay JobID Command
  1    10    id   /path/to/command
```

- `Period` = Interval in days (1, 7, 30, 365)
- `Delay` = Minutes to wait after boot before running
- `JobID` = Unique job identifier
- `Command` = Command to execute

#### Anacron Examples:

**1. Run daily:**
```
1 0 daily_backup /usr/bin/backup.sh
```
Runs every day with 0 minutes delay after boot

**2. Run weekly:**
```
7 10 weekly_maintenance /usr/local/bin/maintenance.sh
```
Runs every 7 days with 10 minutes delay after boot

**3. Run monthly:**
```
30 30 monthly_report /usr/bin/generate_report.sh
```
Runs every 30 days with 30 minutes delay after boot

**4. Run yearly:**
```
365 60 annual_cleanup /etc/init.d/yearly_cleanup.sh
```
Runs every 365 days with 60 minutes delay after boot

**Create anacron job file:**
```bash
sudo nano /etc/cron.d/my_anacron
```

**Add job:**
```
# Runs daily at 2 AM (anacron style)
1   0   daily_backup   root    /usr/bin/backup.sh > /var/log/backup.log 2>&1

# Runs weekly every Monday
7   10  weekly_scan    root    /usr/bin/virus_scan.sh

# Runs monthly on 1st
30  30  monthly_report root    /usr/bin/monthly_report.sh
```

**View anacron status:**
```bash
anacron -T                      # Test if anacron is installed
cat /var/spool/anacron/cron.*   # View last run timestamps
```

---

### **3. AT - Run Once at Specific Time**

**Purpose:** Execute a command or script one time at a future date/time

**When to use:**
- One-time tasks
- Scheduled maintenance window
- Delayed execution
- Emergency operations

**Service:** atd (must be running)

#### Check and Enable at Service:
```bash
sudo systemctl status atd
sudo systemctl start atd
sudo systemctl enable atd
```

#### At Command Syntax:

**Schedule at specific time:**
```bash
at 2:30 PM            # Run at 2:30 PM today
at 2:30 PM tomorrow   # Run at 2:30 PM tomorrow
at 2:30 PM June 15    # Run at 2:30 PM on June 15
at 2:30 PM +7 days    # Run 7 days from now at 2:30 PM
```

#### At Examples:

**Example 1: Schedule a one-time backup**
```bash
at 3:00 AM tomorrow
at> /usr/bin/backup.sh
at> <Ctrl+D>          # Press Ctrl+D to save and exit
```

**Example 2: Reboot after update**
```bash
at now + 10 minutes
at> /sbin/reboot
at> <Ctrl+D>
```

**Example 3: Send reminder email in 5 hours**
```bash
at now + 5 hours
at> mail user@example.com < /tmp/reminder.txt
at> <Ctrl+D>
```

**Example 4: Run with date format**
```bash
at 14:30 June 25       # 2:30 PM on June 25
at 2:30 PM 06/25/2026  # Alternative format
```

#### At Management Commands:

**View scheduled jobs:**
```bash
atq                   # List all pending at jobs
atq -u username       # List jobs for specific user
```

**View job details:**
```bash
at -c 1               # Display commands in job 1
```

**Remove at job:**
```bash
atrm 1                # Remove job ID 1
atrm -u username      # Remove all jobs for user
at -d 1               # Alternative way to delete job 1
```

**Check at logs:**
```bash
tail -f /var/log/syslog | grep at
journalctl -u atd     # View systemd logs
```

#### Production Example - System Update Window:

**Schedule maintenance window:**
```bash
at 11:59 PM Saturday
at> echo "Starting maintenance..." > /var/log/maintenance.log
at> /usr/bin/apt update && apt upgrade -y >> /var/log/maintenance.log 2>&1
at> /sbin/reboot >> /var/log/maintenance.log 2>&1
at> <Ctrl+D>
```

**Check scheduled time:**
```bash
atq
```

Output:
```
1  Sat Jun 25 23:59:00 2026 a root
```

---

### **Comparison Table: Cron vs Anacron vs At**

| Feature | CRON | ANACRON | AT |
|---------|------|---------|-----|
| **Frequency** | Recurring (minutes/hours) | Recurring (days/weeks/months/years) | One-time only |
| **Time-based** | ✅ Yes | ❌ No (day-based) | ✅ Yes |
| **Requires system always on** | ✅ Yes | ❌ No, runs after boot | ✅ Yes |
| **Runs if off at scheduled time** | ❌ No | ✅ Yes (catches up) | ❌ No |
| **Best for** | Regular tasks | Laptop/occasional use | One-shot events |
| **Config file** | `/var/spool/cron/` | `/etc/anacrontab` | at daemon (atd) |
| **Examples** | Every 15 mins, hourly backups | Daily/weekly/monthly maintenance | Single update, reboot |

---

### **System-Wide Cron Directories**

When adding jobs that need root privileges:

```bash
/etc/cron.d/        # Custom system cron jobs
/etc/cron.daily/    # Run daily
/etc/cron.hourly/   # Run hourly
/etc/cron.weekly/   # Run weekly
/etc/cron.monthly/  # Run monthly
```

**Add system cron job:**
```bash
sudo nano /etc/cron.d/my_system_job
```

**Content example:**
```
# Run every day at 3 AM as root
0 3 * * * root /usr/local/bin/system_backup.sh

# Run every Monday at 5 AM as www-data user
0 5 * * 1 www-data /home/www-data/weekly_cleanup.sh
```

![](../media/Network/cron-1.png)

![](../media/Network/cron_2.png) 

## SSL

- Secure Socket Layer, now (TLS) Transport Layer Security
- Authenticate and encrypts the data over network

- Openssl  -  Creates and manages the certificate

## Steps Involved in TLS (Transport Layer Security)

1. **Handshake Initiation**: The client sends a "ClientHello" message to the server, indicating supported TLS versions and cipher suites.

2. **Server Response**: The server responds with a "ServerHello" message, selecting the TLS version and cipher suite to use.

3. **Server Authentication and Pre-Master Secret**: The server sends its digital certificate to the client for authentication. The client verifies the certificate and generates a pre-master secret, encrypting it with the server's public key and sending it to the server.

4. **Session Keys Creation**: Both the client and server generate session keys from the pre-master secret for encryption and decryption of the data.

5. **Client Finished**: The client sends a "Finished" message, indicating that the client part of the handshake is complete.

6. **Server Finished**: The server responds with its own "Finished" message, completing the handshake.

7. **Secure Encrypted Connection**: The client and server can now securely exchange data using the established session keys.

8. **Certificate Signing Request (CSR)**: The client generates a CSR, which includes the public key and information about the entity requesting the certificate. This CSR is sent to a Certificate Authority (CA) for verification.

9. **Certificate Verification**: The CA verifies the information in the CSR and issues a digital certificate, which includes the public key and the CA's signature.

10. **Private Key Generation**: The client generates a private key that corresponds to the public key in the CSR. This private key is kept secure and is used for encrypting data and establishing secure connections.


Command to generate private key and cert sign request

```commandline
openssl req -newkey rsa:2048 -keyout key.pem -out req.pem
```

Command to generate the self signed certificate (used internally)

- Skips the authority verification and self signed cert creation

```commandline
openssl req -x509 -noexec -newkey rsa:4096 -days 365 -keyout myprivate.key -out mycertificate.crt
```

To view the details 
```commandline
openssl x509 -in mycertificate.crt -text
```



