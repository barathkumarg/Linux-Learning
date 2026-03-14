## Table of Contents

- [What is SELinux?](#what-is-selinux)
- [Why Do We Need SELinux?](#why-do-we-need-selinux)
- [SELinux Modes Explained](#selinux-modes-explained)
- [Core Concepts](#core-concepts)
- [Installation & Setup](#installation--setup)
- [Practical Commands](#practical-commands)
- [Production Use Cases](#production-use-cases)
- [Common Issues & Troubleshooting](#common-issues--troubleshooting)

---

## What is SELinux?

**SELinux (Security Enhanced Linux)** is a mandatory access control (MAC) security mechanism that adds an additional security layer to the Linux kernel. 

### In Simple Terms:
Traditional Linux uses **Discretionary Access Control (DAC)**, which works like:
- A file owner decides who can access their files
- Once a user has access, they can do whatever they want with that file

**SELinux changes this** by using **Context-Based Access Control**:
- The system itself decides what each program can do
- Even if a user has permission to a file, a program may not be allowed to access it
- Example: A web server (Apache) cannot read user home directories, even if technical permissions allow it

### Real-World Analogy:
- **Without SELinux**: You give a physical key to someone. They can use it however they want.
- **With SELinux**: You give a key labeled "Cashier" to someone. They can ONLY use it at the cashier desk, nowhere else.

---

## Why Do We Need SELinux?

### The Problem:
```
Scenario: A web server gets hacked by an attacker
Without SELinux:
  ├─ Attacker gains web server process access
  ├─ Can read /etc/shadow (password file)
  ├─ Can access user home directories
  ├─ Can modify system files
  └─ Full system compromise!

With SELinux:
  ├─ Attacker gains web server process access
  ├─ Still cannot read /etc/shadow
  ├─ Cannot access user home directories  
  ├─ Cannot modify system files
  └─ Damage is LIMITED to web server context!
```

### Key Benefits:
1. **Principle of Least Privilege** - Each program gets only the minimum permissions needed
2. **Containment** - If one service is compromised, damage is limited
3. **Audit Trail** - Every access attempt is logged and can be reviewed
4. **Consistency** - Policies apply uniformly across the system

---

## SELinux Modes Explained

### Mode Comparison Table

| Mode | Enforcement | Logging | Use Case |
|------|------------|---------|----------|
| **Enforcing** | ✅ Yes | ✅ Yes | Production systems, high security |
| **Permissive** | ❌ No | ✅ Yes | Testing, policy development, troubleshooting |
| **Disabled** | ❌ No | ❌ No | Emergency troubleshooting only |

### 1. **Enforcing Mode** (Default - Most Secure)

**What it does:**
- SELinux actively enforces all security policies
- Denies any action that violates the policy
- All denied actions are logged
- System operates at maximum security

**When to use:**
- ✅ Production servers (web servers, databases, mail servers)
- ✅ Company infrastructure
- ✅ Secure systems with critical data
- ❌ NOT for initial setup/learning

**Example Behavior:**
```
You try to: httpd process reads /etc/shadow file
SELinux says: "No! httpd_t cannot read shadow_t"
Result: Access DENIED, error logged
```

### 2. **Permissive Mode** (Less Secure - Monitor Only)

**What it does:**
- SELinux logs what WOULD be denied
- But doesn't actually deny access
- Useful for testing policies before enforcement

**When to use:**
- ✅ Learning environment
- ✅ Testing new policies
- ✅ Debugging application issues
- ✅ Troubleshooting production problems
- ❌ NOT for production deployment

**Example Behavior:**
```
You try to: httpd process reads /etc/shadow file
SELinux says: "This would normally be blocked..."
Result: Access ALLOWED, warning logged
```

### 3. **Disabled Mode** (Least Secure - No Protection)

**What it does:**
- SELinux is completely turned off
- No monitoring, no protection
- Falls back to standard Linux permissions

**When to use:**
- ⚠️ ONLY for emergency troubleshooting
- ⚠️ ONLY temporary debugging
- ❌ NEVER for production

**Example Behavior:**
```
You try to: httpd process reads /etc/shadow file
SELinux: (not running)
Result: Access depends only on standard file permissions
```

---

## Core Concepts

### Security Context Format

Every file and process in SELinux has a security context:
```
user:role:type:level
```

**Example:**
```bash
system_u:object_r:httpd_sys_content_t:s0
    ↑        ↑           ↑              ↑
  User    Role         Type           Level
```

### Component Meanings:

| Component | Purpose | Common Examples |
|-----------|---------|-----------------|
| **user** | Identity in SELinux | `system_u` (system), `user_u` (regular user), `root`, `unconfined_u` |
| **role** | Defines what the user can do | `system_r` (system role), `object_r` (for files), `staff_r` |
| **type** | Domain/type determining access | `httpd_t` (web server), `user_home_t` (user files), `shadow_t` (password file) |
| **level** | Security clearance (MLS) | `s0` (standard), `s0:c0.c1023` (multi-level) |

### Real File Example:

```bash
$ ls -Z /var/www/html/index.html
-rw-r--r-- root root system_u:object_r:httpd_sys_content_t:s0 /var/www/html/index.html
```

**What this means:**
- The file is owned by `root`
- It has the type `httpd_sys_content_t`
- Only processes with httpd context can read it (even if file permissions allow)

---

## Installation & Setup

### Step 1: Check if SELinux is Installed

```bash
# Check if SELinux is installed
which semanage

# If not found, it's not installed yet
```

### Step 2: Installation

**On CentOS/RHEL (Already included by default):**
```bash
# Install SELinux policy and tools
sudo yum install -y selinux-policy selinux-policy-devel selinux-policy-targeted
sudo yum install -y policycoreutils-python-utils
```

**On Ubuntu/Debian (Limited support):**
```bash
# SELinux is not standard, but can be installed
sudo apt-get update
sudo apt-get install -y apparmor apparmor-utils

# Note: Ubuntu uses AppArmor instead (similar concept)
```

**On Fedora (Recommended for learning):**
```bash
# SELinux is standard on Fedora
sudo dnf install -y selinux-policy selinux-policy-devel selinux-policy-targeted
sudo dnf install -y setroubleshoot-server
```

### Step 3: Verify Installation

```bash
# Check SELinux is working
getenforce

# Should output: Enforcing, Permissive, or Disabled
```

---

## Practical Commands

### 1. **Check SELinux Status**

```bash
# View complete SELinux status
sestatus
# Output shows:
# - Current mode (Enforcing/Permissive/Disabled)
# - Loaded policy
# - Policy state

# Show only current mode
getenforce
# Output: Enforcing

# View configuration file
cat /etc/selinux/config
```

### 2. **Change SELinux Mode (Temporary)**

```bash
# Switch to Permissive (allows but logs violations)
sudo setenforce 0

# Switch to Enforcing (blocks violations)
sudo setenforce 1

# This lasts until reboot!
```

### 3. **Change SELinux Mode (Permanent)**

```bash
# Edit configuration file
sudo nano /etc/selinux/config

# Find line: SELINUX=enforcing
# Change to:
SELINUX=permissive    # for testing
SELINUX=enforcing     # for production

# Save and exit (Ctrl+X, Y, Enter)

# Reboot to apply
sudo reboot
```

### 4. **View Security Contexts**

```bash
# View context of files
ls -Z
# Output: system_u:object_r:user_home_t:s0 file.txt

# View context of specific file
ls -Z /var/www/html/index.html

# View directory context
ls -Zd /var/www/html/

# View process contexts
ps auxZ | grep httpd
# Output shows: httpd_t context for web server processes
```

### 5. **Change File Context**

```bash
# Change context for a file
sudo chcon -t httpd_sys_content_t /var/www/html/index.html

# Change context recursively (entire directory)
sudo chcon -R -t httpd_sys_content_t /var/www/html/

# Change user and role
sudo chcon -u system_u -r object_r /var/www/html/index.html
```

### 6. **Restore Default Context**

```bash
# Restore to default context for a file
sudo restorecon /var/www/html/index.html

# Restore recursively for a directory
sudo restorecon -R /var/www/html/

# Restore with verbose output (show what's changing)
sudo restorecon -Rv /var/www/html/
```

### 7. **Check SELinux Policies**

```bash
# List all boolean policies
getsebool -a

# Check specific policy
getsebool httpd_can_network_connect

# Enable a policy
sudo setsebool httpd_can_network_connect on

# Make change permanent across reboots
sudo setsebool -P httpd_can_network_connect on

# View policy status
getsebool -a | grep httpd
```

### 8. **View Audit Logs**

```bash
# View SELinux denial logs
sudo tail -f /var/log/audit/audit.log

# Search for recent denials
sudo ausearch -m avc | tail -20

# Search for specific service denials
sudo ausearch -m avc -ts recent | grep httpd

# View in human-readable format
sudo ausearch -m avc -ts recent | audit2why
```

---

## Production Use Cases

### **Use Case 1: Securing a Web Server (Apache/Nginx)**

**Scenario:** You have a production web server that must:
- Serve files from `/var/www/html/`
- Cannot read `/etc/shadow` (even if compromised)
- Cannot access user home directories
- Can only write to `/var/tmp/` for temporary files

**Setup Steps:**
```bash
# 1. Set web server files to correct context
sudo chcon -R -t httpd_sys_content_t /var/www/html/
sudo chcon -R -t httpd_sys_rw_content_t /var/www/uploads/

# 2. Allow network connections if needed
sudo setsebool -P httpd_can_network_connect on

# 3. Allow connection to databases
sudo setsebool -P httpd_can_network_connect_db on

# 4. View what's protected
ls -Z /var/www/html/
ls -Z /etc/shadow

# 5. Test (in permissive first)
sudo setenforce 0
# ... test application ...

# 6. Switch to enforcing when verified
sudo setenforce 1
```

**Result:** 
- ✅ Web server works normally
- ✅ Even if hacked, attacker cannot read sensitive files
- ✅ Damage is limited to web content

---

### **Use Case 2: Running Custom Application with Limited Access**

**Scenario:** You have a custom Java application that needs:
- Read access to `/opt/myapp/config/`
- Write access to `/var/log/myapp/`
- NO access to system directories

**Setup Steps:**
```bash
# 1. Create context for application
sudo semanage fcontext -a -t user_tmp_t "/opt/myapp(/.*)?"

# 2. Apply context
sudo restorecon -R /opt/myapp/

# 3. Create policy for logs
sudo semanage fcontext -a -t user_tmp_t "/var/log/myapp(/.*)?"
sudo mkdir -p /var/log/myapp
sudo restorecon -R /var/log/myapp

# 4. Verify contexts
ls -Zd /opt/myapp
ls -Zd /var/log/myapp

# 5. Run application and monitor
sudo tail -f /var/log/audit/audit.log
```

---

### **Use Case 3: Database Server with Multiple Applications**

**Scenario:** PostgreSQL server with multiple applications accessing it. Each app should:
- Connect to PostgreSQL only
- Not access other application data
- Not read system files

**Setup Steps:**
```bash
# 1. Check PostgreSQL context
ps auxZ | grep postgres
# Output: system_u:system_r:postgresql_t:s0

# 2. Grant database connection to specific service
sudo setsebool -P postgresql_can_rsync on

# 3. Allow Apache to connect to PostgreSQL
sudo setsebool -P httpd_can_network_connect_db on

# 4. View active policies
getsebool -a | grep postgres

# 5. Test connections and log violations
sudo tail -f /var/log/audit/audit.log
```

---

### **Use Case 4: Troubleshooting in Production**

**Scenario:** Your application suddenly stops working after a system update

**Diagnosis Process:**
```bash
# 1. Temporary switch to permissive mode
sudo setenforce 0

# 2. Check if application works now
# If yes, it's an SELinux issue!

# 3. Check recent denials
sudo ausearch -m avc -ts recent

# 4. Convert to human-readable rules
sudo ausearch -m avc -ts recent | audit2why

# 5. Generate policy module for the issue
sudo audit2allow -a -M myapp_fix

# 6. Review generated policy before applying
cat myapp_fix.te

# 7. Install the policy
sudo semodule -i myapp_fix.pp

# 8. Return to enforcing
sudo setenforce 1

# 9. Test application
# If working, fix is complete!
```

---

## Common Issues & Troubleshooting

### Issue 1: Permission Denied Error After Installation

**Symptom:**
```
$ ls -l /root
Permission denied
```

**Cause:** SELinux context mismatch or incorrect permissions

**Solution:**
```bash
# Step 1: Check current mode
getenforce

# Step 2: Switch to permissive for troubleshooting
sudo setenforce 0

# Step 3: Check audit log
sudo tail -f /var/log/audit/audit.log

# Step 4: See what's being denied
sudo ausearch -m avc -ts recent | head -5

# Step 5: Analyze the denial
sudo ausearch -m avc -ts recent | audit2why

# Step 6: Let system fix it automatically
sudo audit2allow -a -M fix_issue
sudo semodule -i fix_issue.pp

# Step 7: Return to enforcing
sudo setenforce 1
```

---

### Issue 2: Web Server Can't Read Files

**Symptom:**
```
Apache/Nginx returns 403 Forbidden for valid files
```

**Cause:** Files have incorrect SELinux context

**Solution:**
```bash
# 1. Check current context
ls -Z /var/www/html/
# Output: system_u:object_r:user_home_t:s0 index.html
# ❌ This is user_home_t, not httpd_sys_content_t!

# 2. Fix the context
sudo chcon -t httpd_sys_content_t /var/www/html/index.html

# 3. Verify change
ls -Z /var/www/html/
# Output: system_u:object_r:httpd_sys_content_t:s0 index.html
# ✅ Correct!

# 4. Fix entire directory
sudo chcon -R -t httpd_sys_content_t /var/www/html/

# 5. Test access (refresh browser)
```

---

### Issue 3: Application Needs Permission It Doesn't Have

**Symptom:**
```
Application fails to connect to network/database
```

**Cause:** Boolean policy for that action is disabled

**Solution:**
```bash
# 1. Check what's being denied
sudo ausearch -m avc -ts recent | grep -i "your_app"

# 2. Convert to human format
sudo ausearch -m avc -ts recent | audit2why

# Output might say:
# SELinux policy prevents httpd_t from name_connect to port 3306

# 3. Find the boolean
getsebool -a | grep -i "network_connect"

# 4. Enable the boolean
sudo setsebool -P httpd_can_network_connect on

# 5. Verify
sudo setsebool -P httpd_can_network_connect_db on

# 6. Test application
```

---

### Issue 4: SELinux Blocking Valid Activity

**Systematic Troubleshooting Process:**

```bash
# Step 1: Document current issue
# Write down: What app? What error? When started?

# Step 2: Temporarily disable enforcement
sudo setenforce 0
echo "✓ Switched to Permissive Mode"

# Step 3: Reproduce the issue
# Try the operation that was failing

# Step 4: Check if it now works
# If YES: It's definitely SELinux!
# If NO: It's a different problem

# Step 5: View what would have been blocked
sudo ausearch -m avc -ts recent | tail -20

# Step 6: Analyze denials
sudo ausearch -m avc -ts recent | audit2why | head -10

# Step 7: Create appropriate policy
sudo audit2allow -a -M custom_policy

# Step 8: Install policy
sudo semodule -i custom_policy.pp

# Step 9: Return to Enforcing
sudo setenforce 1

# Step 10: Test again
# If working: Problem solved!
```

---

## Quick Reference Cheat Sheet

### Most Common Commands

```bash
# Check status
sestatus
getenforce

# View file contexts
ls -Z /path/to/file

# Change file context
sudo chcon -t new_type /path/to/file

# Restore to default
sudo restorecon /path/to/file

# Toggle enforcement (temporary)
sudo setenforce 0  # permissive
sudo setenforce 1  # enforcing

# View audit log
sudo tail -f /var/log/audit/audit.log

# Check policy
getsebool -a

# Enable policy
sudo setsebool -P policy_name on
```

---

