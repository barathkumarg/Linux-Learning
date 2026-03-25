# Resource Management

## Disk Space Management

### df (Disk Free) - File System Disk Space Usage

The `df` command displays disk space usage of mounted file systems.

**Basic Usage:**
```bash
df
```

**Human-readable format:**
```bash
df -h
```

**Show specific file system type:**
```bash
df -t ext4
df -t xfs
```

**Show inode usage:**
```bash
df -i
```

**Show specific mount point:**
```bash
df -h /home
```

**Production Scenario:**
```bash
# Monitor critical file systems in production
df -h /var /log /home

# Alert when usage exceeds 80%
# Output: /dev/vda1        50G  42G  5.2G  89% /
# Action: Archive old logs, clean up temporary files
```

---

### du (Disk Usage) - Directory/File Size

The `du` command estimates file and directory space usage.

**Basic Usage:**
```bash
du /home
```

**Human-readable format (size in bytes):**
```bash
du -sh /home
```

**Show all files and directories:**
```bash
du -ah /home
```

**Sort by size (largest first):**
```bash
du -sh /home/* | sort -hr
```

**Show specific depth:**
```bash
du -h --max-depth=1 /var
```

**Find large files in a directory:**
```bash
du -ah /var | sort -hr | head -20
```

**Production Scenario:**
```bash
# Identify large directories consuming disk space
du -sh /var/* | sort -hr

# Output:
# 15G     /var/log
# 8.5G    /var/cache
# 2.3G    /var/spool

# Action: Clean up old logs
rm -rf /var/log/apache2/*.log.1
gzip /var/log/*.log

# Or archive logs to external storage
tar -czf /backup/var-log-$(date +%Y%m%d).tar.gz /var/log
```

---

### free - Memory Usage

The `free` command displays RAM and swap memory usage.

**Human-readable format:**
```bash
free -h
```

**Show in megabytes:**
```bash
free -m
```

**Show in gigabytes:**
```bash
free -g
```

**Continuous monitoring (every 2 seconds):**
```bash
free -h -s 2
```

**Sample Output:**
```
              total        used        free      shared  buff/cache   available
Mem:          15Gi       8.2Gi       1.5Gi       512Mi       5.3Gi       5.8Gi
Swap:         2.0Gi       1.2Gi       800Mi
```

**Production Scenario:**
```bash
# Monitor memory before running resource-intensive job
free -h

# If available < 2GB, defer job or kill non-essential processes
# High swap usage indicates memory pressure
# Action: Increase RAM or optimize applications
```

---

## System Information

### uptime - System Uptime and Load Average

Shows how long the system has been running and current load average.

**Basic Usage:**
```bash
uptime
```

**Output:**
```
14:35:42 up 48 days,  3:22,  2 users,  load average: 0.45, 0.52, 0.48
```

**Load Average Interpretation:**
- 1st number: 1-minute load average
- 2nd number: 5-minute load average  
- 3rd number: 15-minute load average

**Production Scenario:**
```bash
# Check system health before deployment
uptime

# Output: load average: 0.15, 0.18, 0.20 (Good - CPU idle)
# Load average: 3.50, 3.60, 3.70 (Bad - CPU bottleneck on 4-core system)

# If load > CPU_count, system is under stress
# Action: Defer non-critical jobs, investigate running processes
```

---

### lscpu - CPU Information

Displays CPU architecture and information.

**Basic Usage:**
```bash
lscpu
```

**Sample Output:**
```
Architecture:            x86_64
CPU op-mode(s):          32-bit, 64-bit
Byte Order:              Little Endian
CPU(s):                  8
On-line CPU(s) list:     0-7
Vendor ID:               GenuineIntel
Model name:              Intel(R) Xeon(R) E-2176M CPU @ 3.70GHz
CPU family:              6
Model:                   158
Stepping:                10
CPU MHz:                 3699.993
```

**Specific queries:**
```bash
# Show only CPU count
lscpu | grep "CPU(s)"

# Show only model name
lscpu | grep "Model name"

# Show socket and core information
lscpu | grep -E "Socket|Core|Thread"
```

**Production Scenario:**
```bash
# Verify CPU allocation in cloud VM
lscpu  # Verify 8 CPUs as requested

# Check for CPU throttling
cat /proc/cpuinfo | grep MHz  # Verify frequency

# Performance monitoring
watch -n 1 'lscpu'
```

