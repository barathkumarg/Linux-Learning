# LDAP Configuration - Complete Guide

## Quick Overview

**LDAP** (Light Directory Access Protocol) = Centralized user management system. Add a user **once** to a central server, and they can login to **50+ Linux servers** immediately.

**Traditional vs LDAP:**
- Traditional: Add user to each server's `/etc/passwd` (tedious, error-prone)
- LDAP: Add user to LDAP server, all servers automatically get it (efficient, centralized)

### Why Use LDAP?

| Need | Solution |
|------|----------|
| Manage 100 users across 50 servers | Create 1 user once in LDAP, all servers use it |
| Centralized authentication | Single password database for all Linux systems |
| Consistent permissions | User UID/GID same everywhere |
| Save administration time | One place to add/remove/modify users |

**Real-world example**: Large company with 500 Linux servers - instead of maintaining `/etc/passwd` on each server, they use LDAP. IT admin adds a user once, and that user can log into all 500 servers immediately.

---

## Quick Start (20 minutes)

### Step 1: Start LDAP Server (5 min)

```bash
# Initialize LXD (one-time)
sudo lxd init
# Use defaults when prompted

# Import and start LDAP server
sudo lxc import ldap-server.tar.xz
sudo lxc start ldap-server

# Get LDAP server IP
sudo lxc info ldap-server | grep eth0
# Copy this IP address - you'll need it: e.g., 10.0.0.101
```

### Step 2: Configure Client (10 min)

```bash
# Step 1: Install LDAP packages
sudo apt-get update
sudo apt-get install -y libnss-ldap nslcd ldap-utils

# Step 2: Edit /etc/nslcd.conf
# Replace 10.0.0.101 with your LDAP server IP
sudo nano /etc/nslcd.conf
```

**Paste this into /etc/nslcd.conf:**
```conf
uri ldap://10.0.0.101:389
base dc=example,dc=com
binddn cn=admin,dc=example,dc=com
bindpw admin_password
base passwd ou=people,dc=example,dc=com
base shadow ou=people,dc=example,dc=com
base group  ou=groups,dc=example,dc=com
filter passwd (&(objectClass=posixAccount)(uid=*))
filter shadow (&(objectClass=shadowAccount)(uid=*))
filter group  (&(objectClass=posixGroup)(cn=*))
cache passwd 3600
cache group  3600
cache shadow 3600
```

```bash
# Step 3: Update NSS configuration
sudo nano /etc/nsswitch.conf
```

**Change these three lines in /etc/nsswitch.conf:**
```conf
passwd:         files ldap
shadow:         files ldap
group:          files ldap
```

```bash
# Step 4: Start NSLCD service
sudo systemctl start nslcd
sudo systemctl enable nslcd
sudo systemctl status nslcd
# Should show: active (running)
```

### Step 3: Test LDAP (5 min)

```bash
# Test 1: LDAP server reachable?
ldapsearch -x \
  -H ldap://10.0.0.101 \
  -b "dc=example,dc=com" \
  -s base

# Test 2: See LDAP users (if they exist)
getent passwd
# Should show both local + LDAP users

# Test 3: Try login as LDAP user (if you have one)
su - alice
# Enter password

# Test 4: Check user info
id alice
```

---

## Key LDAP Concepts - Explained Simply

### 1. **LDAP Directory Structure (DIT - Directory Information Tree)**

Think of it like a filing system:

### 1. **LDAP Directory Structure (DIT - Directory Information Tree)**

Think of it like a filing system:

```
BaseDN: dc=company,dc=com (root - like C: drive)
├── ou=people (folder for users)
│   ├── uid=alice
│   ├── uid=bob
│   └── uid=charlie
├── ou=groups (folder for groups)
│   ├── cn=admins
│   ├── cn=developers
│   └── cn=support
└── ou=computers (folder for systems)
    ├── cn=server1
    ├── cn=server2
    └── cn=workstation1
```

