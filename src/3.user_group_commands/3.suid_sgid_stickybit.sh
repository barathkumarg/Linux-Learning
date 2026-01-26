#!/bin/bash

# SUID, SGID, and Sticky Bit Permissions
# Reference: 3_User_&_Group_Adminstration.md

# ============ SUID (Set User ID) ============
# Special permission that allows users to run an executable 
# with the permission of the executable's owner

# Set SUID on a file
chmod 4755 filename

# Or using symbolic notation
chmod u+s filename

# First digit in chmod should be 4 for SUID
chmod 4666 filename

# 's' in output indicates SUID enabled with execute permission
# 'S' indicates SUID enabled WITHOUT execute permission
# Example output: -rwsr-xr-x

# Remove SUID
chmod u-s filename

# ============ SGID (Set Group ID) ============
# Similar to SUID, but applies to both executables and directories
# Used for collaboration - files inherit directory's group

# Set SGID on a file
chmod 2755 filename

# Or using symbolic notation
chmod g+s filename

# Set SGID on a directory (files inherit directory's group)
chmod g+s directory/

# First digit should be 2 for SGID
chmod 2466 filename

# 's' indicates SGID enabled with execute permission
# 'S' indicates SGID enabled WITHOUT execute permission
# Example output: -rwxr-sr-x

# Remove SGID
chmod g-s filename

# ============ Sticky Bit ============
# Special permission that restricts file deletion in a directory
# Only file owner can delete files (even if others have write permission)
# Common on /tmp directory

# Set sticky bit on a directory
chmod 1777 directory/

# Or using symbolic notation
chmod o+t directory/

# First digit should be 1 for sticky bit
chmod 1755 directory/

# 't' in output indicates sticky bit enabled with execute permission
# 'T' indicates sticky bit enabled WITHOUT execute permission
# Example output: drwxrwxrwt

# Remove sticky bit
chmod o-t directory/

# ============ Combined Special Permissions ============

# Set all three permissions together
# 4 (SUID) + 2 (SGID) + 1 (Sticky) = 7777
chmod 7755 filename

# ============ Find Files with Special Permissions ============

# Find files with SUID permission
find / -perm /4000 2>/dev/null

# Find files with SGID permission
find / -perm /2000 2>/dev/null

# Find files with sticky bit
find / -perm /1000 2>/dev/null

# Find files with SUID or SGID
find . -perm /6000

# Find SUID and SGID files recursively in current directory
find . -perm -4000 -o -perm -2000

# ============ Examples ============

# Make a script run with user 'root' privileges
# chmod 4755 /usr/local/bin/my_script.sh

# Set directory so new files belong to group
# chmod g+s /shared/project/

# Make /tmp world-writable but prevent deletion
# chmod 1777 /tmp

# ============ View Special Permissions ============

# List files with detailed permissions
ls -la

# Display in long format showing special permissions
ls -lah

# Check permissions of specific file
stat filename

echo "Special permissions examples completed!"