---

### lspci - PCI Devices

Lists all PCI (Peripheral Component Interconnect) devices.

**Basic Usage:**
```bash
lspci
```

**Verbose output:**
```bash
lspci -v
```

**Very verbose output:**
```bash
lspci -vv
```

**Show specific device (e.g., network cards):**
```bash
lspci | grep -i ethernet
lspci | grep -i network
```

**Show GPU:**
```bash
lspci | grep -i vga
```

**Sample Output:**
```
00:00.0 Host bridge: Intel Corporation 4th Gen Core Processor DRAM Controller
00:02.0 VGA compatible controller: Intel Corporation Xeon E3-1200 v3/4th Gen Core
00:14.0 USB controller: Intel Corporation 8 Series/C220 Series USB xHCI HC
00:16.0 Communication controller: Intel Corporation 8 Series/C220 Series MEI Interface
00:1a.0 USB controller: Intel Corporation 8 Series/C220 Series USB EHCI
00:1f.0 ISA bridge: Intel Corporation H87 Express LM75 temperature sensor
```

**Production Scenario:**
```bash
# Check network device drivers
lspci -v | grep -A 5 "Ethernet"

# Verify GPU availability
lspci | grep -i cuda  # For CUDA-capable GPUs

# Check for driver issues
lspci -k | grep -A 2 Kernel  # Shows loaded/unloaded drivers
```

---

## File System Integrity Management

### mount and unmount - File System Mounting

**List all mounted file systems:**
```bash
mount
df -h
```

**Mount a file system:**
```bash
mount /dev/sdb1 /data
mount -t ext4 /dev/sdb1 /data
```

**Mount with options (read-only):**
```bash
mount -o ro /dev/sdb1 /data
mount -o remount,ro /data
```

**Unmount:**
```bash
umount /data
```

**Force unmount (use carefully):**
```bash
umount -f /data
```

**Remount with different options:**
```bash
mount -o remount,noatime /dev/sdb1 /data
```

**Production Scenario:**
```bash
# Emergency: File system is read-only due to errors
mount -o remount,rw /

# Add new disk to production server
fdisk /dev/sdb          # Partition the disk
mkfs.ext4 /dev/sdb1     # Create file system
mkdir -p /mnt/data      # Create mount point
mount /dev/sdb1 /mnt/data

# Make permanent (add to /etc/fstab)
echo "/dev/sdb1 /mnt/data ext4 defaults,noatime 0 0" >> /etc/fstab
mount -a  # Mount all entries from fstab
```

---

### fsck - File System Check (ext4)

Checks and repairs ext4 file systems. **Must run on unmounted file system.**

**Basic check (no repair):**
```bash
fsck.ext4 -n /dev/sdb1
```

**Repair automatically (fix errors):**
```bash
fsck.ext4 -y /dev/sdb1
```

**Verbose output:**
```bash
fsck.ext4 -v /dev/sdb1
```

**Check for bad blocks:**
```bash
fsck.ext4 -c /dev/sdb1
```

**Production Scenario:**
```bash
# Server crashed unexpectedly, file system corrupted
# Boot into recovery mode

# First, unmount the partition
umount /data

# Check for errors
fsck.ext4 -n /dev/sdb1  # Preview repairs needed

# Repair if safe
fsck.ext4 -y /dev/sdb1

# Output:
# Pass 1: Checking inodes, blocks, and sizes
# Pass 2: Checking directory structure
# Pass 3: Checking directory connectivity
# Pass 4: Checking reference counts
# Pass 5: Checking group summary information
# /dev/sdb1: 1234/262144 files, 45678/1048576 blocks

# Remount and verify
mount /dev/sdb1 /data
df -h /data
```

---

### xfs_repair - File System Repair (XFS)

Repairs XFS file systems. **Filesystem must be unmounted or in read-only mode.**

**Preview repair (read-only):**
```bash
xfs_repair -n /dev/vdb1
```

**Repair with verbose output:**
```bash
xfs_repair -v /dev/vdb1
```

**Force repair (dangerous, use as last resort):**
```bash
xfs_repair -L /dev/vdb1  # Destroy log
xfs_repair /dev/vdb1
```

**Check XFS file system:**
```bash
xfs_admin -l /dev/vdb1
```