**Key terms:**
- **BaseDN**: `dc=company,dc=com` - Like domain root. `dc` = Domain Component
- **ou**: `ou=people` - Organizational Unit (like folder)
- **uid**: `uid=alice` - User ID (unique user identifier)
- **cn**: `cn=admins` - Common Name (like a label)
- **DN (Distinguished Name)**: Full path like `uid=alice,ou=people,dc=company,dc=com`

### 2. **Simple LDAP Example Entry**

```ldif
dn: uid=alice,ou=people,dc=company,dc=com
uid: alice
cn: Alice Smith
mail: alice@company.com
objectClass: inetOrgPerson
objectClass: posixAccount
userPassword: {SSHA}encrypted_password_here
uidNumber: 5001
gidNumber: 5000
homeDirectory: /home/alice
loginShell: /bin/bash
```

**What this means:**
- `dn`: Complete address of this user
- `uid`: Username (like /etc/passwd)
- `uidNumber`: User ID number (like UID in /etc/passwd)
- `gidNumber`: Primary group ID (like GID in /etc/passwd)
- `homeDirectory`: Home dir (like /home/alice)
- `loginShell`: Default shell (like /bin/bash)

---

## High-Level Architecture (3 Components)

```
1. LDAP SERVER (Container)
   └─ Stores all user/group data
   └─ Run in LXD container (ldap-server)
   
2. LDAP CLIENT (Your Linux System)
   └─ Connects to LDAP server
   └─ Installs: nslcd, libnss-ldap
   └─ Configuration: /etc/nslcd.conf, /etc/nsswitch.conf
   
3. TEST & VERIFY
   └─ Commands like: getent passwd, id, su, ssh
```

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                LDAP Infrastructure                           │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐                                           │
│  │ LDAP Server  │ (OpenLDAP - stores all data)             │
│  │ lxd container│ Port: 389 (LDAP), 636 (LDAPS)           │
│  └──────┬───────┘                                           │
│         │                                                    │
│    ┌────┴────────────────────────────────┐                  │
│    │ LDAP Protocol (TCP/IP)               │                  │
│    │ Queries for user/group info          │                  │
│    └────┬────────────────────────────────┘                  │
│         │                                                    │
│  ┌──────┴────────────────────────────────┐                  │
│  │ LDAP Clients (Your Linux Servers)     │                  │
│  │ ┌────────────────────────────────┐   │                  │
│  │ │ nslcd - LDAP Namservice Switch │   │                  │
│  │ │ (Daemon connecting to LDAP)    │   │                  │
│  │ ├────────────────────────────────┤   │                  │
│  │ │ libnss-ldap - NSS Library      │   │                  │
│  │ │ (Makes LDAP look like /etc/p..)│   │                  │
│  │ ├────────────────────────────────┤   │                  │
│  │ │ /etc/passwd, /etc/shadow, etc. │   │                  │
│  │ │ (System files)                  │   │                  │
│  │ └────────────────────────────────┘   │                  │
│  └─────────────────────────────────────┘                    │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Part 1: Setting Up LDAP Server using LXD

### Step 1: Initialize LXD

```bash
# Initialize LXD - answer the prompts
sudo lxd init
```

**What happens:**
- Sets up LXD storage (storage pool)
- Configures networking
- Sets default image server

**Interactive prompts:**
```
Would you like to use LXD clustering? (yes/no) [default=no]: no
Do you want to configure a new storage pool? (yes/no) [default=yes]: yes
Name of the new storage pool [default=default]:                          # Press Enter
Name of the lxd backend driver [btrfs,cdir,lvm,zfs] [default=zfs]: zfs   # Choose zfs
[... other prompts, use defaults ...]
```

### Step 2: Import LDAP Server Container

```bash
# Import pre-built LDAP server container
sudo lxc import ldap-server.tar.xz

# This loads a container named 'ldap-server' that already has OpenLDAP installed
```

### Step 3: List Containers

```bash
# See all containers
sudo lxc list

# Output example:
# NAME           STATE   IPV4       IMAGE
# ldap-server    STOPPED 10.0.0.x   -
```

### Step 4: Start LDAP Server

```bash
# Start the container
sudo lxc start ldap-server

# Verify it's running
sudo lxc list
# Should show STATE: RUNNING
```

### Step 5: Get Container IP Address

