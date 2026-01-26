#!/bin/bash

# Swap Space Management
# Reference: 2_File_systems.md

# Swap Memory: Virtual memory extension of physical RAM
# Helps maintain system stability when RAM is fully used

# ============ Create Swap Space ============

# Step 1: Create a file for swap
sudo dd if=/dev/zero of=/swapfile bs=1G count=4

# Step 2: Set appropriate permissions
sudo chmod 600 /swapfile

# Step 3: Format the file as swap
sudo mkswap /swapfile

# Step 4: Enable the swap
sudo swapon /swapfile

# ============ Verify Swap ============

# Check if swap is enabled
swapon --show

# Or check using free command
free -h

# Check swap space in detail
cat /proc/swaps

# ============ Make Swap Permanent ============

# Add to /etc/fstab so it persists after reboot
# First, get the UUID of the swap file
sudo blkid /swapfile

# Then add this line to /etc/fstab:
# /swapfile none swap sw 0 0

# ============ Disable Swap ============

# Disable specific swap space
sudo swapoff /swapfile

# Remove swap file
sudo rm /swapfile

# ============ Swap on Partition ============

# Create a new partition (using fdisk or parted)
# Set partition type to 82 (Linux Swap)

# Format partition as swap
sudo mkswap /dev/sdXY

# Enable swap on partition
sudo swapon /dev/sdXY

# ============ Swap Optimization ============

# Adjust swappiness (0-100, default is 60)
# Higher value = more likely to use swap
cat /proc/sys/vm/swappiness

# Set swappiness to 10 (prefer RAM over swap)
sudo sysctl vm.swappiness=10

# Make it permanent by editing /etc/sysctl.conf
# Add: vm.swappiness=10

echo "Swap space management examples completed!"
