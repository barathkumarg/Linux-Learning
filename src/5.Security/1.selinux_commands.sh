#!/bin/bash

##############################################################################
# SELinux (Security Enhanced Linux) - Comprehensive Command Reference
# Reference: 5_Selinux_commands.md
# 
# SELinux adds mandatory access control (MAC) to Linux systems
# Each file/process has a security context: user:role:type:level
# This limits what programs can access, even if technical permissions allow
##############################################################################

echo "=========================================="
echo "SELinux Command Reference - Beginner Guide"
echo "=========================================="

# ============================================================================
# SECTION 1: INSTALLATION & VERIFICATION
# ============================================================================

echo -e "\n### SECTION 1: Installation & Verification ###\n"

# Check if SELinux tools are installed
echo "1. Checking if SELinux is installed..."
which semanage getenforce sestatus 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✓ SELinux tools found"
else
    echo "✗ SELinux tools not found - installation needed"
fi

# Installation commands (commented out - uncomment to run)

# On CentOS/RHEL:
# sudo yum install -y selinux-policy selinux-policy-devel
# sudo yum install -y policycoreutils-python-utils

# On Fedora:
# sudo dnf install -y selinux-policy selinux-policy-devel
# sudo dnf install -y setroubleshoot-server

# On Ubuntu/Debian:
# sudo apt-get install -y apparmor apparmor-utils
# Note: Ubuntu uses AppArmor instead of SELinux

# ============================================================================
# SECTION 2: CHECK SELinux STATUS
# ============================================================================

echo -e "\n### SECTION 2: Checking SELinux Status ###\n"

echo "2a. Complete status report:"
echo "$ sestatus"
# Displays:
# - Current mode (Enforcing/Permissive/Disabled)
# - Loaded policy
# - Policy state

echo -e "\n2b. Show only current mode:"
echo "$ getenforce"
# Output: Enforcing, Permissive, or Disabled

echo -e "\n2c. View SELinux configuration:"
echo "$ cat /etc/selinux/config"
# Shows the permanent SELinux configuration

# ============================================================================
# SECTION 3: UNDERSTAND SELinux SECURITY CONTEXT
# ============================================================================

echo -e "\n### SECTION 3: Security Contexts ###\n"

echo "3a. View file security contexts:"
echo "$ ls -Z"
# Example output: system_u:object_r:user_home_t:s0 myfile.txt
#                  ^       ^        ^               ^
#                  user    role     type            level

echo -e "\n3b. Context components:"
cat << 'EOF'
  Format: user:role:type:level
  
  - user:  SELinux user identity
    Examples: system_u, unconfined_u, user_u
  
  - role:  Role assigned to the user
    Examples: system_r, object_r, staff_r
  
  - type:  Domain defining what actions are allowed
    Common types:
    • httpd_t - Apache/Nginx web server
    • httpd_sys_content_t - Web server content files
    • user_home_t - User home directory files
    • shadow_t - Password files (/etc/shadow)
    • sysadm_t - System administrator
  
  - level: Security clearance (MLS - Multi-Level Security)
    Examples: s0, s0:c0.c1023
EOF

echo -e "\n3c. View context of specific file:"
echo "$ ls -Z /var/www/html/index.html"

echo -e "\n3d. View directory context:"
echo "$ ls -Zd /var/www/html/"

echo -e "\n3e. View process contexts:"
echo "$ ps auxZ | grep httpd"

# ============================================================================
# SECTION 4: SELINUX MODES - DETAILED
# ============================================================================

echo -e "\n### SECTION 4: SELinux Modes ###\n"

cat << 'EOF'
MODE COMPARISON:

1. ENFORCING MODE (Default - Most Secure)
   - Actively enforces all policies
   - Denies unauthorized access
   - Logs all violations
   - Use in: Production systems
   - Command: sudo setenforce 1

2. PERMISSIVE MODE (Testing Mode)
   - Logs what would be denied
   - But doesn't actually deny
   - Use in: Testing, troubleshooting, development
   - Command: sudo setenforce 0

3. DISABLED MODE (Emergency Only)
   - SELinux completely off
   - No monitoring, no protection
   - Use in: Emergency troubleshooting ONLY
   - Edit: /etc/selinux/config
   - SELINUX=disabled
EOF

# ============================================================================
# SECTION 5: CHANGING SELINUX MODES
# ============================================================================

echo -e "\n### SECTION 5: Changing SELinux Modes ###\n"

echo "5a. Temporary mode change (until reboot):"
echo "$ sudo setenforce 0    # Switch to Permissive"
echo "$ sudo setenforce 1    # Switch to Enforcing"

echo -e "\n5b. Permanent mode change (survives reboot):"
cat << 'EOF'
$ sudo nano /etc/selinux/config

Find line: SELINUX=enforcing
Change to:
  SELINUX=enforcing  # for production
  SELINUX=permissive # for testing
  SELINUX=disabled   # for emergency only

Then reboot:
$ sudo reboot
EOF

# ============================================================================
# SECTION 6: MANAGING FILE CONTEXTS
# ============================================================================