```bash
# Find LDAP server IP
sudo lxc list ldap-server

# Get more details
sudo lxc info ldap-server | grep "eth0"

# Will show something like: 10.0.0.101
```

**Save this IP** - you'll need it for client configuration (e.g., `10.0.0.101`)

### Step 6: Verify LDAP Server is Working

```bash
# Connect to container
sudo lxc exec ldap-server -- bash

# Inside container, check LDAP service
systemctl status slapd   # slapd = OpenLDAP daemon

# Test LDAP query (inside container)
ldapsearch -x -H ldap://localhost -b "dc=example,dc=com" -s base 'objectclass=*'

# Should return the LDAP database structure
```

---

## Part 2: Configure LDAP Client (Your Main Linux System)

### Step 1: Install Required Packages

```bash
# Install LDAP client tools
sudo apt-get update
sudo apt-get install -y libnss-ldap nslcd libpam-ldapd ldap-utils

# Debian/Ubuntu - will prompt for LDAP server details during installation
```

**What each package does:**

| Package | Purpose |
|---------|---------|
| `libnss-ldap` | Makes LDAP look like `/etc/passwd` to the system |
| `nslcd` | Daemon that connects to LDAP server |
| `libpam-ldapd` | Allows login using LDAP passwords |
| `ldap-utils` | Tools like `ldapsearch` for testing |

### Step 2: Configure `/etc/nslcd.conf`

This file tells system where LDAP server is and how to connect.

```bash
# Edit configuration
sudo nano /etc/nslcd.conf
```

**Basic Configuration:**

```conf
# /etc/nslcd.conf - NSLCD Configuration File

# IP address of LDAP server
uri ldap://10.0.0.101:389

# Base search path (same as LDAP server config)
base dc=example,dc=com

# How system identifies itself to LDAP
binddn cn=admin,dc=example,dc=com
bindpw admin_password

# User search path
base passwd ou=people,dc=example,dc=com
base shadow ou=people,dc=example,dc=com
base group  ou=groups,dc=example,dc=com

# Search filters (what LDAP object classes to use)
filter passwd (&(objectClass=posixAccount)(uid=*))
filter shadow (&(objectClass=shadowAccount)(uid=*))
filter group  (&(objectClass=posixGroup)(cn=*))

# Make searches faster (cache results)
cache passwd 3600
cache group  3600
cache shadow 3600

# Timeouts and performance
timelimit 30
bind_timelimit 10
```

**Production Example (for company.com):**

```conf
uri ldap://ldap.company.com:389

base dc=company,dc=com

binddn cn=ldapbind,ou=service-accounts,dc=company,dc=com
bindpw SecurePassword123!

base passwd ou=employees,dc=company,dc=com
base shadow ou=employees,dc=company,dc=com
base group  ou=groups,dc=company,dc=com

# SSL/TLS encryption (recommended for production)
ssl on
tls_reqcert hard

# Cache user data (improves performance)
cache passwd 900
cache group  900
cache shadow 900
```

### Step 3: Configure NSS (Name Service Switch)

This file tells system where to look for user/group info.

```bash
# Edit NSS configuration
sudo nano /etc/nsswitch.conf
```

**Modify these lines:**

```conf
# OLD (before)
passwd:         files
shadow:         files
group:          files

# NEW (with LDAP)
passwd:         files ldap
shadow:         files ldap
group:          files ldap
```

**What this means:**
- `files ldap` = First check local files (`/etc/passwd`), then LDAP
- This way, local users still work if LDAP is down
- LDAP is consulted when info not found locally

### Step 4: Start and Enable NSLCD Service

```bash
# Start the service
sudo systemctl start nslcd
sudo systemctl status nslcd   # Should show "active (running)"

# Enable on boot
sudo systemctl enable nslcd

# Check logs
sudo journalctl -u nslcd -f   # Follow logs in real-time
```

---

## Part 3: Testing LDAP Configuration

### Test 1: Basic LDAP Query

```bash
# Query LDAP server directly
ldapsearch -x -H ldap://10.0.0.101 -b "dc=example,dc=com" -s base

# -x: Simple authentication (no password)
# -H: LDAP server URI
# -b: Search base
# -s base: Search scope (just return base object)

# Expected output: Shows LDAP database structure
```

