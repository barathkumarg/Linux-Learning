#!/bin/bash

# Booting & Kernel Information
# Reference: 6_Booting_&_kernel.md

# ============ Booting Process Components ============
# 1. BIOS - Checks system integrity and loads MBR
# 2. MBR - Master Boot Record (located in first disk sector)
# 3. GRUB - Grand Unified Boot Loader (selects kernel)
# 4. Kernel - Core of the OS
# 5. Init - First process (PID: 1)

# ============ Check Kernel Information ============

# Get kernel name/type
uname -r

# Get detailed kernel information
uname -a

# Check kernel version
cat /proc/version

# ============ View GRUB Configuration ============

# GRUB configuration file
cat /boot/grub/grub.cfg

# GRUB custom configuration
cat /boot/grub/grub.conf

# ============ Kernel Files ============

# View available kernels
ls -la /boot/

# Check current kernel
uname -r

# ============ Boot Process Related Commands ============

# View boot messages
dmesg

# View recent boot messages
dmesg | tail -20

# Search for specific boot message
dmesg | grep -i usb

# View system startup logs
sudo journalctl -b

# View specific boot
sudo journalctl --list-boots

# ============ Kernel Parameters ============

# View all kernel parameters
cat /proc/cmdline

# View mounted filesystems
mount | grep -E "^/dev"

# ============ Init System Information ============

# Check current init system
ps -p 1 -o comm=

# View systemd status
systemctl status

# View system targets (runlevels)
systemctl list-units --type=target

# ============ Initrd Information ============

# initrd is temporary RAM disk used during boot
# Lists content of initrd
lsinitrd

# Extract initrd
cd /tmp && lsinitrd -f /boot/initrd.img-$(uname -r)

# ============ Grub Boot Options ============

# Edit grub during boot:
# 1. At grub menu, press 'e' to edit
# 2. Navigate to kernel line
# 3. Edit parameters (e.g., add 'single' for single-user mode)
# 4. Press Ctrl+x to boot with new parameters

# ============ Grub Recovery ============

# If GRUB is broken, boot into recovery mode:
# 1. Restart system
# 2. Hold Shift during boot
# 3. Select recovery kernel option
# 4. Use grub-install to reinstall GRUB

# Reinstall GRUB (from recovery/live environment)
# sudo grub-install /dev/sda
# sudo update-grub

# ============ Kernel Module Information ============

# List loaded kernel modules
lsmod

# Load a kernel module
sudo modprobe module_name

# Unload a kernel module
sudo modprobe -r module_name

# Check module information
modinfo module_name

# ============ Boot Parameters ============

# Common kernel boot parameters:
# root=/dev/sda1 - Root filesystem
# ro - Mount read-only initially
# rw - Mount read-write
# single - Single user mode
# quiet - Suppress boot messages
# splash - Show splash screen

# ============ Systemd Boot (Alternative to GRUB) ============

# Check if using systemd-boot
ls /boot/EFI/BOOT/

# ============ Check System Boot Time ============

# View detailed boot time
systemd-analyze

# View time spent in each service
systemd-analyze blame

# View boot process as graph
systemd-analyze plot > /tmp/boot.svg

echo "Booting and kernel information examples completed!"
