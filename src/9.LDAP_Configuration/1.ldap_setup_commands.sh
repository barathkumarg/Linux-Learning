#!/bin/bash

################################################################################
# LDAP Configuration - Quick Reference Commands
# This script shows the complete workflow for setting up LDAP
# Production-ready examples with explanations
################################################################################

# =============================================================================
# SECTION 1: SETUP LDAP SERVER USING LXD
# =============================================================================

# Initialize LXD infrastructure
lxd init

# This creates LXD storage and networking. When prompted:
# - Would you like to use LXD clustering? → no
# - Configure new storage pool? → yes (default values work)
# - Backend driver: → zfs (Recommended for production)

# ─────────────────────────────────────────────────────────────────────────

# Import pre-built LDAP server container from archive
lxc import ldap-server.tar.xz

# This loads OpenLDAP server pre-configured with default settings
# The container will have slapd (LDAP daemon) ready to run

# ─────────────────────────────────────────────────────────────────────────

# List all LXD containers to verify import
lxc list

# Expected output:
# ╠═══════════════════╦════════╦══════════════════════╦════════════════════╣
# ║ NAME              ║ STATE  ║ IPV4                 ║ IMAGE              ║
# ╠═══════════════════╩════════╩══════════════════════╩════════════════════╣
# ║ ldap-server       │ STOPPED│ -                    │ -                  ║
# ╚═══════════════════════════════════════════════════════════════════════╝

# ─────────────────────────────────────────────────────────────────────────

# Start LDAP server container
lxc start ldap-server

# Container now boots and runs OpenLDAP service automatically

# ─────────────────────────────────────────────────────────────────────────

# Verify LDAP server is running and get its IP
lxc info ldap-server | grep eth0

# Output something like:
# eth0:  inet   10.0.0.101
# eth0:  inet6  fd42:22f2:e84b:abc::1

# SAVE THIS IP ADDRESS - CRUCIAL FOR CLIENT CONFIGURATION!
# Example: LDAP_SERVER_IP=10.0.0.101

# ─────────────────────────────────────────────────────────────────────────

# Verify LDAP service is active on server
lxc exec ldap-server -- systemctl status slapd

# Output should show:
# ● slapd.service - OpenLDAP Server Daemon
#    Loaded: loaded (/lib/systemd/system/slapd.service; enabled; preset: disabled)
#    Active: active (running)

# ─────────────────────────────────────────────────────────────────────────

# Test LDAP server from container (verify database exists)
lxc exec ldap-server -- ldapsearch -x -H ldap://localhost -b "dc=example,dc=com" -s base

# This queries the LDAP database root. Sample output:
# # extended LDIF
# #
# # LDAPv3
# # base <dc=example,dc=com> with scope baseObject
# # filter: (objectclass=*)
# # requesting: ALL
# #
# 
# # example.com
# dn: dc=example,dc=com
# objectClass: top
# objectClass: dcObject
# dc: example

# =============================================================================
# SECTION 2: CONFIGURE LDAP CLIENT (YOUR LINUX SYSTEM)
# =============================================================================

# Step 1: Install LDAP client packages
sudo apt-get update
sudo apt-get install -y libnss-ldap nslcd libpam-ldapd ldap-utils

# What gets installed:
# - libnss-ldap    : NSS library for LDAP user/group lookups
# - nslcd          : LDAP daemon for client-side LDAP queries
# - libpam-ldapd   : PAM module for LDAP authentication
# - ldap-utils     : Tools like ldapsearch for testing LDAP

# During installation, may be prompted for LDAP server details
# LDAP Server address: 10.0.0.101
# Base DN: dc=example,dc=com

# ─────────────────────────────────────────────────────────────────────────

# Step 2: Configure NSLCD (LDAP daemon configuration)
# Edit /etc/nslcd.conf - tells nslcd where LDAP server is

sudo cat > /etc/nslcd.conf << 'EOF'
# /etc/nslcd.conf - NSLCD Daemon Configuration
# This file configures how to connect to LDAP server

# LDAP server URI and port
# Format: ldap://hostname:port or ldaps://hostname:port (for SSL/TLS)
uri ldap://10.0.0.101:389

# Base DN (Distinguished Name) for directory searches
# This is the root of your LDAP directory tree
base dc=example,dc=com

# Service account credentials (read-only account for binding)
# This account connects to LDAP to query user/group data
binddn cn=admin,dc=example,dc=com
bindpw admin_password

# Search bases for different databases
# These specify where to find users, groups, etc.
base passwd ou=people,dc=example,dc=com
base shadow ou=people,dc=example,dc=com
base group  ou=groups,dc=example,dc=com