### Test 2: Search for a User

```bash
# Search for user 'alice' in LDAP
ldapsearch -x -H ldap://10.0.0.101 -b "dc=example,dc=com" "uid=alice"

# Should return alice's entry with all attributes
```

### Test 3: Get User Information via System

```bash
# After LDAP is configured, should return user info
getent passwd alice

# Output should show:
# alice:x:5001:5000:Alice Smith:/home/alice:/bin/bash

# (Like 'cat /etc/passwd' but gets data from LDAP!)
```

### Test 4: Get Group Information

```bash
# Get all groups (local + LDAP)
getent group

# Get specific group
getent group admins
```

### Test 5: Try Login

```bash
# SSH into server as LDAP user
ssh alice@localhost

# Or switch user
su - alice
```

**Verify user logged in from LDAP:**
```bash
# Check who you are
id alice

# Output should show:
# uid=5001(alice) gid=5000(developers) groups=5000(developers),5001(admins)
```

---

## Key Concepts Explained Simply

### 1. **nslcd vs libnss-ldap**

**nslcd (LDAP Daemon):**
- Background service that connects to LDAP server
- Handles communication, keeps connection alive
- Caches data for performance
- Modern approach (pre-configured in `/etc/nslcd.conf`)

**libnss-ldap (Legacy):**
- Older library-based approach
- Less flexible than nslcd
- Less recommended for new setups

**Modern setup uses both** - they work together nicely.

### 2. **NSS (Name Service Switch)**

Controls where system looks for user/group/host/service information.

```
User types: getent passwd alice

     ↓
     
NSS check (/etc/nsswitch.conf):
  ├─ First check: files (/etc/passwd)
  └─ If not found: ldap (LDAP server)
  
     ↓
     
Returns: alice's info
```

### 3. **LDAP Server vs Client**

| LDAP Server | LDAP Client |
|------------|------------|
| Central database | System using LDAP |
| Stores all user/group data | Asks server for info |
| One per organization | Many systems |
| OpenLDAP (slapd) | nslcd + libnss-ldap |

### 4. **What is DN (Distinguished Name)?**

Think of it like a full file path:

```
File system:        /home/documents/work/report.pdf
LDAP structure:     uid=alice,ou=people,dc=example,dc=com

Components:
- uid=alice                   └─ User ID (like filename)
- ou=people                   └─ Organizational Unit (like /people folder)
- dc=example,dc=com           └─ Domain Component (like c:/ root)
```

### 5. **What is nslcd?**

A background service that:
- Connects to LDAP server
- Answers system's questions about users/groups
- Caches data for speed
- Handles authentication

**Think of it like:** A librarian who talks to a central database to answer "Who is user alice?"

### 6. **nslcd vs libnss-ldap**

**nslcd (LDAP Daemon):**
- Background service that connects to LDAP server
- Handles communication, keeps connection alive
- Caches data for performance
- Modern approach (configured via `/etc/nslcd.conf`)

**libnss-ldap (Legacy):**
- Older library-based approach
- Less flexible than nslcd
- Not recommended for new setups

**Modern setup uses both** - they work together nicely.

### 7. **What is NSS (Name Service Switch)?**

Tells Linux where to look for user/group/host/service information:

```
WITHOUT LDAP:
  getent passwd alice  →  Look in /etc/passwd only  →  LDAP user NOT found

WITH LDAP (via /etc/nsswitch.conf):
  getent passwd alice  →  Look in /etc/passwd first  →  If not found
                       →  Look in LDAP server       →  User found!
```

### 8. **What is posixAccount?**

LDAP object class (type) that makes LDAP users look like Linux users.

Contains fields like:
- `uid`: Username
- `uidNumber`: User ID (like UID in /etc/passwd)
- `homeDirectory`: /home/alice
- `loginShell`: /bin/bash

### 9. **Common LDAP Objects (What Can Be Stored)**