**Production Scenario:**
```bash
# XFS file system corrupted after power failure
# Data node in Hadoop cluster affected

# 1. Boot into maintenance mode
# 2. Unmount the file system
umount /data

# 3. Run diagnostic check
xfs_repair -n /dev/vdb1

# 4. Review errors and repair if necessary
xfs_repair -v /dev/vdb1

# Output:
# Phase 1 - Find and verify superblock...
# Phase 2 - Using internal log
# Phase 3 - For each AG...
# Phase 4 - Check for duplicate blocks...
# Phase 5 - Rebuild AG headers and trees...
# Phase 6 - Repair inode allocation trees...
# Phase 7 - Verify and correct link counts...
# Done

# 5. Remount and verify
mount /dev/vdb1 /data
xfs_repair -n /dev/vdb1  # Verify no more errors
df -h /data
```

---

## File System Types

### Common File Systems in Production

**ext4** - Linux standard
- Default on Ubuntu/Debian
- Good for general-purpose use
- Supports journaling
- Max file size: 16TB
- Max partition: 1EB

```bash
# Check file system type
df -T

# Verify Ubuntu system uses ext4
lsblk -f
```

**XFS** - High-performance file system
- Used in RHEL/CentOS
- Better for large files and high I/O
- Excellent for parallel I/O
- Used in data centers and HPC

```bash
# Check if XFS is available
mkfs.xfs -V

# Format partition as XFS
mkfs.xfs /dev/sdb1
```

---

## Disk Partitioning and Management

### lsblk - List Block Devices

The `lsblk` command displays information about all available block devices (disks and partitions) in a tree format.

**Basic Usage:**
```bash
lsblk
```

**Sample Output:**
```
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda           8:0    0  500G  0 disk
├─sda1        8:1    0    1G  0 part /boot
├─sda2        8:2    0  200G  0 part /
└─sda3        8:3    0  299G  0 part /home
sdb           8:16   0  1.8T  0 disk
└─sdb1        8:17   0  1.8T  0 part /data
nvme0n1     259:0    0  476G  0 disk
└─nvme0n1p1 259:1    0  476G  0 part
```

**Display file system types:**
```bash
lsblk -f
```

**Show permissions and owner:**
```bash
lsblk -P
```

**List only disks (no partitions):**
```bash
lsblk -d
```

**Human-readable sizes with all details:**
```bash
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
```

**Production Scenario:**
```bash
# New storage added to server, need to verify device
lsblk

# Identify which device is new (e.g., sdc with 2TB)
# Check if already partitioned
lsblk -f | grep sdc

# Verify in monitoring dashboard
lsblk -o NAME,SIZE,TYPE,MODEL | grep -E "TYPE|sdc"

# Output indicates unpartitioned device ready for setup
```

---

### fdisk and cfdisk - Partition Management

Disk partitioning tools to create, modify, and delete partitions.

**Interactive Partition Editor - cfdisk (recommended):**
```bash
# User-friendly, interactive partitioning
sudo cfdisk /dev/sdb

# Steps:
# 1. Select label type (gpt, dos)
# 2. Create new partition
# 3. Set partition type
# 4. Write changes to disk
```

**Command-line Tool - fdisk:**
```bash
# View current partition table
sudo fdisk -l /dev/sdb
sudo fdisk -l /dev/sdb | grep sdb1

# Interactive mode
sudo fdisk /dev/sdb
```

**Partition Label Types:**

| Type | Usage | Max Partitions | Max Size |
|------|-------|-----------------|----------|
| **dos** | Legacy, MBR-based | 4 primary + extended | 2TB per partition |
| **gpt** | Modern, UEFI systems | Unlimited | 9.4ZB per partition |
| **sgi** | SGI IRIX systems | Multiple | Large |
| **sun** | Sun SPARC systems | Multiple | Large |

**Create Partition with cfdisk - Step by Step:**
```bash
# 1. Launch cfdisk on unpartitioned disk
sudo cfdisk /dev/sdb

# 2. In interactive menu:
#    - Press 'n' for New partition
#    - Select partition size (e.g., 1000G for 1TB)
#    - Select partition type (Primary/Extended)
#    - Press 'd' to delete if needed
#    - Press 't' to change type

# 3. Verify partition created
sudo cfdisk /dev/sdb

# 4. Write changes with 'w' (important!)
#    Or 'q' to quit without saving

# 5. Verify with fdisk
sudo fdisk -l /dev/sdb
```