echo -e "\n### SECTION 6: Managing File Contexts ###\n"

echo "6a. View file context:"
echo "$ ls -Z /path/to/file"

echo -e "\n6b. Change file context (temporary until reboot):"
echo "$ sudo chcon -t httpd_sys_content_t /var/www/html/index.html"

echo -e "\n6c. Change context recursively (entire directory):"
echo "$ sudo chcon -R -t httpd_sys_content_t /var/www/html/"

echo -e "\n6d. Change user and role together:"
echo "$ sudo chcon -u system_u -r object_r -t httpd_sys_content_t /path/to/file"

echo -e "\n6e. Restore to default context (from policy):"
echo "$ sudo restorecon /var/www/html/index.html"

echo -e "\n6f. Restore recursively with verbose output:"
echo "$ sudo restorecon -Rv /var/www/html/"

# ============================================================================
# SECTION 7: SELINUX POLICIES & BOOLEANS
# ============================================================================

echo -e "\n### SECTION 7: SELinux Policies ###\n"

echo "7a. List all policy booleans:"
echo "$ getsebool -a"
# Shows all policies that can be toggled

echo -e "\n7b. Check specific policy status:"
echo "$ getsebool httpd_can_network_connect"
# Output: httpd_can_network_connect --> off

echo -e "\n7c. Enable policy (temporary until reboot):"
echo "$ sudo setsebool httpd_can_network_connect on"

echo -e "\n7d. Make policy change permanent:"
echo "$ sudo setsebool -P httpd_can_network_connect on"

echo -e "\n7e. View only httpd-related policies:"
echo "$ getsebool -a | grep httpd"

# ============================================================================
# SECTION 8: AUDIT LOGS & TROUBLESHOOTING
# ============================================================================

echo -e "\n### SECTION 8: Audit Logs & Troubleshooting ###\n"

echo "8a. View live SELinux denial log:"
echo "$ sudo tail -f /var/log/audit/audit.log"

echo -e "\n8b. Search recent denials:"
echo "$ sudo ausearch -m avc -ts recent"

echo -e "\n8c. Find denials for specific service:"
echo "$ sudo ausearch -m avc -ts recent | grep httpd"

echo -e "\n8d. Convert denials to human-readable format:"
echo "$ sudo ausearch -m avc -ts recent | audit2why"

echo -e "\n8e. Get suggested policies to fix issues:"
echo "$ sudo audit2allow -a"

echo -e "\n8f. Generate AND install policy automatically:"
echo "$ sudo audit2allow -a -M myapp_policy"
echo "$ sudo semodule -i myapp_policy.pp"

# ============================================================================
# SECTION 9: PRODUCTION USE CASES
# ============================================================================

echo -e "\n### SECTION 9: Production Use Cases ###\n"

cat << 'EOF'
USE CASE 1: Secure Web Server
================================
Problem: Apache must serve web content but cannot access system files
  
Setup:
$ sudo chcon -R -t httpd_sys_content_t /var/www/html/
$ sudo chcon -R -t httpd_sys_rw_content_t /var/www/uploads/
$ sudo setsebool -P httpd_can_network_connect on
$ sudo setsebool -P httpd_can_network_connect_db on

Verification:
$ ls -Z /var/www/html/
$ setsebool -a | grep httpd

Benefits:
✓ Web server can't read /etc/shadow even if hacked
✓ Attack limited to web directories only
✓ Attackers can't modify system files


USE CASE 2: Custom Application Isolation
==========================================
Problem: Custom Java app should only read config, write logs

Setup:
$ sudo semanage fcontext -a -t user_tmp_t "/opt/myapp(/.*)?"
$ sudo restorecon -R /opt/myapp/
$ sudo mkdir -p /var/log/myapp
$ sudo chcon -t user_tmp_t /var/log/myapp

Verification:
$ ls -Zd /opt/myapp
$ ls -Zd /var/log/myapp

Benefits:
✓ App can only access its own directories
✓ Cannot read other application data
✓ Cannot modify system files


USE CASE 3: Database Server Protection
========================================
Problem: PostgreSQL must not allow unauthorized access

Setup:
$ sudo setsebool -P postgresql_can_rsync on
$ sudo setsebool -P httpd_can_network_connect_db on

Verification:
$ getsebool -a | grep postgres
$ ps auxZ | grep postgres

Benefits:
✓ Database only accessible to authorized apps
✓ Apps cannot bypass database to read files
✓ Audit trail of all access attempts
EOF

# ============================================================================
# SECTION 10: TROUBLESHOOTING WORKFLOW
# ============================================================================

echo -e "\n### SECTION 10: Troubleshooting Workflow ###\n"

cat << 'EOF'
PROBLEM: "Permission Denied" after SELinux changes

STEP 1: Check current mode
$ getenforce
Expected: Enforcing or Permissive

STEP 2: Switch to Permissive for testing
$ sudo setenforce 0

STEP 3: Try the failing operation again
Does it work now? 
  YES → It's an SELinux issue, continue
  NO  → It's a different problem, check permissions

STEP 4: View what was blocked
$ sudo ausearch -m avc -ts recent | head -10

