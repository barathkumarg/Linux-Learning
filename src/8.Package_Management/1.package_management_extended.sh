#!/bin/bash

# Package Management - RPM, YUM, APT, DPKG
# Reference: 8_Package_management.md

# ============ RPM (Red Hat Package Manager) ============
# Used on CentOS, RHEL, Fedora

# Install RPM package
sudo rpm -ivh package.rpm

# Uninstall RPM package
sudo rpm -e package

# Upgrade RPM package
sudo rpm -Uvh package.rpm

# Query RPM package info
sudo rpm -q package

# Verify file from RPM package
sudo rpm -Vf /path/to/file

# List all installed packages
sudo rpm -qa

# Show dependencies
sudo rpm -qpR package.rpm

# ============ YUM (Yellowdog Updater, Modified) ============
# RPM-based package manager with automatic dependency resolution
# Used on CentOS, RHEL

# Search for package
sudo yum search package_name

# Install package
sudo yum install package_name

# Remove package
sudo yum remove package_name

# Update package
sudo yum update package_name

# Update all packages
sudo yum update

# List available packages
sudo yum list available

# List installed packages
sudo yum list installed

# Show package info
sudo yum info package_name

# Show package provides
sudo yum provides command_name

# List repositories
sudo yum repolist

# Enable/disable repository
sudo yum-config-manager --enable repository_name
sudo yum-config-manager --disable repository_name

# Clean cache
sudo yum clean all

# ============ DPKG (Debian Package) ============
# Low-level package manager on Debian/Ubuntu

# Install .deb package
sudo dpkg -i package.deb

# Uninstall package
sudo dpkg -r package_name

# List installed packages
sudo dpkg -l

# List specific package
sudo dpkg -l package_name

# Show package status
sudo dpkg -s package_name

# List files in package
sudo dpkg -L package_name

# Show package info
sudo dpkg -p package_name

# Remove package completely (including config)
sudo dpkg --purge package_name

# Reconfigure package
sudo dpkg-reconfigure package_name

# ============ APT (Advanced Package Tool) ============
# High-level package manager on Debian/Ubuntu
# Uses DPKG internally

# Search for package
apt search package_name

# Install package
sudo apt install package_name

# Install multiple packages
sudo apt install package1 package2 package3

# Remove package
sudo apt remove package_name

# Remove package completely
sudo apt purge package_name

# Update package list
sudo apt update

# Upgrade all packages
sudo apt upgrade

# Full upgrade (can remove/add packages)
sudo apt full-upgrade

# Auto-remove unused packages
sudo apt autoremove

# Show package info
apt show package_name

# List installed packages
apt list --installed

# List upgradeable packages
apt list --upgradeable

# Check dependencies
apt-cache depends package_name

# Show reverse dependencies
apt-cache rdepends package_name

# ============ APT-GET (Older APT Interface) ============
# Similar to APT, still works for backwards compatibility

# Update repository
sudo apt-get update

# Install package
sudo apt-get install package_name

# Remove package
sudo apt-get remove package_name

# Clean cache
sudo apt-get clean

# Autoclean old packages
sudo apt-get autoclean

# ============ Repository Management ============

# View APT sources
cat /etc/apt/sources.list

# View APT sources in sources.d directory
ls -la /etc/apt/sources.list.d/

# Edit APT sources
sudo nano /etc/apt/sources.list

# Add PPA repository (Ubuntu)
sudo add-apt-repository ppa:username/ppa-name

# Remove PPA repository
sudo add-apt-repository --remove ppa:username/ppa-name

# Add custom repository
sudo nano /etc/apt/sources.list.d/custom.list

# Update after adding repository
sudo apt update

# ============ Package File Handling ============

# Check which package owns a file
apt-cache search /path/to/file
dpkg -S /path/to/file

# Find package for command
apt-file search /usr/bin/command
which command

# ============ Debian Package Creation ============

# Extract .deb package content
dpkg -x package.deb extraction_folder

# Extract control files
dpkg -e package.deb extraction_folder/DEBIAN

# ============ Common Package Management Tasks ============

# Install from local file
sudo apt install ./package.deb

# Install from URL
sudo apt install http://example.com/package.deb

# Pin package version
echo "package_name hold" | sudo dpkg --set-selections

# Unpin package
echo "package_name install" | sudo dpkg --set-selections

# Check held packages
sudo apt-mark showhold

# ============ Troubleshooting ============

# Fix broken dependencies
sudo apt --fix-broken install

# Fix held packages
sudo apt --fix-held-packages install

# Remove lock file (if locked)
sudo rm /var/lib/apt/lists/lock
sudo rm /var/cache/apt/archives/lock
sudo rm /var/lib/dpkg/lock*

# Force package configuration
sudo dpkg --configure -a

echo "Package management examples completed!"