**Production Scenario - Add Storage to Database Server:**
```bash
# New 4TB NVMe SSD added to production DB server
lsblk  # Identify as nvme1n1

# Create GPT partition table (supports > 2TB)
sudo cfdisk /dev/nvme1n1
# Select 'gpt' label type
# Create 4TB partition
# Write changes

# Verify
sudo fdisk -l /dev/nvme1n1

# Output:
# Device        Start        End   Sectors Size Type
# /dev/nvme1n1p1    2048 8388607   8386560   4T Linux filesystem

# Create file system
sudo mkfs.ext4 /dev/nvme1n1p1

# Mount permanently
sudo mkdir -p /data/db
echo "/dev/nvme1n1p1 /data/db ext4 defaults,noatime 0 0" | sudo tee -a /etc/fstab
sudo mount -a

# Verify
df -h /data/db
```

**Production Scenario - Multiple Small Partitions for Separation:**
```bash
# Server with 2TB disk - separate OS, data, and backups
sudo cfdisk /dev/sdb

# Create partitions:
# /dev/sdb1: 500GB - Data partition
# /dev/sdb2: 500GB - Backup partition
# /dev/sdb3: 1000GB - Archive/Log partition

sudo mkfs.ext4 /dev/sdb1
sudo mkfs.ext4 /dev/sdb2
sudo mkfs.xfs /dev/sdb3

# Mount and add to fstab for persistence
sudo mkdir -p /mnt/data /mnt/backup /mnt/archive
sudo mount /dev/sdb1 /mnt/data
sudo mount /dev/sdb2 /mnt/backup
sudo mount /dev/sdb3 /mnt/archive

# Verify space allocation
df -h /mnt/*
```

---

## Swap Management

Swap is disk space used as virtual memory when RAM is exhausted. Essential for system stability under memory pressure.

### Understanding Swap

**When to Use Swap:**
- System runs out of physical RAM
- Hibernation (needs swap >= RAM size)
- OOM protection
- Memory spikes handling

**Swap Disadvantages:**
- Much slower than RAM
- Excessive swapping causes performance degradation
- Can reduce SSD lifespan

### mkswap - Create Swap Space

Formats a partition or file as swap space.

**On a dedicated partition:**
```bash
# Create swap on /dev/sdb2 partition
sudo mkswap /dev/sdb2
```

**On a file (for temporary swap):**
```bash
# Create 2GB swap file
sudo dd if=/dev/zero of=/swapfile bs=1M count=2048 status=progress

# Set permissions (only root can access)
sudo chmod 600 /swapfile

# Format as swap
sudo mkswap /swapfile
```

**Sample Output:**
```
Setting up swapspace version 1, size = 2 GiB (2147483648 bytes)
no label, UUID=a1b2c3d4-e5f6-7890-abcd-ef1234567890
```

### swapon - Enable Swap

Activates swap space for use by the system.

**Enable swap on partition:**
```bash
sudo swapon /dev/sdb2

# Verify
sudo swapon -s
```

**Enable swap on file:**
```bash
sudo swapon /swapfile

# Verify swap is active
free -h
```

**Enable all configured swap:**
```bash
sudo swapon -a
```

**Sample Output:**
```
Filename        Type       Size    Used Priority
/dev/sdb2       partition  2097152 0    -2
/swapfile       file       2097152 0    -3
```

### swapoff - Disable Swap

Deactivates swap space.

**Disable specific swap:**
```bash
sudo swapoff /dev/sdb2
sudo swapoff /swapfile
```

**Disable all swap:**
```bash
sudo swapoff -a
```

**Monitor before disabling:**
```bash
# Check swap usage
free -h

# Verify memory is available before removing swap
# Output: Swap: 4.0Gi   512Mi   3.5Gi (only 512Mi used - safe to disable)
```

---

### Persistent Swap Configuration

Make swap survive reboot by adding to `/etc/fstab`.

**Add Swap Partition to /etc/fstab:**
```bash
# For partition
echo "/dev/sdb2 none swap sw 0 0" | sudo tee -a /etc/fstab

# Verify
cat /etc/fstab
```

