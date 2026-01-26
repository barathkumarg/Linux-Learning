#!/bin/bash

# SSH - Secure Shell Commands
# Reference: 7_ssh.md

# SSH provides secure remote connection to servers
# Replaces Telnet (which is unencrypted and insecure)

# ============ Installation ============

# Install SSH server (sshd) on Ubuntu/Debian
sudo apt-get install openssh-server

# Install SSH client
sudo apt-get install openssh-client

# Start SSH service
sudo systemctl start ssh

# Enable SSH on boot
sudo systemctl enable ssh

# ============ Basic SSH Connection ============

# Connect to remote server
ssh username@ip_address

# Connect to remote server with specific port
ssh -p 2222 username@ip_address

# Connect and execute command
ssh username@ip_address "ls -la /home"

# Connect with verbose output (debugging)
ssh -vvv username@ip_address

# ============ SSH Key Pair Generation ============

# Generate SSH key pair (creates id_rsa and id_rsa.pub)
ssh-keygen

# Generate with specific name
ssh-keygen -f ~/.ssh/custom_key

# Generate with 4096-bit RSA key
ssh-keygen -b 4096

# Generate with Ed25519 (more secure)
ssh-keygen -t ed25519

# ============ Copy Public Key to Remote Server ============

# Copy public key (passwordless login setup)
ssh-copy-id -i ~/.ssh/id_rsa.pub username@ip_address

# Copy using specific port
ssh-copy-id -i ~/.ssh/id_rsa.pub -p 2222 username@ip_address

# Manual copy (if ssh-copy-id not available)
cat ~/.ssh/id_rsa.pub | ssh username@ip_address "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

# ============ Verify Public Key Installation ============

# Check authorized_keys on remote server
cat ~/.ssh/authorized_keys

# Check locally what keys are authorized
ssh -i ~/.ssh/id_rsa username@ip_address

# ============ SSH Config File ============

# Create/edit SSH config
mkdir -p ~/.ssh
nano ~/.ssh/config

# SSH Config Example:
# Host myserver
#     HostName 192.168.1.100
#     User username
#     Port 22
#     IdentityFile ~/.ssh/id_rsa
#     IdentitiesOnly yes

# Set proper permissions on config
chmod 600 ~/.ssh/config

# Use config entry to connect
ssh myserver

# ============ SSH Key Management ============

# Start SSH agent
eval "$(ssh-agent -s)"

# Add key to agent
ssh-add ~/.ssh/id_rsa

# List keys in agent
ssh-add -l

# Remove key from agent
ssh-add -d ~/.ssh/id_rsa

# Remove all keys from agent
ssh-add -D

# ============ SSH Agent Forwarding ============

# Enable agent forwarding in SSH config
# Host myserver
#     ForwardAgent yes

# Or use command line
ssh -A username@ip_address

# ============ Port Forwarding ============

# Forward local port to remote port
ssh -L 8080:localhost:80 username@ip_address

# Forward remote port to local port (reverse)
ssh -R 8080:localhost:80 username@ip_address

# ============ SSHFS - SSH File System ============

# Mount remote directory via SSH
sshfs username@ip_address:/remote/path /local/mount/point

# Unmount SSHFS
fusermount -u /local/mount/point

# ============ SCP - Secure Copy ============

# Copy file from remote to local
scp username@ip_address:/remote/path/file.txt /local/path/

# Copy file from local to remote
scp /local/path/file.txt username@ip_address:/remote/path/

# Copy directory recursively
scp -r username@ip_address:/remote/dir /local/path/

# ============ Rsync over SSH ============

# Sync files from remote to local
rsync -av -e ssh username@ip_address:/remote/path/ /local/path/

# Sync files from local to remote
rsync -av -e ssh /local/path/ username@ip_address:/remote/path/

# Delete extra files on destination
rsync -av --delete -e ssh /local/path/ username@ip_address:/remote/path/

# ============ SSH Security Best Practices ============

# Disable root login
# Edit /etc/ssh/sshd_config
# PermitRootLogin no

# Change default SSH port
# Port 2222

# Use public key authentication only
# PubkeyAuthentication yes
# PasswordAuthentication no

# Disable password authentication
# PasswordAuthentication no

# Allow specific users
# AllowUsers username1 username2

# Disable X11 forwarding (if not needed)
# X11Forwarding no

# Set client alive interval to prevent timeout
# ClientAliveInterval 300
# ClientAliveCountMax 2

# Restart SSH after changes
sudo systemctl restart ssh

# ============ SSH Connection Troubleshooting ============

# Test SSH connection
ssh -vvv username@ip_address

# Check SSH key permissions
ls -la ~/.ssh/

# Fix permissions (should be 700 for .ssh, 600 for keys)
chmod 700 ~/.ssh/
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# Check remote SSH service
sudo systemctl status ssh

# ============ SSH Tunneling ============

# Create SSH tunnel for VPN-like access
ssh -D 8080 username@ip_address

# Use with SOCKS5 proxy client

echo "SSH commands examples completed!"