# LDAP object class filters for searches
# These ensure we only query correct object types
filter passwd (&(objectClass=posixAccount)(uid=*))
filter shadow (&(objectClass=shadowAccount)(uid=*))
filter group  (&(objectClass=posixGroup)(cn=*))

# Caching configuration (in seconds)
# Cache reduces LDAP queries for better performance
cache passwd 3600
cache group  3600
cache shadow 3600

# Connection timeouts
timelimit 30
bind_timelimit 10
EOF

# ─────────────────────────────────────────────────────────────────────────

# Step 3: Update system to use LDAP for name lookups
# Edit /etc/nsswitch.conf - tells system where to look for user/group info

sudo sed -i.bak \
  -e 's/^passwd:.*/passwd:         files ldap/' \
  -e 's/^shadow:.*/shadow:         files ldap/' \
  -e 's/^group:.*/group:          files ldap/' \
  /etc/nsswitch.conf

# What changed:
# Old: passwd: files        <- Only look in local files (/etc/passwd)
# New: passwd: files ldap   <- First check local, then LDAP server

# Verify changes
cat /etc/nsswitch.conf | grep -E "^(passwd|shadow|group):"

# Output should show:
# passwd:         files ldap
# shadow:         files ldap
# group:          files ldap

# ─────────────────────────────────────────────────────────────────────────

# Step 4: Start and enable NSLCD service
sudo systemctl start nslcd
sudo systemctl enable nslcd

# Verify service is running
sudo systemctl status nslcd

# Should show:
# ● nslcd.service - LDAP passwd, group, and shadow lookup service.
#    Loaded: loaded (/lib/systemd/system/nslcd.service; enabled; preset: enabled)
#    Active: active (running) since [timestamp]

# ─────────────────────────────────────────────────────────────────────────

# Check NSLCD logs for any errors
journalctl -u nslcd -n 50
# -n 50 shows last 50 log lines

# For real-time monitoring
journalctl -u nslcd -f
# -f follows logs like 'tail -f'

# =============================================================================
# SECTION 3: TEST LDAP CONFIGURATION
# =============================================================================

# Test 1: Query LDAP server directly (test network connectivity)
ldapsearch -x \
  -H ldap://10.0.0.101 \
  -b "dc=example,dc=com" \
  -s base

# -x: Simple authentication (no password)
# -H: LDAP server URI
# -b: Base DN to search from
# -s base: Only return base object itself

# Expected output: Shows LDAP database structure and attributes

# ─────────────────────────────────────────────────────────────────────────

# Test 2: Search for specific user in LDAP
ldapsearch -x \
  -H ldap://10.0.0.101 \
  -b "dc=example,dc=com" \
  "uid=alice"

# This searches for user 'alice' in LDAP
# Replace 'alice' with actual username in your LDAP server

# Expected output: User entry with all attributes
# dn: uid=alice,ou=people,dc=example,dc=com
# uid: alice
# cn: Alice Smith
# mail: alice@company.com
# uidNumber: 5001
# gidNumber: 5000
# homeDirectory: /home/alice
# etc.

# ─────────────────────────────────────────────────────────────────────────

# Test 3: Get user info via system (proves NSS integration works!)
getent passwd alice

# Output should look like /etc/passwd but data comes from LDAP:
# alice:x:5001:5000:Alice Smith:/home/alice:/bin/bash

# Compare with local user
getent passwd root
# root:x:0:0:root:/root:/bin/bash

# getent shows both local and LDAP users!

# ─────────────────────────────────────────────────────────────────────────

# Test 4: List all LDAP users (only works if users exist in LDAP)
getent passwd | grep -E ":[0-9]{4}:"

# Shows users with UID >= 1000 (typical LDAP users)
# Local system users have lower UIDs (0-999)

# ─────────────────────────────────────────────────────────────────────────

# Test 5: Get group information
getent group admins

# Output:
# admins:x:5001:alice,bob,charlie

# Shows group name, GID, and members from LDAP

# ─────────────────────────────────────────────────────────────────────────

# Test 6: Test login as LDAP user
su - alice

# Should prompt for password
# If it works, you're now logged in as LDAP user!

# Verify:
id
# uid=5001(alice) gid=5000(developers) groups=5000(developers),5001(admins)

whoami
# alice

# ─────────────────────────────────────────────────────────────────────────

# Test 7: Verify NSLCD caching
# Make two getent calls and check response time (should be instant 2nd time)

time getent passwd alice
# First call - may take few milliseconds (queries LDAP)

sleep 1

time getent passwd alice
# Second call - should be much faster (from cache)

