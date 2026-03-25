#!/bin/bash

################################################################################
# LDAP Configuration Files & Troubleshooting Reference
# Complete configuration examples and solutions for common issues
################################################################################

# =============================================================================
# FILE 1: /etc/nslcd.conf - NSLCD Daemon Configuration
# =============================================================================

# Location: /etc/nslcd.conf (on LDAP client systems)
# Owner: root
# Permissions: 600 (only readable by root)
# Purpose: Tells nslcd daemon where LDAP server is and how to query it

# MINIMAL CONFIGURATION (for testing)

cat > /etc/nslcd.conf << 'EOF'
# /etc/nslcd.conf - Minimal LDAP Client Configuration

# LDAP server location
uri ldap://10.0.0.101:389

# Base Distinguished Name (root of LDAP directory)
base dc=example,dc=com

# Admin account credentials for queries
binddn cn=admin,dc=example,dc=com
bindpw admin_password

# Where to find users in LDAP directory
base passwd ou=people,dc=example,dc=com
base shadow ou=people,dc=example,dc=com
base group  ou=groups,dc=example,dc=com

EOF

# ─────────────────────────────────────────────────────────────────────────

# STANDARD CONFIGURATION (recommended for most environments)

cat > /etc/nslcd.conf << 'EOF'
# /etc/nslcd.conf - Standard LDAP Configuration

# LDAP Server Connection
uri ldap://10.0.0.101:389
# uri ldap://ldap1.example.com ldap://ldap2.example.com  # Multiple servers for HA

# Base DN for searches
base dc=example,dc=com

# Service account (read-only LDAP account)
binddn cn=ldapbind,ou=service-accounts,dc=example,dc=com
bindpw BindPassword123!

# User database locations
base passwd ou=people,dc=example,dc=com
base shadow ou=people,dc=example,dc=com
base group  ou=groups,dc=example,dc=com
base hosts  ou=computers,dc=example,dc=com
base netgroup ou=netgroups,dc=example,dc=com

# Search filters (what object class to find)
# Only search for users with posixAccount class
filter passwd (&(objectClass=posixAccount)(uid=*))
filter shadow (&(objectClass=shadowAccount)(uid=*))
filter group  (&(objectClass=posixGroup)(cn=*))
filter hosts  (&(objectClass=ipHost)(cn=*))

# Caching (improves performance, reduce queries to LDAP)
cache passwd 3600    # Cache users for 1 hour
cache group  3600    # Cache groups for 1 hour  
cache shadow 3600    # Cache shadow for 1 hour
cache hosts  3600    # Cache hosts for 1 hour

# Connection settings
timelimit 30         # Query timeout (seconds)
bind_timelimit 10    # Bind operation timeout

# SSL/TLS settings (if using encrypted connection)
# ssl on              # Enable SSL/TLS (use ldaps://)
# tls_reqcert hard    # Require valid certificate

EOF

# ─────────────────────────────────────────────────────────────────────────

# PRODUCTION CONFIGURATION (large company with HA)

cat > /etc/nslcd.conf << 'EOF'
# /etc/nslcd.conf - Production Configuration
# Company: TechCorp
# LDAP Servers: 3 servers for High Availability

# LDAP Server URIs (multiple for failover)
uri ldap://ldap1.company.com:389
uri ldap://ldap2.company.com:389
uri ldap://ldap3.company.com:389

# Base DN
base dc=company,dc=com

# Service account (dedicated read-only account for nslcd)
binddn cn=nslcd-service,ou=service-accounts,dc=company,dc=com
bindpw Secure!Pass#Word2024!

# Database-specific search paths
# Users in Engineering department
base passwd ou=employees,ou=engineering,dc=company,dc=com
base shadow ou=employees,ou=engineering,dc=company,dc=com

# All groups
base group ou=groups,dc=company,dc=com

# Hosts/servers
base hosts ou=infrastructure,ou=computers,dc=company,dc=com

# Search filters - be specific for better performance
filter passwd (&(objectClass=posixAccount)(!(pwdAccountLockedTime=*)))
#            ^ Only active users (not locked)
filter shadow (&(objectClass=shadowAccount)(uid=*))
filter group  (&(objectClass=posixGroup)(cn=*))
filter hosts  (&(objectClass=ipHost)(cn=*))

# Connection optimization
timelimit 30
bind_timelimit 10

