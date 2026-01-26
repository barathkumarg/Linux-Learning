#!/bin/bash

# File Permissions
# Reference: 1_Basic_commands.md

# ============ Symbolic Link Notation ============
# Grant rwx to user, rx to group, w to others
chmod u=rwx,g=rx,o=w file.txt

# ============ Absolute/Numeric Notation ============
# 752 means: user=rwx(7), group=rx(5), others=w(2)
chmod 752 file.txt

# ============ Permission Calculations ============
# Read (r) = 4
# Write (w) = 2
# Execute (x) = 1
# Sum them for each user category

# Default file permissions in Linux: rw-r--r-- (644)
# Default directory permissions in Linux: rwxr-xr-x (755)

# ============ Umask ============
# Umask determines the default permissions for newly created files
# Default umask: 0022
# To view current umask
umask

# To set umask (remove write permission for group and others)
umask 0022

# ============ Change File Ownership ============
# Change the owner of file
chown user filename

# Change the group of file
chgrp group filename

# Change both user and group
chown user:group filename

# Recursive change (for directories)
chown -R user:group directory

# ============ SUID (Set User ID) ============
# Allows users to run an executable with the permission of the executable's owner
# First digit should be 4 on chmod
chmod 4666 filename

# 's' indicates SUID enabled with execute permission
# 'S' indicates SUID enabled without execute permission

# ============ SGID (Set Group ID) ============
# Similar to SUID, but applies to both executables and directories
# Used for collaborating
chmod 2466 filename

# Find files with SUID or SGID permission enabled
find . -perm /6000

# ============ Sticky Bit ============
# Special permission that restricts file deletion in that directory
# First digit should be 1 on chmod
chmod 1777 directory

# Only the file owner can delete files in this directory
