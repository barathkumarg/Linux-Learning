#!/bin/bash

# Run Levels in Linux
# Reference: 1_Basic_commands.md and 6_Booting_&_kernel.md

# ============ Run Levels Description ============
# 0 - System halt (safely power off)
# 1 - Single user mode
# 2 - Multiple user mode with no NFS
# 3 - Multiple user CLI (no GUI)
# 4 - User-definable
# 5 - Multiple user mode with GUI (default for most Linux systems)
# 6 - Reboot the system

# ============ Get Current Run Level ============
# Display the current run level (target)
systemctl get-default

# ============ Set Run Level ============
# Set to graphical mode (GUI) - runlevel 5
systemctl set-default graphical.target

# Set to multi-user mode (CLI) - runlevel 3
systemctl set-default multi-user.target

# Set to rescue mode - runlevel 1
systemctl set-default rescue.target

# ============ Runlevel Targets Mapping ============
# graphical.target = runlevel 5 (GUI)
# multi-user.target = runlevel 3 (CLI)
# rescue.target = runlevel 1 (Single user)
# poweroff.target = runlevel 0 (Halt)
# reboot.target = runlevel 6 (Reboot)

# ============ Change Run Level Temporarily ============
# Switch to rescue mode (doesn't persist after reboot)
# sudo systemctl rescue

# Switch to emergency mode
# sudo systemctl emergency

# ============ Related Commands ============

# Get all available targets
systemctl list-units --type=target

# Check what the default target is
cat /etc/systemd/system/default.target

echo "Run level management examples completed!"