# Caching - aggressive for production (reduces LDAP load)
cache passwd 7200    # Cache users for 2 hours
cache group  7200    # Cache groups for 2 hours
cache shadow 7200    # Cache shadow for 2 hours
cache hosts  7200    # Cache hosts for 2 hours

# Performance tuning
# pagesize 1000 results     # Return 1000 results per page

# SSL/TLS (RECOMMENDED for production)
uri ldaps://ldap1.company.com:636
uri ldaps://ldap2.company.com:636
uri ldaps://ldap3.company.com:636

ssl on
tls_cacertfile /etc/ldap/ca_cert.pem
tls_reqcert hard

# Logging
log syslog

EOF

# =============================================================================
# FILE 2: /etc/nsswitch.conf - Name Service Switch Configuration
# =============================================================================

# Location: /etc/nsswitch.conf
# Purpose: Tells Linux where to look for user/group/host information
# Syntax: database: source1 source2 source3

# SEARCH ORDER MEANINGS:
# files  - Look in local files (/etc/passwd, /etc/group, etc.)
# ldap   - Query LDAP server
# dns    - Query DNS
# nis    - Query NIS server
# db     - Local database
# compat - Compatibility (old /etc/passwd format)

# DEFAULT (before LDAP):
# ─────────────────────────
# passwd: files       <- Only local /etc/passwd
# group:  files       <- Only local /etc/group
# shadow: files       <- Only local /etc/shadow
# Result: LDAP users not recognized!

# ─────────────────────────────────────────────────────────────────────────

# BASIC LDAP CONFIGURATION (files first, then LDAP):

cat > /tmp/nsswitch-basic.conf << 'EOF'
# /etc/nsswitch.conf - Basic LDAP
# Order: 1. Check local files (fast), 2. Check LDAP (if not found)

passwd:         files ldap
shadow:         files ldap
group:          files ldap
hosts:          files dns
networks:       files
services:       files
protocols:      files
rpc:            files
ethers:         files
netmasks:       files
netgroup:       nis
publickey:      files
automount:      files ldap
aliases:        files

EOF

# ─────────────────────────────────────────────────────────────────────────

# PRODUCTION CONFIGURATION (optimized for speed):

cat > /tmp/nsswitch-production.conf << 'EOF'
# /etc/nsswitch.conf - Production Grade
# Optimized for performance and fallback

# passwd database - Check files, then LDAP
# [NOTFOUND=continue] = Skip LDAP if local lookup succeeds
# [UNAVAILABLE=continue] = Continue if LDAP is down
passwd:         files [NOTFOUND=continue] ldap [UNAVAILABLE=return]

# shadow database - Same logic
shadow:         files [NOTFOUND=continue] ldap [UNAVAILABLE=return]

# group database - Check files, then LDAP, cache results
group:          files [NOTFOUND=continue] ldap [UNAVAILABLE=return]

# Host database - DNS lookup required
hosts:          files resolve [!UNAVAIL=return] dns
# resolve = Use getaddrinfo (supports IPv4/IPv6)
# [!UNAVAIL=return] = Return if DNS unavailable (don't continue)

# Networks, services, protocols - local only
networks:       files
services:       files
protocols:      files
rpc:            files
ethers:         files
netmasks:       files

# Network groups via LDAP
netgroup:       ldap

# Public keys for SSH - LDAP
publickey:      ldap

# Automount - local and LDAP
automount:      files ldap

# Mail aliases
aliases:        files

EOF

# ─────────────────────────────────────────────────────────────────────────

# APPLY CONFIGURATION:

# Make backup first (CRITICAL - wrong config breaks login!)
sudo cp /etc/nsswitch.conf /etc/nsswitch.conf.bak

# Update passwd/group/shadow for LDAP
sudo sed -i.bak \
  -e 's/^passwd:.*/passwd:         files ldap/' \
  -e 's/^shadow:.*/shadow:         files ldap/' \
  -e 's/^group:.*/group:          files ldap/' \
  /etc/nsswitch.conf

# Verify changes
cat /etc/nsswitch.conf | grep -E "^(passwd|shadow|group):"

# Should show:
# passwd:         files ldap
# shadow:         files ldap
# group:          files ldap

# =============================================================================
# FILE 3: /etc/pam.d/common-password - PAM Password Configuration
# =============================================================================

# Location: /etc/pam.d/common-password
# Purpose: Configures password authentication (including LDAP)
# Required for: Users to login with LDAP password

# DEFAULT (without LDAP):