| Object | Used For | Example |
|--------|----------|---------|
| posixAccount | Users | jane.smith, uidNumber: 5001 |
| shadowAccount | Password hashes | Password expiry info |
| posixGroup | Groups | developers, admins |
| inetOrgPerson | People data | cn, mail, telephoneNumber |
| organizationalUnit | Folders | ou=people, ou=groups |

---

## Production Example: Company Network

### Scenario
A company with 3 Linux servers needs to manage employees:
- `ldap-server` - LDAP server (10.0.0.101)
- `prod-web1` - Web server needing user access (10.0.0.102)
- `prod-app1` - App server needing user access (10.0.0.103)

### Setup Flow

```
1. LDAP Server (ldap-server)
   ├─ OpenLDAP running
   ├─ Contains: 100 employee accounts
   └─ Users: uid=john, uid=jane, uid=bob, etc.

2. Web Server (prod-web1)
   ├─ Install: nslcd, libnss-ldap
   ├─ Configure: /etc/nslcd.conf (point to 10.0.0.101)
   ├─ Configure: /etc/nsswitch.conf (add ldap)
   └─ Result: Can login as any LDAP user

3. App Server (prod-app1)
   ├─ Install: nslcd, libnss-ldap
   ├─ Configure: /etc/nslcd.conf (point to 10.0.0.101)
   ├─ Configure: /etc/nsswitch.conf (add ldap)
   └─ Result: Can login as any LDAP user

4. Add new employee to 100 servers
   └─ Add user ONCE in LDAP → Auto available on all servers!
```

### Server1 Config Example

```bash
# /etc/nslcd.conf on prod-web1 and prod-app1
uri ldap://10.0.0.101:389
base dc=company,dc=com
binddn cn=admin,dc=company,dc=com
bindpw secure_password
```

---

## Common Issues & Solutions

### Issue 1: "Users not appearing after LDAP setup"

```bash
# Check nslcd is running
sudo systemctl status nslcd
# If not running:
sudo systemctl start nslcd

# Check configuration
sudo nslcd -d   # Run in debug mode to see errors

# Test LDAP connection
ldapsearch -x -H ldap://SERVER_IP -b "dc=example,dc=com"
```

### Issue 2: "LDAP users can't login"

```bash
# Check PAM configuration
cat /etc/pam.d/common-password
cat /etc/pam.d/common-auth

# May need PAM configuration for LDAP passwords
# (depends on system/distribution)
```

### Issue 3: "This works locally but users can't SSH"

```bash
# SSH uses PAM, needs libpam-ldapd
sudo apt-get install libpam-ldapd

# Check SSH allows PAM password auth
grep PubkeyAuthentication /etc/ssh/sshd_config
# Should allow password auth if using LDAP passwords
```

---

## Production-Ready Security

### Always use these in production:

```conf
# /etc/nslcd.conf - Production Security

# 1. SSL/TLS Encryption
uri ldaps://ldap.company.com:636
ssl on
tls_reqcert hard
tls_cacertfile /etc/ldap/ca_cert.pem

# 2. Dedicated service account (not admin)
binddn cn=nslcd-service,ou=service-accounts,dc=company,dc=com
bindpw SecurePassword123!@#

# 3. Proper file permissions
# Run this:
sudo chmod 640 /etc/nslcd.conf
sudo chown root:nslcd /etc/nslcd.conf

# 4. Aggressive caching (reduces queries)
cache passwd 7200
cache group  7200
cache shadow 7200
```

---

## Troubleshooting Quick Reference

| Problem | Solution |
|---------|----------|
| LDAP users not showing up | Check: `getent passwd alice` and `journalctl -u nslcd -f` |
| Can't login as LDAP user | Need PAM setup or user doesn't have loginShell |
| Slow logins | Increase cache: `cache passwd 7200` in nslcd.conf |
| Connection refused | Check firewall: `nc -zv 10.0.0.101 389` |
| Permission denied | Verify bind credentials: test with `ldapsearch -D` |
| LDAP server down | Should still work - local users in /etc/passwd work |

### Enhanced Troubleshooting

#### Issue 4: "Can query LDAP manually but getent doesn't show users"