STEP 5: Understand the denial
$ sudo ausearch -m avc -ts recent | audit2why

Output might say:
  "SELinux policy prevents httpd_t from read to shadow_t"

STEP 6: Fix the issue

Option A - Change file context:
  $ sudo chcon -t httpd_sys_content_t /path/to/file
  
Option B - Enable policy boolean:
  $ sudo getsebool -a | grep -i network
  $ sudo setsebool -P httpd_can_network_connect on
  
Option C - Generate custom policy:
  $ sudo audit2allow -a -M myfix
  $ sudo semodule -i myfix.pp

STEP 7: Verify fix works in Permissive
Test your application thoroughly

STEP 8: Return to Enforcing
$ sudo setenforce 1

STEP 9: Test in Enforcing mode
Does everything still work?
  YES → Change is permanent!
  NO  → Debug further
EOF

# ============================================================================
# SECTION 11: QUICK REFERENCE / CHEAT SHEET
# ============================================================================

echo -e "\n### SECTION 11: Quick Reference ###\n"

cat << 'EOF'
MOST IMPORTANT COMMANDS:

Check Status:
  sestatus              # Full status report
  getenforce            # Current mode
  
View Contexts:
  ls -Z                 # File contexts
  ls -Zd /dir/          # Directory context
  ps auxZ | grep app    # Process context
  
Change Contexts:
  sudo chcon -t TYPE FILE                    # Change type
  sudo chcon -R -t TYPE /dir/                # Recursive
  sudo restorecon /file                      # Restore default
  sudo restorecon -R /dir/                   # Restore directory
  
Manage Policies:
  getsebool -a          # List all policies
  setsebool -P BOOL on  # Enable policy (permanent)
  
Mode Changes:
  sudo setenforce 0     # Permissive (temporary)
  sudo setenforce 1     # Enforcing (temporary)
  
Troubleshooting:
  sudo tail -f /var/log/audit/audit.log      # Live audit log
  sudo ausearch -m avc -ts recent            # Recent denials
  sudo ausearch -m avc -ts recent | audit2why # Why denied
  sudo audit2allow -a -M policy              # Generate policy
  sudo semodule -i policy.pp                 # Install policy
EOF

# ============================================================================
# SECTION 12: COMMON SCENARIOS & SOLUTIONS
# ============================================================================

echo -e "\n### SECTION 12: Common Scenarios ###\n"

cat << 'EOF'
SCENARIO 1: Web server returns 403 Forbidden
============================================
Problem: Apache can't read website files
$ ls -Z /var/www/html/
Output: system_u:object_r:user_home_t:s0 index.html  ❌ Wrong!

Solution:
$ sudo chcon -R -t httpd_sys_content_t /var/www/html/
$ ls -Z /var/www/html/
Output: system_u:object_r:httpd_sys_content_t:s0 index.html  ✓ Correct!


SCENARIO 2: Application can't connect to database
====================================================
Problem: App fails when trying to reach PostgreSQL
$ sudo ausearch -m avc -ts recent | grep postgres

Solution:
$ sudo setsebool -P httpd_can_network_connect_db on
$ sudo setsebool -P httpd_can_network_connect on


SCENARIO 3: Service works in Permissive but fails in Enforcing
=============================================================
Problem: Indicates SELinux policy is missing or wrong

Solution:
$ sudo audit2allow -a -M fix_service
$ sudo semodule -i fix_service.pp
$ sudo setenforce 1


SCENARIO 4: Too many audit logs, performance impact
======================================================
Problem: /var/log/audit/audit.log growing too fast

Solution:
$ sudo ausearch -m avc -ts recent | audit2why
$ Fix the issues (change contexts, enable policies)
$ Or disable unwanted rules (temporary until fixed)
EOF

# ============================================================================
# SECTION 13: BEST PRACTICES
# ============================================================================

echo -e "\n### SECTION 13: Best Practices ###\n"

cat << 'EOF'
1. LEARNING & TESTING
   ✓ Start in Permissive mode
   ✓ Make changes gradually
   ✓ Test before moving to Enforcing
   ✓ Keep audit logs for reference

2. PRODUCTION DEPLOYMENT
   ✓ Use Enforcing mode
   ✓ Set up proper policies before enabling
   ✓ Monitor audit logs regularly
   ✓ Have rollback plan (switch to Permissive)

3. TROUBLESHOOTING
   ✓ Switch to Permissive mode first
   ✓ Check audit logs before making changes
   ✓ Use audit2why to understand denials
   ✓ Test fixes in Permissive mode
   ✓ Only then enable in Enforcing

4. MAINTENANCE
   ✓ Review audit logs regularly
   ✓ Remove unused custom policies
   ✓ Keep policies documented
   ✓ Test policy changes before rolling out

5. SECURITY
   ✓ Use context-based access, not just file permissions
   ✓ Apply principle of least privilege
   ✓ Use MLS levels for sensitive systems
   ✓ Audit all access attempts
EOF

echo -e "\n=========================================="
echo "SELinux Examples Completed!"
echo "=========================================="