cat > /tmp/pam-passwd-default << 'EOF'
# /etc/pam.d/common-password
password    [success=1 default=ignore]  pam_unix.so obscure use_authtok try_first_pass yescrypt sha512 shadow
password    [success=1 default=ignore]  pam_lsass.so
password    requisite             pam_deny.so
password    required              pam_permit.so
password    required              pam_permit.so
password    optional              pam_gnome_keyring.so                          # pam_gnome_keyring.so
EOF

# ─────────────────────────────────────────────────────────────────────────

# WITH LDAP SUPPORT:

cat > /tmp/pam-passwd-ldap << 'EOF'
# /etc/pam.d/common-password - With LDAP
password    [success=1 default=ignore]  pam_unix.so obscure use_authtok try_first_pass yescrypt
password    [success=1 default=ignore]  pam_ldap.so use_authtok
password    requisite             pam_deny.so
password    required              pam_permit.so
EOF

# Note: libpam-ldapd package provides pam_ldap.so

# =============================================================================
# FILE 4: /etc/pam.d/common-auth - PAM Authentication
# =============================================================================

# Location: /etc/pam.d/common-auth
# Purpose: Configures user authentication (login, su, sudo, etc.)

# DEFAULT (local only):

cat > /tmp/pam-auth-default << 'EOF'
# /etc/pam.d/common-auth
auth    [success=1 default=ignore]      pam_unix.so nullok try_first_pass
auth    [success=1 default=ignore]      pam_lsass.so
auth    requisite             pam_deny.so
auth    required              pam_permit.so
EOF

# ─────────────────────────────────────────────────────────────────────────

# WITH LDAP SUPPORT:

cat > /tmp/pam-auth-ldap << 'EOF'
# /etc/pam.d/common-auth - With LDAP
auth    [success=1 default=ignore]      pam_unix.so nullok try_first_pass
auth    [success=1 default=ignore]      pam_ldap.so use_first_pass
auth    requisite             pam_deny.so
auth    required              pam_permit.so
EOF

# This allows authentication from both local and LDAP sources

# =============================================================================
# SECTION: TROUBLESHOOTING LDAP CONFIGURATION
# =============================================================================

# PROBLEM 1: "User exists, but can't login"

# Check 1: Is nslcd running?
sudo systemctl status nslcd
# Should show: Active: active (running)

# Check 2: Can system see LDAP user?
getent passwd alice
# Should show user info if LDAP is working

# Check 3: Is LDAP server reachable?
nc -zv 10.0.0.101 389
# Should show: Connection succeeded

# Check 4: Are /etc/nsswitch.conf and /etc/nslcd.conf correct?
cat /etc/nsswitch.conf | grep passwd
# Should have "ldap" in the line

cat /etc/nslcd.conf | grep "^uri\|^base"
# Should show correct LDAP server and base DN

# ─────────────────────────────────────────────────────────────────────────

# PROBLEM 2: "LDAP queries fail with 'Insufficient access rights'"

# Cause: binddn account doesn't have permission to read user data

# Solution 1: Verify bind credentials work
ldapsearch -x \
  -H ldap://10.0.0.101 \
  -D "cn=admin,dc=example,dc=com" \
  -w "admin_password" \
  -b "dc=example,dc=com" \
  "uid=alice"

# Solution 2: Create dedicated read-only service account on LDAP server
# (Ask LDAP administrator to do this)

# Solution 3: Update nslcd.conf with correct credentials and restart
sudo systemctl restart nslcd

# ─────────────────────────────────────────────────────────────────────────

# PROBLEM 3: "Login takes too long (nslcd queries LDAP every time)"

# Cause: Caching not configured

# Solution: Increase cache times in /etc/nslcd.conf
cache passwd 7200   # Cache for 2 hours instead of 60 seconds

# Also check /etc/nsswitch.conf has cache options:
grep "cache" /etc/nsswitch.conf
# Should have caching directives

# Restart nslcd to apply
sudo systemctl restart nslcd

# ─────────────────────────────────────────────────────────────────────────

# PROBLEM 4: "Startup is slow, LDAP server is down, but system still works"

# Good! This means failover is working (files are first in nsswitch.conf)

# To verify failover configuration:
cat /etc/nsswitch.conf | grep passwd
# Should show: passwd: files ldap
# This tries local /etc/passwd first!

# ─────────────────────────────────────────────────────────────────────────

# PROBLEM 5: "Can query LDAP manually but getent doesn't show users"