```bash
# Check 1: NSS filter might be too restrictive
grep "filter passwd" /etc/nslcd.conf

# Check 2: Try manual query with same filter
ldapsearch -x \
  -H ldap://10.0.0.101 \
  -D "cn=admin,dc=example,dc=com" \
  -w "admin_password" \
  -b "ou=people,dc=example,dc=com" \
  "(&(objectClass=posixAccount)(uid=alice))"

# If returns nothing, user doesn't have correct objectClass
# Solution: Add posixAccount objectClass to user in LDAP
```

#### Issue 5: "LDAP server down, need fallback"

Good news - this already works! Your configuration uses:
```
passwd: files ldap
```

This tries local `/etc/passwd` first, then LDAP. So even if LDAP is down, local users still work!

#### Common Troubleshooting Commands

```bash
# Real-time nslcd logs
sudo journalctl -u nslcd -f

# See last 20 nslcd messages
sudo journalctl -u nslcd -n 20

# Run nslcd in debug mode (verbose output)
sudo systemctl stop nslcd
sudo nslcd -d

# Test LDAP connection with timing
time ldapsearch -x \
  -H ldap://10.0.0.101 \
  -D "cn=admin,dc=example,dc=com" \
  -w "admin_password" \
  -b "dc=example,dc=com" \
  "uid=alice"

# Check if LDAP server is reachable
nc -zv 10.0.0.101 389

# Verify nslcd is running and listening
sudo ss -tulpn | grep nslcd
```

---

## What You Can Do Now

✓ Add user once in LDAP → Auto login on all 50 servers  
✓ Remove user from LDAP → All 50 servers deny access immediately  
✓ Change user's email in LDAP → Change reflected everywhere  
✓ Create groups in LDAP → Assign permissions to groups  
✓ Organize users by department → Different search bases  

---

- [ ] `lxd init` - Initialize LXD
- [ ] `lxc import ldap-server.tar.xz` - Import LDAP server
- [ ] `lxc start ldap-server` - Start LDAP server  
- [ ] Get LDAP server IP: `lxc info ldap-server`
- [ ] `sudo apt-get install libnss-ldap nslcd ldap-utils`
- [ ] Edit `/etc/nslcd.conf` - Set server URI and base DN
- [ ] Edit `/etc/nsswitch.conf` - Add "ldap" to passwd/shadow/group
- [ ] `sudo systemctl start nslcd` - Start NSLCD service
- [ ] Test: `ldapsearch -x -H ldap://SERVER_IP -b "dc=example,dc=com"`
- [ ] Test: `getent passwd username`
- [ ] Test: `su - ldap_username` - Try logging in

---

## Key Takeaways

1. **LDAP = Centralized Directory Service** for managing users/groups across many servers

2. **Architecture:** LDAP Server (Central) ← → LDAP Clients (Local Systems) via nslcd

3. **Configuration:**
   - `/etc/nslcd.conf` - Tell nslcd where LDAP server is
   - `/etc/nsswitch.conf` - Tell system to check LDAP for users/groups

4. **Search Flow:**
   - System needs user info
   - nslcd queries LDAP server
   - LDAP returns data
   - System loads user (if LDAP-authorized)
   - User can login

5. **Benefits:**
   - One user account, many servers
   - Changes apply instantly everywhere
   - Centralized security
   - Scalable to 1000s of users

---

## Reference Files

See the script files for detailed examples:
- `src/9.LDAP_Configuration/1.ldap_setup_commands.sh` - All commands with explanations
- `src/9.LDAP_Configuration/2.ldap_ldif_examples.sh` - How to add users/groups to LDAP
- `src/9.LDAP_Configuration/3.ldap_config_reference.sh` - Config files and troubleshooting

---

## You're Ready!

You now understand:
- ✓ What LDAP is and why it's useful
- ✓ How LDAP server and clients work
- ✓ How to set up LDAP client (nslcd)
- ✓ How to test LDAP connectivity
- ✓ How to troubleshoot common issues
- ✓ How to add users (via LDIF)
- ✓ Production security best practices

**Next:** Practice adding a user to LDAP and logging in!

Good luck! 🚀

---