**Add Swap File to /etc/fstab:**
```bash
# For swap file
echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab

# Verify
cat /etc/fstab
```

**Load all fstab entries at boot:**
```bash
# Already automatic, verify with
sudo systemctl status var-swapfile.swap
```

---

### Creating Persistent Swap File - Complete Example

Full workflow to create and persist a 2GB swap file:

```bash
# Step 1: Create empty file (2GB = 2048MB)
sudo dd if=/dev/zero of=/swapfile bs=1M count=2048 status=progress
# Output: 2147483648 bytes (2.1 GB, 2.0 GiB) copied, 15.2345 s, 141 MB/s

# Step 2: Restrict permissions (security - only root accesses)
sudo chmod 600 /swapfile

# Verify permissions
ls -lh /swapfile
# Output: -rw------- 1 root root 2.0G Mar 24 10:30 /swapfile

# Step 3: Format as swap space
sudo mkswap /swapfile
# Output: Setting up swapspace version 1, size = 2 GiB...

# Step 4: Enable swap immediately
sudo swapon /swapfile

# Step 5: Verify swap is active
free -h
# Output shows 2.0Gi Swap available

# Step 6: Make persistent across reboots
echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab

# Step 7: Verify configuration
cat /etc/fstab | tail -3

# Step 8: Test persistence (optional - done on reboot)
# sudo mount -a
# free -h
```

---

### Swap Optimization

**Adjust Swap Usage Priority (swappiness):**
```bash
# View current swappiness (0-100)
cat /proc/sys/vm/swappiness

# Typical value: 60 (uses swap when 40% RAM remains)
# For servers: reduce to 10-20 (prefer RAM)
# For desktops: keep at 60

# Temporarily change
sudo sysctl vm.swappiness=10

# Verify
cat /proc/sys/vm/swappiness

# Make permanent
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.d/99-custom.conf
sudo sysctl -p
```

**Monitor Swap Usage:**
```bash
# Real-time swap monitoring
watch -n 1 'free -h'

# Check swap in and out (paging activity)
vmstat 1 5

# Output columns: si (swap in), so (swap out)
# High values indicate memory pressure
```

**Production Scenario - Database Server Swap Setup:**
```bash
# 256GB RAM server needs swap for hibernation and OOM protection
# Current arrangement: 4TB NVMe storage

# Create 16GB swap partition (for hibernation, limited swappiness)
sudo cfdisk /dev/nvme0n1  # Create 16GB partition
sudo mkswap /dev/nvme0n1p4

# Enable swap
sudo swapon /dev/nvme0n1p4

# Make persistent
echo "/dev/nvme0n1p4 none swap sw 0 0" | sudo tee -a /etc/fstab

# Set swappiness to 10 (prefer RAM, use swap for emergencies)
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.d/99-db-server.conf
sudo sysctl -p

# Monitor configuration
swapon -s
cat /proc/sys/vm/swappiness
free -h

# Alert: If swap usage > 1%, investigate memory leak
```

**Swap File vs Swap Partition:**

| Aspect | Swap File | Swap Partition |
|--------|-----------|-----------------|
| Creation | Easy, no repartitioning | Requires partition | 
| Performance | Slightly slower | Faster |
| Resizing | Easy | Complex |
| Recommended | General server use | High-performance systems |
| Setup time | Minutes | Requires reboot |

---

## Complete Monitoring Script

**Production-grade resource monitoring:**
```bash
#!/bin/bash
# resource_monitor.sh - Monitor system resources

echo "=== DISK USAGE ==="
df -h | grep -E "^/dev"

echo -e "\n=== TOP 5 LARGEST DIRECTORIES ==="
du -sh /* 2>/dev/null | sort -hr | head -5

echo -e "\n=== MEMORY USAGE ==="
free -h

echo -e "\n=== LOAD AVERAGE ==="
uptime

echo -e "\n=== CPU INFO ==="
lscpu | grep -E "CPU\(s\)|Model name|CPU MHz"

echo -e "\n=== CRITICAL ALERTS ==="
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 80 ]; then
    echo "WARNING: Root partition at ${DISK_USAGE}% capacity"
fi

FREE_MEM=$(free -h | awk 'NR==2 {print $7}')
echo "Available Memory: $FREE_MEM"
```

**Run it:**
```bash
chmod +x resource_monitor.sh
./resource_monitor.sh
```