# Check 1: NSS filter might be too restrictive
grep "filter passwd" /etc/nslcd.conf

# Check 2: Try manual query with same filter
ldapsearch -x \
  -H ldap://10.0.0.101 \
  -D "cn=admin,dc=example,dc=com" \
  -w "admin_password" \
  -b "ou=people,dc=example,dc=com" \
  "(&(objectClass=posixAccount)(uid=alice))"

# If this returns nothing, user doesn't have correct objectClass

# Solution: Add posixAccount objectClass to user in LDAP
# (Ask LDAP administrator)

# ─────────────────────────────────────────────────────────────────────────

# PROBLEM 6: "getent passwd works but 'id alice' fails"

# Cause: PAM configuration not configured for LDAP authentication

# Solution: Configure/etc/pam.d/common-auth to include pam_ldap.so
# (As shown in previous section)

# Then users can login using LDAP password

# ─────────────────────────────────────────────────────────────────────────

# PROBLEM 7: "SSH login fails for LDAP users but 'su - alice' works"

# Cause: SSH needs session PAM configuration

# Solution: Check /etc/pam.d/sshd includes common-session
grep "common-session" /etc/pam.d/sshd
# Should show: @include common-session-noninteractive

# Ensure common-session has LDAP support:
cat /etc/pam.d/common-session | grep ldap
# Should show pam_ldap.so

# ─────────────────────────────────────────────────────────────────────────

# PROBLEM 8: "SSL/TLS connection failures"

# Error: "TLS negotiation failure" or "certificate verify failed"

# Check 1: Is cert file correct?
ls -la /etc/ldap/ca_cert.pem
# File should exist and be readable

# Check 2: Verify cert is valid
openssl x509 -in /etc/ldap/ca_cert.pem -text -noout

# Check 3: Temporarily disable cert verification to test connection
# Edit /etc/nslcd.conf:
# ssl start_tls
# tls_reqcert never     # Disable verification (test only!)

# Check 4: If it works with disabled verification, cert is the issue
# Get correct CA certificate from LDAP administrator

# ─────────────────────────────────────────────────────────────────────────

# DEBUGGING COMMANDS

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

# Shows how long query takes

# Check which library is being used for lookups
ldd /lib/x86_64-linux-gnu/libnss_ldap.so.2
# Shows dependencies

# Monitor nslcd socket communication
sudo strace -p $(pidof nslcd)
# Shows system calls (useful for timing/issues)

# =============================================================================
# QUICK REFERENCE: File Locations & Permissions
# =============================================================================

# /etc/nslcd.conf
# Owner: root
# Permissions: 600 (only root can read)
# Contains: LDAP server info and passwords - KEEP SECURE!

# /etc/nsswitch.conf  
# Owner: root
# Permissions: 644 (world readable)
# Contains: Where to look up user/group info

# /etc/pam.d/common-auth
# Contains: Authentication configuration (local and LDAP)

# /etc/pam.d/common-password
# Contains: Password configuration (change password)

# /etc/pam.d/common-session
# Contains: Session setup after login

# /var/run/nslcd.sock
# Runtime socket for nslcd daemon
# Created automatically when nslcd starts

# ─────────────────────────────────────────────────────────────────────────

# Correct permissions for nslcd.conf (IMPORTANT!):
sudo chown root:nslcd /etc/nslcd.conf
sudo chmod 640 /etc/nslcd.conf

# This allows nslcd daemon to read passwords but prevents other users

# =============================================================================
# CONFIGURATION VALIDATION CHECKLIST
# =============================================================================

# [ ] /etc/nslcd.conf exists and is readable by nslcd
# [ ] LDAP server URI is correct: uri ldap://[IP]:389
# [ ] Base DN is valid: base dc=example,dc=com  
# [ ] Bind DN has LDAP read permissions
# [ ] Bind password is correct
# [ ] /etc/nsswitch.conf has ldap in passwd/shadow/group
# [ ] nslcd service is running: systemctl status nslcd
# [ ] ldapsearch works: ldapsearch -x -H ldap://[IP] -b [BASE_DN]
# [ ] getent shows LDAP users: getent passwd [username]
# [ ] PAM configured if password login needed
# [ ] SSL/TLS working if required for production
# [ ] Caching configured for performance
# [ ] Firewall allows port 389 (or 636 for LDAPS)
# [ ] NTP/time is synchronized (LDAP can fail if time skewed)

################################################################################
# END OF CONFIGURATION REFERENCE
################################################################################