# =============================================================================
# SECTION 4: PRODUCTION HARDENING
# =============================================================================

# Secure NSLCD configuration (restrict permissions)
sudo chmod 600 /etc/nslcd.conf
sudo chown nslcd:nslcd /etc/nslcd.conf

# This prevents other users from reading passwords in nslcd.conf

# ─────────────────────────────────────────────────────────────────────────

# Enable SSL/TLS for LDAP connection (production important!)
# Edit /etc/nslcd.conf and modify:

# FROM:
# uri ldap://10.0.0.101:389

# TO:
# uri ldaps://10.0.0.101:636
# tls_reqcert hard

# This encrypts LDAP traffic and verifies SSL certificate

# ─────────────────────────────────────────────────────────────────────────

# Backup NSLCD configuration before changes
sudo cp /etc/nslcd.conf /etc/nslcd.conf.bak

# Useful if configuration breaks LDAP access!

# =============================================================================
# SECTION 5: TROUBLESHOOTING COMMANDS
# =============================================================================

# Check if LDAP server is reachable
nc -zv 10.0.0.101 389
# If successful: Connection to 10.0.0.101 389 port [ldap/*] succeeded!

# ─────────────────────────────────────────────────────────────────────────

# Verify NSLCD is running and listening
sudo ss -tulpn | grep nslcd
# Shows NSLCD listening on Unix sockets for clients

# ─────────────────────────────────────────────────────────────────────────

# Debug NSLCD connection to LDAP server
sudo nslcd -d 2>&1 | head -50

# Shows debug output from NSLCD including:
# - LDAP server connection attempts
# - Search queries
# - Errors (if any)

# ─────────────────────────────────────────────────────────────────────────

# Check NSLCD can authenticate to LDAP
ldapsearch -v \
  -x \
  -H ldap://10.0.0.101 \
  -D "cn=admin,dc=example,dc=com" \
  -w "admin_password" \
  -b "dc=example,dc=com" \
  "uid=alice"

# -D: Bind DN (user to authenticate as)
# -w: Bind password

# ─────────────────────────────────────────────────────────────────────────

# List all users currently visible to system (local + LDAP)
getent passwd | awk -F: '{print $1, $3, $6}'

# Output columns: username, UID, home_directory

# ─────────────────────────────────────────────────────────────────────────

# Check what NSS sources are actually being used
cat /etc/nsswitch.conf | grep -E "^(passwd|shadow|group)"

# Verify 'ldap' is included in each

# ─────────────────────────────────────────────────────────────────────────

# View recent NSLCD service logs
journalctl -u nslcd -n 100 --no-pager

# Useful for diagnosing LDAP connection issues

# =============================================================================
# SECTION 6: PRODUCTION EXAMPLE - COMPANY NETWORK
# =============================================================================

# SCENARIO: Company needs 100 employees to authenticate across 50 Linux servers
# SOLUTION: LDAP server in LXC + LDAP client configuration on all servers

# STEP 1: On LDAP Server Container (one-time setup)
# - Already done: lxc start ldap-server
# - LDAP server has 100 employee accounts

# STEP 2: Deploy client to all 50 servers (automated)
# Configure nslcd on each server with same settings:
# uri ldap://10.0.0.101:389
# base dc=company,dc=com
# binddn cn=admin,dc=company,dc=com
# bindpw SecurePassword123

# STEP 3: Add new employee (IT admin does once)
# - Add user to LDAP server
# - Result: All 50 servers immediately recognize new user
# - No need to add user 50 times to separate /etc/passwd files!

# STEP 4: Remove employee (HR event)
# - Remove user from LDAP
# - Result: Access revoked on all 50 servers instantly

# =============================================================================
# EXAMPLE: Full setup on fresh Ubuntu server
# =============================================================================

# As root or with sudo:

# 1. Install packages
apt-get update
apt-get install -y libnss-ldap nslcd libpam-ldapd ldap-utils

# 2. Configure NSLCD
cat > /etc/nslcd.conf << 'LDAPEOF'
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
LDAPEOF

# 3. Update NSS
sed -i.bak \
  -e 's/^passwd:.*/passwd:         files ldap/' \
  -e 's/^shadow:.*/shadow:         files ldap/' \
  -e 's/^group:.*/group:          files ldap/' \
  /etc/nsswitch.conf

# 4. Start NSLCD
systemctl start nslcd
systemctl enable nslcd

# 5. Test
getent passwd alice
# Done! Should see LDAP user

################################################################################
# END OF LDAP CONFIGURATION SCRIPT
# For detailed explanations, see 16_LDAP_Configuration.md
################################################################################

