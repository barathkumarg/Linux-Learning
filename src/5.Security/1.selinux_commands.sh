#!/bin/bash

# SELinux (Security Enhanced Linux) Commands
# Reference: 5_Selinux_commands.md

# SELinux is a special security system that limits permissions for programs and users

# ============ Installation ============

# Install SELinux on Debian/Ubuntu
sudo apt-get install selinux

# Install SELinux on CentOS/RHEL
sudo yum install selinux-policy selinux-policy-devel

# ============ Check SELinux Status ============

# View SELinux config file
cat /etc/selinux/config

# Check current SELinux status
sestatus

# Check current SELinux mode
getenforce

# ============ SELinux Modes ============

# 1. Enforcing - Default and most secure
#    SELinux actively enforces policy rules
#    Denies unauthorized access attempts and logs them

# 2. Permissive - Less secure but still monitors
#    SELinux logs what would be blocked but doesn't actually block it
#    Useful for testing and troubleshooting

# 3. Disabled - Completely turned off
#    Removes all access protection
#    Only for troubleshooting

# ============ Change SELinux Mode ============

# Set to permissive mode (0)
sudo setenforce 0

# Set to enforcing mode (1)
sudo setenforce 1

# This change is temporary (until reboot)

# ============ Permanent Mode Change ============

# Edit the SELinux config file
sudo nano /etc/selinux/config

# Change SELINUX parameter to:
# SELINUX=enforcing (for Enforcing)
# SELINUX=permissive (for Permissive)
# SELINUX=disabled (for Disabled)

# Reboot for changes to take effect
sudo reboot

# ============ SELinux Policy Commands ============

# View loaded policy
getsebool -a

# Set a boolean policy
sudo setsebool httpd_can_network_connect on

# Make boolean policy change permanent
sudo setsebool -P httpd_can_network_connect on

# ============ SELinux Context Commands ============

# View file context
ls -Z

# View directory context
ls -Zd /

# Change file context
sudo chcon -t httpd_sys_content_t /var/www/html/file.html

# Restore default context
sudo restorecon /var/www/html/

# Restore context recursively
sudo restorecon -R /var/www/html/

# ============ SELinux Audit and Logging ============

# Check audit logs
sudo tail -f /var/log/audit/audit.log

# View recent SELinux denials
sudo ausearch -m avc | tail -20

# Search for specific denials
sudo ausearch -m avc -ts recent | grep httpd

# ============ Troubleshooting SELinux Issues ============

# Generate policy from audit log
sudo audit2allow -a

# Generate and install policy
sudo audit2allow -a -M mymodule
sudo semodule -i mymodule.pp

# ============ SELinux Contexts ============

# SELinux contexts have format: user:role:type:level

# Common context types:
# httpd_sys_content_t - Web server content
# user_home_t - User home directory
# user_tmp_t - User temporary files
# admin_home_t - Admin home directory

# ============ Quick Troubleshooting ============

# If SELinux is blocking something:
# 1. Check audit logs: sudo tail -f /var/log/audit/audit.log
# 2. Temporarily set to permissive: sudo setenforce 0
# 3. Generate policy: sudo audit2allow -a -M mymodule
# 4. Install policy: sudo semodule -i mymodule.pp
# 5. Return to enforcing: sudo setenforce 1

echo "SELinux command examples completed!"
