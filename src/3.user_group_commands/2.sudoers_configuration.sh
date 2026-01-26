#!/bin/bash

# Sudoers Configuration and Management
# Reference: 3_User_&_Group_Adminstration.md

# IMPORTANT: Always edit sudoers file using visudo command!
# Direct editing can lock you out of sudo access

# ============ Viewing Sudoers ============

# View sudoers file (SAFE WAY)
sudo visudo

# View sudoers file without editing
sudo visudo -c

# View sudoers file content
sudo cat /etc/sudoers

# ============ Edit Sudoers ============

# Edit sudoers file safely (recommended)
sudo visudo

# Specify editor when editing sudoers
sudo EDITOR=nano visudo

# ============ Sudoers File Format ============

# Basic syntax:
# user_name/group_name HOST = (RUN_AS_USER:RUN_AS_GROUP) COMMANDS

# Example entries:
# Allow user 'john' to run all commands with sudo
# john ALL=(ALL) ALL

# Allow user 'john' to run specific commands without password
# john ALL=(ALL) NOPASSWD: /usr/bin/systemctl, /usr/bin/service

# Allow group 'sudo' to run all commands with password
# %sudo ALL=(ALL) ALL

# Allow user 'john' to run commands on specific host
# john host1=(ALL) ALL

# Allow user 'john' to run commands as specific user
# john ALL=(mysql) ALL

# ============ Sudoers Include Directory ============

# Include sudoers files from a directory
# This allows modular sudoers configuration
#@includedir /etc/sudoers.d

# ============ Create Custom Sudoers File ============

# Create a new sudoers file in /etc/sudoers.d/
# This is safer than editing main /etc/sudoers file
# sudo visudo -f /etc/sudoers.d/myuser

# ============ Sudo Without Password ============

# Add to sudoers (using visudo):
# username ALL=(ALL) NOPASSWD:ALL

# Or for specific commands:
# username ALL=(ALL) NOPASSWD:/usr/bin/systemctl

# ============ Check Sudo Privileges ============

# Check what commands current user can run with sudo
sudo -l

# Check sudoers entry for specific user
sudo -U username -l

# ============ Verify Sudoers Syntax ============

# Check if sudoers file has correct syntax
sudo visudo -c

# Check specific sudoers file
sudo visudo -c -f /etc/sudoers.d/myfile

# ============ Common Sudo Issues ============

# If sudoers is locked/broken:
# 1. Boot into recovery mode or use liveUSB
# 2. Mount filesystem and chroot
# 3. Use pkexec or become root another way
# 4. Fix /etc/sudoers permissions: chmod 0440 /etc/sudoers

echo "Sudoers configuration examples completed!"
