#!/bin/bash

# Vagrant Commands and Usage
# Reference: 7_1_vagrand.md

# Vagrant is a tool for building and distributing development environments
# Uses VM providers like VirtualBox, VMware, etc.

# ============ Prerequisites ============
# - VM Provider installed (VirtualBox, VMware, KVM, etc.)
# - Vagrant installed

# ============ Basic Vagrant Workflow ============

# Step 1: Create project directory
mkdir my_vagrant_project
cd my_vagrant_project

# Step 2: Initialize Vagrant (creates Vagrantfile)
vagrant init generic/debian11

# Or initialize with specific OS box
vagrant init ubuntu/focal

# Step 3: Start the VM
vagrant up

# Step 4: SSH into the VM
vagrant ssh

# Step 5: Suspend VM (saves state)
vagrant suspend

# Step 6: Resume suspended VM
vagrant resume

# Step 7: Stop the VM
vagrant halt

# Step 8: Destroy the VM
vagrant destroy

# ============ Box Management ============

# Search for boxes (requires web connection)
# Visit: https://app.vagrantup.com/boxes/search

# Add a box to local collection
vagrant box add ubuntu/focal

# List all available boxes locally
vagrant box list

# Remove a box
vagrant box remove ubuntu/focal

# Update a box to latest version
vagrant box update

# ============ VM Status Commands ============

# Show current VM status
vagrant status

# Show global Vagrant status
vagrant global-status

# Show VM info
vagrant info

# ============ Working with VM ============

# SSH into VM
vagrant ssh

# Execute command in VM without SSH shell
vagrant ssh -c "ls -la /home/vagrant"

# ============ Vagrantfile Configuration ============

# Edit Vagrantfile to configure VM
nano Vagrantfile

# Common Vagrantfile settings:
# - config.vm.box = "box_name"
# - config.vm.network "private_network", ip: "192.168.33.10"
# - config.vm.synced_folder ".", "/vagrant"
# - config.vm.provider "virtualbox" do |vb|

# ============ Port Forwarding ============

# In Vagrantfile:
# config.vm.network "forwarded_port", guest: 80, host: 8080

# ============ Synced Folders ============

# Default synced folder: . <-> /vagrant

# Configure custom synced folder in Vagrantfile:
# config.vm.synced_folder "./data", "/vagrant_data"

# Disable synced folder
# config.vm.synced_folder ".", "/vagrant", disabled: true

# ============ Provisioning ============

# Provisioning runs when VM is first created

# Inline shell provisioning in Vagrantfile:
# config.vm.provision "shell", inline: "apt-get update"

# Run external script:
# config.vm.provision "shell", path: "bootstrap.sh"

# Run provisioning without destroying VM
vagrant provision

# ============ Snapshot Management ============

# Create a snapshot
vagrant snapshot save snapshot_name

# List snapshots
vagrant snapshot list

# Restore a snapshot
vagrant snapshot restore snapshot_name

# Delete a snapshot
vagrant snapshot delete snapshot_name

# ============ Multiple VMs ============

# In Vagrantfile, define multiple VMs:
# config.vm.define "web" do |web|
#   web.vm.box = "ubuntu/focal"
#   web.vm.hostname = "web"
# end

# Control specific VM:
vagrant up web
vagrant ssh web
vagrant halt web

# ============ Networking ============

# Private network (host-only)
# config.vm.network "private_network", ip: "192.168.33.10"

# Public network (bridged)
# config.vm.network "public_network"

# ============ Logs and Debugging ============

# Enable verbose logging
VAGRANT_LOG=info vagrant up

# Different log levels: debug, info, warn, error

# ============ Troubleshooting ============

# If VM fails to start, check logs:
vagrant up 2>&1 | tee vagrant.log

# Reload VM (halt and up)
vagrant reload

# Reload with provisioning
vagrant reload --provision

# Validate Vagrantfile syntax
vagrant validate

# ============ Important Notes ============
# - Vagrant box is a packaged VM image
# - Vagrantfile defines VM configuration
# - VMs are stored in .vagrant directory
# - Default user/password: vagrant/vagrant
# - Synced folder allows host-guest file sharing
# - Provisioning automates VM setup

echo "Vagrant command examples completed!"
