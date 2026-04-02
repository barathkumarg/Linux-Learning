## Content

1. [File Systems and Partition](#file-systems-and-partition)
2. [Linux Device Naming Conventions](#linux-device-naming-conventions)
3. [Listing and Managing Partitions with fdisk](#listing-and-managing-partitions-with-fdisk)
4. [Creating File Systems with mkfs.xfs](#creating-file-systems-with-mkfsxfs)
5. [Mounting Filesystems and Persistent Boot Configuration](#mounting-filesystems-and-persistent-boot-configuration)
6. [Listing Mounted Filesystems with findmnt](#listing-mounted-filesystems-with-findmnt)
7. [Advanced Mount Options](#advanced-mount-options)
8. [Swap Space creation](#swap-space-creation)
9. [Logical Volume Management](#logical-volume-management)
10. [Network Block Devices (NBD)](#network-block-devices-nbd)
11. [External Storage DAS, NAS, SAN](#external-storage-nas-das-and-san)
12. [NFS - Network File System](#nfs---network-file-system)
13. [Storage Monitoring and I/O Performance](#storage-monitoring-and-io-performance)
14. [Access Control Lists (ACL) and File Attributes](#access-control-lists-acl-and-file-attributes)

## File Systems and Partition
![](../media/File_system/partition_1.png)

![](../media/File_system/partition_2.png)

![](../media/File_system/partition_3.png)

![image](../media/File_system/file_system_1.png)
![image](../media/File_system/file_system_2.png)
![image](../media/File_system/file_system_3.png)
![image](../media/File_system/file_system_4.png)

[GUI Way to create the Partition](https://askubuntu.com/questions/1347340/how-can-i-create-an-usable-partition-with-unallocated-space)

### GUI Tool to do partition and mounting
[g-parted](https://www.geeksforgeeks.org/disk-partitioning-in-ubuntu-using-gparted/)

Operations can be Performed
- Partitioning the Disk
- Mounting the partition
- Unmounting the partition

---

## Linux Device Naming Conventions

Device names assigned based on motherboard connection and controller type:

- **SATA/IDE:** `/dev/sda`, `/dev/sdb`, `/dev/sdc` (partitions: `/dev/sda1`, `/dev/sda2`, etc.)
- **NVMe:** `/dev/nvme0n1`, `/dev/nvme0n1p1` (first controller, first namespace, first partition)
- **Virtual:** `/dev/vda`, `/dev/vdb` (KVM/Xen VMs)
- **Loop:** `/dev/loop0`, `/dev/loop1` (ISO/disk images)

**Kernel assigns names based on:**
1. Driver/Controller Type, 2. Bus Location (PCIe, SATA port), 3. Detection Order, 4. BIOS Settings

```bash
lsblk  # Check all devices
```

---

## Listing and Managing Partitions with fdisk

`fdisk` - Partition management and disk viewing utility.

**Syntax:**
```bash
sudo fdisk -l              # List all disks/partitions
sudo fdisk -l /dev/sda     # List specific disk
sudo fdisk /dev/sdb        # Interactive mode
```

**Interactive Commands:** `p` (print), `d` (delete), `n` (new), `t` (type), `w` (write), `q` (quit)

**Example:**
```bash
sudo fdisk -l /dev/sdb
# Output: Disk /dev/sdb: 500 GiB | /dev/sdb1 500G Linux

sudo fdisk /dev/sdb
# Command: n → p → 1 → (defaults) → w
```

---

## Creating File Systems with mkfs.xfs

`mkfs.xfs` - Creates XFS filesystem (high-performance for large files/databases).

**Syntax:**
```bash
sudo mkfs.xfs /dev/sdb1                    # Basic
sudo mkfs.xfs -L "Backup" /dev/sdb1        # With label
sudo mkfs.xfs -f -L "Data" /dev/sdb1       # Force format
```

**Common Options:**

| Option | Purpose |
|--------|---------|
| `-L` | Filesystem label (max 12 chars) |
| `-f` | Force format |
| `-m crc=1` | Enable metadata CRC |
| `-b size=4096` | Block size |
| `-d agcount=32` | Allocation groups |

**Example:**
```bash
sudo mkfs.xfs -L "Backup" /dev/sdb1
sudo blkid /dev/sdb1  # Verify
```

**Production Setup:**
```bash
#!/bin/bash
# Multiple backup disks
sudo mkfs.xfs -L "AppData" /dev/sdb1
sudo mkfs.xfs -L "DBBackup" /dev/sdc1
sudo mkfs.xfs -L "LogArchive" /dev/sdd1
sudo blkid | grep xfs
```

---

## Mounting Filesystems and Persistent Boot Configuration

**Temporary Mount:**
```bash
sudo mount /dev/sdb1 /mnt/backup         # Mount
sudo umount /mnt/backup                  # Unmount
mount | grep /mnt                        # View
```

**/etc/fstab Format:** `<filesystem> <mountpoint> <type> <options> <dump> <pass>`

**Examples:**
```bash
/dev/sdb1              /mnt/backup      xfs     defaults         0  2
UUID=a1b2c3d4          /mnt/appdata     xfs     rw,noatime       0  2
LABEL=Backup           /mnt/backup      xfs     ro,noatime       0  2
192.168.1.100:/export  /mnt/nfs         nfs     defaults,_netdev 0  0
```

**Mount Options:** `ro`/`rw`, `noatime`/`relatime`, `noexec`, `nosuid`, `nodev`, `nofail`, `_netdev`

**Setup Steps:**
```bash
sudo fdisk /dev/sdb              # Create partition
sudo mkfs.xfs -L "Backup" /dev/sdb1
sudo mkdir -p /mnt/backup
sudo blkid /dev/sdb1             # Get UUID
sudo vi /etc/fstab               # Add entry
sudo mount -a && df -h           # Test
```

**Enterprise Setup:**
```bash
#!/bin/bash
sudo mkdir -p /backup/{daily,weekly}
sudo mkfs.xfs -L "Daily-Backup" /dev/sdb1
sudo mkfs.xfs -L "Weekly-Archive" /dev/sdc1
cat >> /etc/fstab << EOF
LABEL=Daily-Backup    /backup/daily    xfs  defaults,noatime  0  2
LABEL=Weekly-Archive  /backup/weekly   xfs  ro,noatime        0  2
EOF
sudo mount -a && df -h /backup/*
```

---

## Listing Mounted Filesystems with findmnt

`findmnt` - Lists all mounted filesystems in tree format from `/etc/fstab`, `/etc/mtab`, and kernel info.

**Syntax:**
```bash
findmnt                   # List all filesystems
findmnt -t xfs,ext4      # Filter by type
findmnt -o SOURCE,TARGET,FSTYPE,OPTIONS  # Specific columns
findmnt /mnt/backup      # Specific mount point
findmnt -D               # Show disk usage
findmnt -h               # Human-readable
```

**Common Options:** `-t` (type filter), `-o` (columns), `-D` (disk usage), `-i` (inode usage), `-h` (human-readable)

**Examples:**
```bash
findmnt                          # Tree view
findmnt -t xfs,ext4             # Only XFS/ext4
findmnt -t xfs -D               # XFS with usage
findmnt -o SOURCE,TARGET,USE%   # Custom columns
```

**Monitoring Script:**
```bash
#!/bin/bash
echo "=== Filesystem Overview ==="
findmnt -t xfs,ext4 -o SOURCE,TARGET,FSTYPE,SIZE,USED,USE%
echo ""
echo "=== Check High Usage ==="
findmnt -t xfs,ext4 -D | awk 'NR>1 && $NF+0 > 80 {print "WARNING: " $1 " is " $NF "% full"}'
```

# Output:
# TARGET       SOURCE    FSTYPE OPTIONS
# /            /dev/sda1 ext4   rw,relatime
# /boot        /dev/sda2 ext4   rw,relatime
# /mnt/backup  /dev/sdb1 xfs    rw,relatime
```

---

## Advanced Mount Options
| `nodev` | Disable character/block devices | Security, prevents device access |
| `remount` | Remount existing filesystem with new options | Dynamic option changes without unmounting |
| `defaults` | Standard options (rw, suid, dev, exec, auto, nouser, async) | General purpose mounting |

**Performance Options:**

| Option | Description | Use Case |
|--------|-------------|----------|
| `noatime` | Don't update access time on reads | Performance improvement (disables atime) |
| `relatime` | Update atime only if older than mtime/ctime | Balanced: performance + atime tracking |
| `strictatime` | Update atime on every access | When atime is required |
| `async` | Asynchronous I/O (default) | General use, better performance |
| `sync` | Synchronous I/O | Reliability, slower performance |

---

## Advanced Mount Options

**Manual:** `man mount` (general), `man xfs` (XFS-specific)

**Security Options:** `ro`, `rw`, `noexec` (prevent execution), `nosuid` (prevent SUID), `nodev` (prevent devices)

**Performance Options:** `noatime` (skip atime), `relatime` (balance), `async` (async I/O)

**XFS-Specific:** `allocsize=32k` (preallocation), `logbufs=8` (log buffers), `barrier` (enable write safety)

**Reliability:** `errors=remount-ro`, `nofail` (skip on error), `_netdev` (wait for network)

**Temporary Mount:**
```bash
sudo mount -o ro,noexec,nosuid /dev/vdb2 /mnt          # With options
sudo mount -o remount,rw,noatime /dev/sdb1 /backup    # Remount (change options, no unmount)
mount | grep /mnt                                       # Verify
```

**Examples:**
```bash
# Security: read-only, no-execute, no-suid
sudo mount -o ro,noexec,nosuid /dev/vdb2 /mnt

# Performance: disable atime, set allocation size
sudo mount -o rw,noatime,allocsize=32k,logbufs=8 /dev/sdb1 /data

# Remount to change options live (no downtime)
sudo mount -o remount,ro /mnt/backup
sudo mount -o remount,rw,noatime,allocsize=32k /dev/sdb1 /app
```

**/etc/fstab Security Examples:**
```bash
# App data - performance
UUID=abc123  /app   xfs  rw,noatime,allocsize=32k,logbufs=8  0  2

# Backups - security (read-only, no-exec, no-suid, no-device)
LABEL=Backup /backup xfs  ro,noexec,nosuid,nodev,noatime     0  2

# Home - balanced
UUID=xyz789  /home  ext4 rw,relatime,errors=remount-ro       0  2

# Database - optimized
LABEL=DBData /var/lib/mysql xfs rw,noatime,allocsize=32k,logbufs=16 0 2
```

**Complete Setup Script:**
```bash
#!/bin/bash
sudo mkdir -p /mnt/{appdata,backup,logs,archive}

# Mount with specific options
sudo mount -o rw,noatime,allocsize=32k,logbufs=8 /dev/sdb1 /mnt/appdata
sudo mount -o ro,noexec,nosuid,nodev,noatime /dev/sdc1 /mnt/backup
sudo mount -o rw,noexec,nosuid,noatime /dev/sdd1 /mnt/logs
sudo mount -o ro,noexec,nosuid,noatime /dev/sde1 /mnt/archive

# Add to /etc/fstab for persistence
cat >> /etc/fstab << EOF
LABEL=AppData   /mnt/appdata  xfs  rw,noatime,allocsize=32k,logbufs=8  0  2
LABEL=Backup    /mnt/backup   xfs  ro,noexec,nosuid,nodev,noatime     0  2
LABEL=Logs      /mnt/logs     xfs  rw,noexec,nosuid,noatime           0  2
LABEL=Archive   /mnt/archive  xfs  ro,noexec,nosuid,noatime           0  2
EOF

# Verify
findmnt -t xfs -o SOURCE,TARGET,OPTIONS
df -h /mnt/*
```

---

## Swap Space creation

Swap Memory - Swap space in Linux is an extension of physical RAM, offering virtual memory that helps maintain system stability and performance. It allows processes to continue running when RAM is fully used and prevents memory errors.

![img_1.png](../media/File_system/swap_1.png)

### [Steps to be followed to create, activate and delete the swap](https://phoenixnap.com/kb/swap-partition)
![img_1.png](../media/File_system/swap_2.png)

## Logical Volume Management

**Overview:** LVM (Logical Volume Manager) allows you to dynamically resize storage without repartitioning the disk. It abstracts physical disks into a flexible layer, enabling easy expansion, movement, and management of storage space.

**Real-World Use Case:**
- Traditional partitioning: Disk space is fixed (e.g., 100GB to /data, 50GB to /backup). When /data runs out, you must repartition.
- LVM: Create a pool of available storage, allocate as needed, and grow partitions on-the-fly without downtime.

![img.png](../media/File_system/logical_1.png)
![img.png](../media/File_system/logical_2.png)

### LVM Concepts and Components

**Physical Volume (PV):** A physical disk or partition (/dev/sdc, /dev/sdd)
- Think of it as raw storage blocks from actual disks
- Commands: `pvcreate`, `pvs`, `pvdisplay`, `lvmdiskscan`

**Volume Group (VG):** A pool of Physical Volumes
- Combines multiple disks into one logical storage pool
- Command: `vgcreate`, `vgs`, `vgdisplay`

**Logical Volume (LV):** Virtual partitions carved from Volume Group
- Acts like a normal partition (/dev/vg0/data, /dev/vg0/backup)
- Can be resized dynamically
- Command: `lvcreate`, `lvs`, `lvdisplay`

### Step 1: Identify and Prepare Physical Volumes

**Scan available disks:**
```bash
sudo lvmdiskscan                    # List all disks/partitions suitable for LVM
lsblk                               # View disk layout
sudo fdisk -l | grep '/dev/sd'     # List SATA disks
```

**Create Physical Volumes from disks:**
```bash
# Single disk
sudo pvcreate /dev/sdc

# Multiple disks
sudo pvcreate /dev/sdc /dev/sdd

# Create on specific partition
sudo pvcreate /dev/sde1

# Force creation (for data loss)
sudo pvcreate -f /dev/sdc
```

**Verify Physical Volumes:**
```bash
sudo pvs                            # Brief view
sudo pvdisplay                      # Detailed view
sudo pvdisplay /dev/sdc             # Specific PV
```

**Example Output:**
```bash
$ sudo pvs
  PV         VG    Fmt  Attr PSize   PFree
  /dev/sdc        lvm2 ---   500.00g 500.00g
  /dev/sdd        lvm2 ---   500.00g 500.00g
```

### Step 2: Create Volume Group from Physical Volumes

**Syntax:**
```bash
sudo vgcreate <volume_group_name> <physical_volume_path> [...]  
```

**Create volume group:**
```bash
# Single disk
sudo vgcreate vg_data /dev/sdc

# Multiple disks (combined pool)
sudo vgcreate vg_storage /dev/sdc /dev/sdd

# PE size (Physical Extent - minimum allocation unit, default 4MB)
sudo vgcreate -s 8M vg_large /dev/sdc /dev/sdd
```

**Verify Volume Group:**
```bash
sudo vgs                            # Brief view
sudo vgdisplay                      # Detailed view
sudo vgdisplay vg_data              # Specific VG
```

**Example Output:**
```bash
$ sudo vgs
  VG         #PV #LV #SN Attr   VSize   VFree
  vg_data      1   0   0 wz--n- 500.00g 500.00g
  vg_storage   2   0   0 wz--n- 1000.00g 1000.00g
```

**Explanation:**
- `VSize`: Total size of Volume Group (sum of all PVs)
- `VFree`: Available space for new Logical Volumes
- PV/LV: Number of Physical/Logical Volumes in the group

### Step 3: Create Logical Volumes from Volume Group

**Syntax:**
```bash
sudo lvcreate -L <size> -n <lv_name> <vg_name>
sudo lvcreate -l <extents> -n <lv_name> <vg_name>
```

**Create logical volumes:**
```bash
# By size (GB)
sudo lvcreate -L 100G -n lv_app vg_data          # 100GB partition
sudo lvcreate -L 50G -n lv_backup vg_data        # 50GB partition

# By percentage of volume group
sudo lvcreate -l 50%VG -n lv_half vg_storage     # 50% of total VG
sudo lvcreate -l 100%FREE -n lv_full vg_storage  # All remaining space

# Create striped volume (spans multiple disks for performance)
sudo lvcreate -L 200G -n lv_stripe -i 2 vg_storage  # Stripe across 2 PVs
```

**Verify Logical Volumes:**
```bash
sudo lvs                            # Brief view
sudo lvdisplay                      # Detailed view
sudo lvdisplay /dev/vg_data/lv_app  # Specific LV
```

**Example Output:**
```bash
$ sudo lvs
  LV        VG         Attr       LSize  Pool Origin Data%
  lv_app    vg_data    -wi-a----- 100.00g
  lv_backup vg_data    -wi-a-----  50.00g
  lv_stripe vg_storage -wi-a----- 200.00g
```

### Step 4: Create Filesystem and Mount

**Create filesystem on Logical Volume:**
```bash
# XFS filesystem
sudo mkfs.xfs /dev/vg_data/lv_app

# ext4 filesystem
sudo mkfs.ext4 /dev/vg_data/lv_backup

# With label
sudo mkfs.xfs -L "App Data" /dev/vg_data/lv_app
```

**Mount the LV:**
```bash
# Temporary mount
sudo mkdir -p /app /backup
sudo mount /dev/vg_data/lv_app /app
sudo mount /dev/vg_data/lv_backup /backup

# Verify
df -h /app /backup
```

**Persistent mount in /etc/fstab:**
```bash
sudo vi /etc/fstab

# Add:
/dev/vg_data/lv_app      /app      xfs  rw,noatime           0  2
/dev/vg_data/lv_backup   /backup   xfs  ro,noatime           0  2

# Test
sudo mount -a
```

### Production Example: Enterprise Storage Setup

**Scenario:** Database server with three volumes (data, logs, backups)

```bash
#!/bin/bash
set -e

echo "=== LVM Storage Setup ==="

# Step 1: Prepare Physical Volumes
echo "Creating Physical Volumes..."
sudo pvcreate /dev/sdc /dev/sdd /dev/sde
sudo pvs

# Step 2: Create Volume Group (1.5TB pool)
echo "Creating Volume Group..."
sudo vgcreate vg_database /dev/sdc /dev/sdd /dev/sde
sudo vgdisplay vg_database | grep -E 'Name|Size'

# Step 3: Create Logical Volumes
echo "Creating Logical Volumes..."
sudo lvcreate -L 800G -n lv_data vg_database          # Database data - 800GB
sudo lvcreate -L 300G -n lv_logs vg_database          # Database logs - 300GB
sudo lvcreate -l 100%FREE -n lv_backup vg_database   # Backup - remaining space

sudo lvs vg_database

# Step 4: Create Filesystems
echo "Creating XFS Filesystems..."
sudo mkfs.xfs -L "DB-Data" /dev/vg_database/lv_data
sudo mkfs.xfs -L "DB-Logs" /dev/vg_database/lv_logs
sudo mkfs.xfs -L "DB-Backup" /dev/vg_database/lv_backup

# Step 5: Mount
echo "Mounting volumes..."
sudo mkdir -p /var/lib/mysql/{data,logs,backup}
sudo mount /dev/vg_database/lv_data /var/lib/mysql/data
sudo mount /dev/vg_database/lv_logs /var/lib/mysql/logs
sudo mount /dev/vg_database/lv_backup /var/lib/mysql/backup

# Step 6: Add to /etc/fstab
echo "Adding to /etc/fstab..."
sudo tee -a /etc/fstab > /dev/null << EOF
LABEL=DB-Data    /var/lib/mysql/data    xfs  rw,noatime               0  2
LABEL=DB-Logs    /var/lib/mysql/logs    xfs  rw,noatime               0  2
LABEL=DB-Backup  /var/lib/mysql/backup  xfs  ro,noatime               0  2
EOF

# Step 7: Verify
echo "=== Final Verification ==="
echo "Physical Volumes:"
sudo pvs
echo ""
echo "Volume Groups:"
sudo vgs
echo ""
echo "Logical Volumes:"
sudo lvs -o lv_name,vg_name,lv_size,lv_path
echo ""
echo "Mounted Filesystems:"
df -h /var/lib/mysql/*

echo "\n✓ LVM Storage Setup Complete!"
```

### Resizing Logical Volumes (Key LVM Benefit)

**Grow Logical Volume - No Downtime!**
```bash
# Extend LV by 50GB
sudo lvextend -L +50G /dev/vg_database/lv_data

# Extend LV to 1TB
sudo lvextend -L 1T /dev/vg_database/lv_data

# Extend filesystem to match LV (for XFS - online)
sudo xfs_growfs /var/lib/mysql/data

# For ext4 (online)
sudo resize2fs /dev/vg_database/lv_data
```

**Shrink Logical Volume (requires offline resize)**
```bash
# Shrink filesystem first
sudo umount /dev/vg_database/lv_data
sudo e2fsck -f /dev/vg_database/lv_data
sudo resize2fs /dev/vg_database/lv_data 400G

# Then shrink LV
sudo lvreduce -L 400G /dev/vg_database/lv_data

# Remount
sudo mount /dev/vg_database/lv_data /var/lib/mysql/data
```

### Complete LVM Tutorial
[Digital Ocean - Introduction to LVM](https://www.digitalocean.com/community/tutorials/an-introduction-to-lvm-concepts-terminology-and-operations)


## Network Block Devices (NBD)

**Overview:** NBD (Network Block Device) allows viewing a network-accessible block device as a local block device on a client machine. Data transfers between a remote NBD server and client over the network, making remote storage appear as local /dev/nbd* devices.

**Use Case:**
- Share a physical partition between multiple machines without NFS overhead
- Use remote storage as if it's locally attached (block-level access)
- Live migration of virtual machines with shared storage
- Database replication and backup systems

**Difference from NFS:**
- NFS: File-level sharing (higher latency, suitable for files)
- NBD: Block-level sharing (lower latency, suitable for partitioning, filesystems, databases)

### NBD Architecture: Server and Client

**NBD Server:** Exports a local block device or partition
**NBD Client:** Mounts the remote block device locally via network

Server exports real block devices → Client accesses as virtual block devices

### Step 1: Install NBD Server

**Installation:**
```bash
sudo apt update
sudo apt install nbd-server
sudo systemctl enable nbd-server
sudo systemctl start nbd-server
```

**Verify Installation:**
```bash
nbd-server -v          # Check version
which nbd-server       # Verify path
```

### Step 2: Configure NBD Server (/etc/nbd-server/config)

**File Location:** `/etc/nbd-server/config`

**Configuration Structure:**
```ini
[generic]
    listenaddr = 0.0.0.0        # Server listen address
    port = 10809                # Default NBD port
    allowlist = true            # Enable access control
    includedir = /etc/nbd-server/conf.d  # Include custom configs

[partition1]
    exportname = /dev/sdb1      # Export device/partition
    port = 10809                # Port for this export
    readonly = false            # Read-write access

[partition2]  
    exportname = /dev/sdc1      # Another device
    port = 10810                # Different port
    readonly = true             # Read-only
    clientname = 192.168.1.100  # Restrict client access
```

**Complete Example:**

```ini
[generic]
    listenaddr = 0.0.0.0
    port = 10809
    allowlist = true
    includedir = /etc/nbd-server/conf.d

[db-data]
    exportname = /dev/sdb1
    port = 10809
    readonly = false
    clientname = 192.168.1.50   # Only specific host

[backup-storage]
    exportname = /dev/sdc1
    port = 10810
    readonly = true             # Read-only for safety
    clientname = 192.168.1.*    # Allow subnet

[archive]
    exportname = /dev/sdd1
    port = 10811
    readonly = true
```

**Restart NBD Server:**
```bash
sudo systemctl restart nbd-server
sudo systemctl status nbd-server

# Verify listening ports
sudo ss -tlnp | grep nbd-server
```

### Step 3: Enable Access Control (allowlist, clientname, keys)

**Access Control Features:**

```bash
# Restrict by client IP
[export1]
    exportname = /dev/sdb1
    clientname = 192.168.1.100  # Single IP
    readonly = false

# Restrict by subnet
[export2]
    exportname = /dev/sdc1
    clientname = 192.168.*      # Wildcard match
    readonly = true

# Restrict by hostname
[export3]
    exportname = /dev/sdd1
    clientname = db-server.example.com
    readonly = false
```

**File Permissions:**
```bash
sudo chmod 644 /etc/nbd-server/config
sudo chown root:root /etc/nbd-server/config

# Device permissions
sudo chmod 660 /dev/sdb1
sudo chown root:root /dev/sdb1
```

### Step 4: Load NBD Kernel Module

**Manual Loading:**
```bash
# Load NBD module
sudo modprobe nbd

# Create up to 128 NBD devices
sudo modprobe nbd nbds_max=128

# Verify
lsmod | grep nbd
```

**Persistent Loading (/etc/modules-load.d/nbd.conf):**
```bash
# Create config file
sudo bash -c 'echo "nbd nbds_max=128" > /etc/modules-load.d/nbd.conf'

# Verify
cat /etc/modules-load.d/nbd.conf
```

### Step 5: Connect NBD Client to Server

**Client Installation:**
```bash
sudo apt install nbd-client
```

**Connect to Server:**

**Syntax:**
```bash
sudo nbd-client <server_ip> -p <port> -N <exportname> /dev/nbd<N>
```

**Examples:**
```bash
# Connect to default export on port 10809
sudo nbd-client 192.168.1.30 -p 10809 /dev/nbd0

# Connect to named export (partition2)
sudo nbd-client 192.168.1.30 -p 10809 -N partition2 /dev/nbd0

# Connect multiple exports
sudo nbd-client 192.168.1.30 -p 10809 -N db-data /dev/nbd0
sudo nbd-client 192.168.1.30 -p 10810 -N backup-storage /dev/nbd1
```

**Verify Connection:**
```bash
lsblk | grep nbd
sudo ss -tnp | grep nbd-client
```

### Step 6: Mount Remote Block Device

**Create Filesystem (if new):**
```bash
sudo mkfs.xfs -L "RemoteData" /dev/nbd0
```

**Create Mount Point and Mount:**
```bash
sudo mkdir -p /mnt/remote-db
sudo mount /dev/nbd0 /mnt/remote-db

# Verify
df -h /mnt/remote-db
```

**Persistent Mount in /etc/fstab:**
```bash
sudo vi /etc/fstab

# Add:
/dev/nbd0  /mnt/remote-db  xfs  rw,noatime,nofail  0  2
/dev/nbd1  /mnt/backup     xfs  ro,noatime,nofail  0  2

# Test
sudo mount -a
```

### Production Example: Database Backup

**Server (/etc/nbd-server/config):**
```ini
[generic]
    listenaddr = 0.0.0.0
    port = 10809
    allowlist = true

[backup-partition]
    exportname = /dev/sdb1      # 1TB backup device
    clientname = 192.168.1.100  # DB server IP
    readonly = false
    port = 10809
```

**Client Setup Script:**
```bash
#!/bin/bash
# Connect and mount remote backup

echo "Loading NBD module..."
sudo modprobe nbd nbds_max=10

echo "Connecting to backup server..."
sudo nbd-client 192.168.1.30 -p 10809 -N backup-partition /dev/nbd0

sleep 1

echo "Mounting remote partition..."
sudo mkdir -p /backup/remote
sudo mount /dev/nbd0 /backup/remote

echo "✓ Remote backup mounted at /backup/remote"
df -h /backup/remote
```

**Disconnect:**
```bash
sudo umount /dev/nbd0
sudo nbd-client -d /dev/nbd0
```

---

## External Storage NAS DAS and SAN

- **DAS:** Direct Attached Storage (Fast, Reliable, attached to single host)
- **NAS:** Network Attached Storage (Shared storage, Network-connected, DBMS-capable)
- **SAN:** Storage Area Network (Large-scale, high-availability, enterprise)

---

## NFS - Network File System

**Overview:** NFS allows mounting filesystems over network from remote servers. Shared storage for multiple clients.

### NFS Server Setup

**1. Install NFS Server:**
```bash
sudo apt update
sudo apt install nfs-kernel-server
sudo systemctl start nfs-server
sudo systemctl enable nfs-server
```

**2. Configure Exports (/etc/exports):**
```bash
sudo vi /etc/exports
```

**Syntax:** `<path> <host1>(options) <host2>(options) <network>(options)`

```bash
/home/backup        192.168.1.10(rw,sync,no_subtree_check)
/data               192.168.1.0/24(rw,sync,no_subtree_check)
/archive            client1.example.com(ro,sync,no_subtree_check)
/export             *(rw,sync,no_subtree_check)      # All hosts
```

**Options Explanation:**

| Option | Purpose |
|--------|---------|
| `rw` | Read-Write access |
| `ro` | Read-Only access |
| `sync` | Write synchronously (safe, slower) |
| `async` | Write asynchronously (faster, risky) |
| `no_subtree_check` | Disable subtree checking (recommended) |
| `insecure` | Allow connections from ports > 1024 |
| `root_squash` | Map root user to nobody (security) |
| `no_root_squash` | Allow root access (risky) |

**3. Apply/Refresh Exports:**
```bash
sudo exportfs -r  # Re-export all entries, keep current mounts
sudo exportfs -a  # Export all entries (unmounts existing)
sudo exportfs -u /data      # Unexport specific path
sudo exportfs -v            # View all exports
```

**Example /etc/exports:**
```bash
# Application backup - read-write to specific host
/backup              192.168.1.20(rw,sync,no_subtree_check,root_squash)

# Database backup - read-only to network
/db-backup           192.168.1.0/24(ro,sync,no_subtree_check,root_squash)

# Archive - read-write to multiple hosts  
/archive             server1(rw,sync) server2(rw,sync) backup(ro,sync)

# Shared data - read-write to all
/shared              *(rw,async,no_subtree_check,insecure)
```

### NFS Client Setup

**1. Install NFS Client:**
```bash
sudo apt update
sudo apt install nfs-common
```

**2. Mount NFS Filesystem:**
```bash
# Temporary mount
sudo mkdir -p /mnt/nfs
sudo mount -t nfs 192.168.1.50:/backup /mnt/nfs
sudo mount -t nfs server.example.com:/data /mnt/data

# Verify
mount | grep nfs
df -h /mnt/nfs
```

**3. Persistent Mount in /etc/fstab:**
```bash
sudo vi /etc/fstab

# Add entries:
192.168.1.50:/backup      /mnt/nfs-backup   nfs   defaults,_netdev,noatime   0  0
server.example.com:/data  /mnt/nfs-data     nfs   rw,sync,noatime,_netdev    0  0
192.168.1.50:/archive     /mnt/archive      nfs   ro,noatime,_netdev         0  0

# Test configuration
sudo mount -a
```

**Fstab NFS Options:**

| Option | Purpose |
|--------|---------|
| `_netdev` | Wait for network before mounting (REQUIRED) |
| `rw`/`ro` | Read-write or read-only |
| `noatime` | Skip atime updates (performance) |
| `hard` | Retry until server responds (default) |
| `soft` | Timeout quickly (risky) |
| `intr` | Allow interrupting hung mounts |
| `vers=4` | Use NFSv4 (recommended) |

**4. Unmount NFS:**
```bash
sudo umount /mnt/nfs
umount -a -t nfs  # Unmount all NFS
```

### Production Scenario - Enterprise NFS Backup Server

**Server Configuration:**
```bash
#!/bin/bash
# NFS server setup for backups

# 1. Install and enable NFS
sudo apt install nfs-kernel-server
sudo systemctl enable nfs-server

# 2. Create export directories
sudo mkdir -p /export/{daily,weekly,archive}
sudo chmod 755 /export/{daily,weekly,archive}

# 3. Configure /etc/exports
cat > /etc/exports << 'EOF'
# Daily backups - read-write to backup clients
/export/daily   192.168.1.10(rw,sync,no_subtree_check,root_squash)
/export/daily   192.168.1.11(rw,sync,no_subtree_check,root_squash)

# Weekly archives - read-only to external access
/export/weekly  192.168.1.0/24(ro,sync,no_subtree_check,root_squash)

# Archive storage - full network access
/export/archive *(ro,sync,no_subtree_check,root_squash)
EOF

# 4. Apply exports
sudo exportfs -r
sudo exportfs -v

# 5. Verify
showmount -e localhost
```

**Client Configuration:**
```bash
#!/bin/bash
# NFS client mount setup

# 1. Install NFS client
sudo apt install nfs-common

# 2. Create mount points
sudo mkdir -p /backup/{local,remote-daily,remote-weekly}

# 3. Mount NFS shares
sudo mount -t nfs 192.168.1.50:/export/daily /backup/remote-daily
sudo mount -t nfs 192.168.1.50:/export/weekly /backup/remote-weekly

# 4. Add to /etc/fstab
cat >> /etc/fstab << 'EOF'
192.168.1.50:/export/daily    /backup/remote-daily    nfs  rw,sync,noatime,_netdev  0  0
192.168.1.50:/export/weekly   /backup/remote-weekly   nfs  ro,noatime,_netdev       0  0
EOF

# 5. Test and verify
sudo mount -a
mount | grep nfs
df -h /backup/*
```

**Diagnostic Commands:**
```bash
# Server side
sudo showmount -e               # List exports
sudo exportfs -v                # Verbose exports
sudo nfsstat                    # NFS statistics
grep "nfs" /var/log/syslog      # Check logs

# Client side
mount | grep nfs                # Show mounted NFS
nfsstat                         # Client NFS stats
showmount -e 192.168.1.50       # View remote server exports
```

---

## Storage Monitoring and I/O Performance

**Overview:** Storage monitoring tracks I/O performance, disk usage patterns, and system bottlenecks. In production environments, identifying which process consumes excessive disk I/O prevents performance degradation and ensures SLA compliance.

### Installation

**Install sysstat package (contains iostat, pidstat, sar):**
```bash
sudo apt update
sudo apt install sysstat
```

**Verify Installation:**
```bash
iostat --version    # Check iostat version
pidstat --version   # Check pidstat version
sar --version       # Check sar version
```

### Understanding iostat Output

**Syntax:**
```bash
iostat                      # Single snapshot
iostat 1                    # Refresh every 1 second
iostat 2 5                  # Refresh every 2 seconds, 5 iterations
iostat -h                   # Human-readable format
iostat -p sda               # Specific partition monitoring
iostat -x                   # Extended statistics (detailed I/O)
```

**Key Metrics Explained:**

| Metric | Meaning | Normal Range |
|--------|---------|-------------|
| `tps` | Transactions Per Second (I/O requests) | < 100 tps is healthy |
| `kB_read/s` | Kilobytes read per second | Varies by workload |
| `kB_wrtn/s` | Kilobytes written per second | Monitor for sustained high writes |
| `r/s` | Read requests per second | < 50 r/s normal |
| `w/s` | Write requests per second | < 50 w/s normal |
| `util%` | Device utilization percentage | > 80% indicates bottleneck |
| `await` | Average I/O wait time (ms) | < 10ms is good; > 50ms is concerning |
| `r_await` | Read await time (ms) | Slow reads indicate contention |
| `w_await` | Write await time (ms) | Slow writes indicate cache pressure |

**Example Output:**
```bash
$ iostat 1
Linux 6.1.0-18-generic (ubuntu)
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           5.12    0.00    3.45   12.30    0.00   79.13

Device             tps    kB_read/s    kB_wrtn/s    kB_dctime    kB_read    kB_wrtn
sda              25.50       102.40       156.80        0.00    1024000   1568000
sdb              18.75        75.20        98.60         0.00     752000    986000
dm-0             12.30        48.90        62.40         0.00     489000    624000
```

**Interpretation:**
- `sda`: 25.50 tps (25 I/O operations/sec), reading 102 MB/s, writing 157 MB/s
- `util%`: Device utilization at 45% (healthy; > 80% = bottleneck)
- `await`: 8.5ms average response time (good; < 10ms ideal)

### Detecting Storage Performance Issues

**Extended Statistics (Detailed I/O Analysis):**
```bash
# Extended statistics with await times
iostat -x 1 2

# Specific device with extended stats
iostat -x -p sda 1
```

**Extended Output:**
```bash
Device: rrqm/s wrqm/s  r/s  w/s  rMB/s  wMB/s r_await w_await util%
sda      0.00   2.50  8.50 16.20 0.103 0.156   5.2    12.5   45.3
dm-0     0.00   0.00  6.50 12.80 0.078 0.125   6.8    14.2   38.5
```

**Metrics:**
- `r_await` > 20ms: Read latency issue
- `w_await` > 30ms: Write cache pressure or disk bottleneck
- `util% > 80%`: Device is saturated

### Finding Processes Using Excessive Disk I/O

**Step 1: Identify High-Activity Process with pidstat**

**Syntax:**
```bash
pidstat -d                      # Disk I/O by process (snapshot)
pidstat -d 1                    # Continuous monitoring, 1-second interval
pidstat -d 1 5 | grep sda       # Monitor for 5 iterations
pidstat -d -e CMD               # Show command names
```

**Key pidstat Metrics:**

| Metric | Meaning |
|--------|---------|
| `kB_rd/s` | Kilobytes read per second per process |
| `kB_wr/s` | Kilobytes written per second per process |
| `Command` | Process name/command |
| `PID` | Process ID |

**Example Output:**
```bash
$ pidstat -d 1
Linux 6.1.0-18-generic (ubuntu)

01:23:45 PM   UID       PID  kB_rd/s  kB_wr/s  Command
01:23:46 PM   1000     2456    102.40 156.80   dd
01:23:46 PM   1000      834      0.00  2.50   rsync
01:23:46 PM    0       1234      0.50  1.20   sshd
```

**Step 2: Identify the Culprit Process**

```bash
# Find the PID of high I/O process
pidstat -d 1 | grep -E "kB_rd/s|kB_wr/s" | sort -k5 -nr

# Get process details
ps -p 2456 -o pid,ppid,user,%mem,%cpu,cmd

# Kill the process if necessary
sudo kill -9 2456
```

### Scenario: Simulating Excessive Disk Write

**Problem:** Disk is saturated, application is slow. Need to identify the culprit.

**Step 1: Replicate High I/O Load (for testing/debugging)**

```bash
# Create large file transfer (write 100GB with dd)
dd if=/dev/zero of=DELETE bs=1M count=100000 oflag=dsync &

# Monitor progress
sleep 2
```

**Step 2: Monitor Disk Activity**

```bash
# In another terminal - watch I/O in real-time
iostat -x 1

# Output shows dm-0 (LVM device) with high writes:
# Device: tps kB_rd/s kB_wrtn/s r_await w_await util%
# dm-0   950.00 0.00  950000.0  0.0    15.2    98.5
```

**Step 3: Find the Process**

```bash
# Find which process is writing
pidstat -d 1

# Output:
# PID  kB_rd/s  kB_wr/s  Command
# 5234     0.00  950000.0  dd

# Get full command
ps -p 5234 -o cmd=
# Output: dd if=/dev/zero of=DELETE bs=1M count=100000 oflag=dsync
```

**Step 4: Find Parent Process Details**

```bash
# Check user and resource limits
ps -p 5234 -o pid,ppid,user,rss,vsz,cmd

# Output:
# PID  PPID  USER RSS(MB) VSZ(MB) CMD
# 5234 4521  root 1.2    10.4    dd if=/dev/zero...

# Stop the process
sudo kill -15 5234
```

### Understanding I/O Devices (LVM and dm devices)

**What is `/dev/dm-0`, `/dev/dm-1`?**

- **dm-N devices:** Logical Volume Manager (LVM) managed volumes
- **LVM device mapper:** Virtual layer between physical disks and logical volumes
- **Example:** `/dev/sda1` (physical) → VG (pool) → `/dev/dm-0` (logical volume)

**Get Mapping Information:**

```bash
# Find which logical volume corresponds to dm-0
sudo dmsetup info /dev/dm-0

# Output:
# Name:              vg_data-lv_app
# State:             LIVE
# Open count:        1
# Event number:      0
# Major, minor:      253, 0
# Number of targets: 1
# UUID: LVM-xxxxx

# Get device mapping details
sudo dmsetup table /dev/dm-0

# Output:
# 0 2097152 linear /dev/sda1 2048
# (maps 2GB to /dev/sda1 starting at block 2048)
```

**Identify Physical Disk Behind dm Device:**

```bash
# List all LVM devices
sudo lvs

# Output:
# LV      VG      Attr LSize   Origin Snap%  Move Log Cpy%Sync
# lv_app  vg_data -wi-ao 100.00g

# See which physical disks are in volume group
sudo vgdisplay vg_data

# Detailed mapping
sudo dmsetup deps /dev/dm-0
# Output: (253, 0) : (8, 1)
# (8, 1) is /dev/sda1
```

### List Block Devices and Identify Storage

**Syntax:**
```bash
lsblk                       # Tree view of all block devices
lsblk -h                    # Human-readable format
lsblk -f                    # Filesystem info
lsblk --tree                # Tree format
lsblk -o NAME,TYPE,SIZE,MOUNT
```

**Example Output:**
```bash
$ lsblk -h
NAME       TYPE   SIZE MOUNT FSTYPE
sda        disk   1.0T
├─sda1     part   500M /boot ext4
└─sda2     part   950G      
vg_data-lv_app lvm    100G /app   xfs
vg_data-lv_backup lvm  50G  /backup xfs
```

### Get Process Information and Take Action

**Find Process Details:**

```bash
# Get full command of PID
ps -p <PID> -o cmd=

# Get process with parent
ps -p <PID> -o pid,ppid,user,etime,cmd

# Find all processes by user writing to disk
pidstat -d 1 | grep <username>

# Count processes by user
ps aux | grep <username> | wc -l
```

**Stopping High I/O Process:**

```bash
# Graceful termination (SIGTERM)
sudo kill -15 <PID>

# Force termination (SIGKILL) - immediate
sudo kill -9 <PID>

# Kill all processes of a user
killall -u <username>

# Kill by process name
killall dd
```

### IOStat Variants and Advanced Monitoring

**Human-Readable Format:**

```bash
# Output in MB/s instead of kB/s
iostat -h 1

# Example:
# Device  tps    MB_read/s MB_wrtn/s
# sda    25.50      0.10      0.15
# sdb    18.75      0.07      0.10
```

**Monitor Specific Partition:**

```bash
# Monitor only /dev/sda
iostat -p sda 1

# Output:
# Device: tps kB_read/s kB_wrtn/s
# sda    25.50   102.40   156.80
# sda1    8.20    12.40     8.50
# sda2   17.30    90.00   148.30
```

**Extended Statistics (Latency Analysis):**

```bash
# Extended with await times
iostat -x 1

# For CPU details
iostat -c 1

# Disk + CPU combined
iostat -cx 1
```

### Production Monitoring Script

**Continuous Disk Monitoring with Alerts:**

```bash
#!/bin/bash
# storage_monitor.sh - Alert on high disk I/O

THRESHOLD_TPS=100
THRESHOLD_UTIL=80
THRESHOLD_AWAIT=50

echo "=== Storage I/O Monitoring ==="
echo "Alerts: tps > ${THRESHOLD_TPS}, util% > ${THRESHOLD_UTIL}%, await > ${THRESHOLD_AWAIT}ms"
echo ""

while true; do
  iostat -x 1 2 | tail -5 | while read line; do
    TPS=$(echo "$line" | awk '{print $2}')
    UTIL=$(echo "$line" | awk '{print $NF}')
    AWAIT=$(echo "$line" | awk '{print $(NF-2)}')
    
    if (( $(echo "$TPS > $THRESHOLD_TPS" | bc -l) )); then
      echo "⚠️  WARNING: High TPS on device: $line"
    fi
    
    if (( $(echo "$UTIL > $THRESHOLD_UTIL" | bc -l) )); then
      echo "🔴 ALERT: Device saturated (util%: $UTIL) - $line"
      pidstat -d 1 1 | tail -3
    fi
  done
  
  sleep 5
done
```

**Quick Health Check:**

```bash
#!/bin/bash
echo "=== Storage Health Check ==="

echo ""
echo "1. Disk Utilization:"
df -h | grep -v "Filesystem" | awk '{print $1, $5}' | column -t

echo ""
echo "2. I/O Performance (top 5 offenders):"
pidstat -d 1 1 2>/dev/null | tail -6 | sort -k4 -nr | head -5

echo ""
echo "3. Storage Device Status:"
iostat -h 1 2 | tail -4

echo ""
echo "4. High Await Time Check:"
iostat -x 1 2 | tail -5 | awk '$NF > 50 {print "⚠️  " $1 " - High await: " $NF "ms"}'
```

**Run Health Check:**
```bash
bash storage_monitor.sh

# Output:
# === Storage Health Check ===
#
# 1. Disk Utilization:
# /dev/sda1 45%
# /dev/dm-0 62%
#
# 2. I/O Performance (top 5 offenders):
# 2456 102.40 156.80 dd
# 834  0.00   2.50   rsync
#
# 3. Storage Device Status:
# sda 25.50 tps, 102.40 MB_read/s, 156.80 MB_wrtn/s, 45% util
#
# 4. High Await Time Check:
# ⚠️  sda - High await: 15.2ms
```

### Quick Reference: Common Commands

```bash
# Real-time disk I/O
iostat -x 1

# By process
pidstat -d 1

# Find device for dm-0
dmsetup table /dev/dm-0

# LVM status
lvs

# Block devices
lsblk -h

# Disk usage
df -h

# Monitor specific partition
iostat -p sda 1

# Kill high I/O process
pidstat -d 1 | head -5  # Find PID → sudo kill -15 <PID>
```

---

## Access Control Lists (ACL) and File Attributes

### Access Control Lists (ACL) - Advanced File Permissions

**Overview:** Standard Linux file permissions (rwx) support only three categories: owner, group, and others. ACLs (Access Control Lists) extend permissions to define granular access for multiple users and groups on the same file, enabling scenarios where a file needs to be accessed by users who are not the owner and may not be in the owning group.

**When to Use ACL:**
- Application server needs read access to a database backup owned by another user
- Contract worker needs temporary access to specific project files
- Shared project directory where different teams need different permission levels
- Database backups accessible by multiple DBAs with different permission requirements

**Standard Permissions vs ACL:**
```
Standard:     -rw-r--r-- (owner can read/write, group read-only, others read-only)
With ACL:     -rw-r--r-+ (+ indicates ACL is applied)
              + user:alice:rwx (Alice can read/write/execute)
              + user:bob:r-- (Bob can only read)
              + group:devops:rwx (Devops group has full access)
```

### Setting ACL Permissions with setfacl

**Syntax:**
```bash
sudo setfacl --modify user:<username>:<permissions> <file>
sudo setfacl --modify group:<groupname>:<permissions> <file>
sudo setfacl -m u:<username>:<permissions> <file>   # Short form
sudo setfacl -m g:<groupname>:<permissions> <file>  # Short form
```

**Permissions:** `r` (read), `w` (write), `x` (execute), combination like `rw`, `rx`, `rwx`, or leave blank for no permissions

**Examples:**

**Example 1: Grant User Read-Write Access**
```bash
# User 'alice' gets read-write access to file3
sudo setfacl -m u:alice:rw /tmp/file3

# Verify
ls -l /tmp/file3
# Output: -rw-r--r--+ 1 owner group 0 (note the '+' indicating ACL)
```

**Example 2: Grant Group Read-Only Access**
```bash
# 'developers' group gets read-only access
sudo setfacl -m g:developers:r /tmp/file3

# Multiple users
sudo setfacl -m u:alice:rw,u:bob:r,u:charlie:rwx /tmp/file3
```

**Example 3: Recursive ACL for Directories**
```bash
# Apply to directory and all contents
sudo setfacl -R -m u:alice:rwx /var/www/project/

# Recursive with default for future files
sudo setfacl -R -m d:u:alice:rwx /var/www/project/
```

**Example 4: Remove Specific ACL Entry**
```bash
# Remove alice's access
sudo setfacl -x u:alice /tmp/file3

# Remove group access
sudo setfacl -x g:developers /tmp/file3
```

**Example 5: Remove All ACL (restore standard permissions)**
```bash
sudo setfacl --remove-all /tmp/file3
sudo setfacl -b /tmp/file3  # Short form
```

### Viewing ACL Permissions with getfacl

**Syntax:**
```bash
getfacl <file>                    # View ACL for single file
getfacl -R <directory>            # View ACL recursively
getfacl <file1> <file2> ...       # View multiple files
```

**Example:**

```bash
# View ACL on file
getfacl /tmp/file3

# Output:
# file: /tmp/file3
# owner: root
# group: root
# user::rw-                    # Owner permissions
# user:alice:rw-              # Alice has rw access
# user:bob:r--                # Bob has r access
# group::r--                  # Group permissions
# group:developers:r--        # Developers group has r access
# mask::rw-                   # Effective permission mask
# other::r--                  # Others permissions
```

**Understanding ACL Output:**

- `user::rw-` → Owner has read-write
- `user:alice:rw-` → User 'alice' has read-write (shown with +)
- `group::r--` → Group 'root' has read-only
- `mask::rw-` → Maximum permissions (acts as filter for all users/groups)
- `other::r--` → Others have read-only

### Production Example: Database Backup Access

**Scenario:** Database backups need to be accessed by multiple DBAs, backup scripts, and auditors with different permission levels.

**Setup:**

```bash
#!/bin/bash
# Setup ACL for database backup file

BACKUP_FILE="/backup/database_full_backup.sql"
AUDIT_FILE="/backup/audit.log"

# Create backup as root with restricted permissions
sudo touch "$BACKUP_FILE" "$AUDIT_FILE"
sudo chmod 600 "$BACKUP_FILE"  # Only owner can read
sudo chmod 640 "$AUDIT_FILE"   # Owner rw, group r

# Grant permissions to different users
echo "Setting up ACLs for database backups..."

# Primary DBA (full access)
sudo setfacl -m u:dba_primary:rw "$BACKUP_FILE"

# Secondary DBA (read-only)
sudo setfacl -m u:dba_secondary:r "$BACKUP_FILE"

# Backup automation script (read-only for validation)
sudo setfacl -m u:backup_user:r "$BACKUP_FILE"

# Auditors (read audit log only)
sudo setfacl -m u:auditor1:r "$AUDIT_FILE"
sudo setfacl -m u:auditor2:r "$AUDIT_FILE"
sudo setfacl -m g:audit_team:r "$AUDIT_FILE"

# Verify
echo ""
echo "=== Database Backup ACLs ==="
getfacl "$BACKUP_FILE"
echo ""
getfacl "$AUDIT_FILE"

# Remove access (when contract ends)
echo ""
echo "Removing auditor1 access (when contract ends)..."
sudo setfacl -x u:auditor1 "$AUDIT_FILE"
getfacl "$AUDIT_FILE"
```

**Output:**
```bash
# Database backup ACL
file: /backup/database_full_backup.sql
owner: root
group: root
user::rw-
user:dba_primary:rw-         # Primary DBA - read-write
user:dba_secondary:r--       # Secondary DBA - read-only
user:backup_user:r--         # Backup script - read-only
group::---
mask::rw-
other::---

# Audit log ACL
file: /backup/audit.log
owner: root
group: root
user::rw-
user:auditor1:r--            # Auditor 1 - read-only
user:auditor2:r--            # Auditor 2 - read-only
group::r--
group:audit_team:r--         # Audit team - read-only
mask::rw-
other::---
```

---

### File Attributes with chattr (immutable, append-only)

**Overview:** Beyond standard permissions (rwx) and ACLs, Linux file attributes provide additional protection through `chattr` (change attributes). These attributes control fundamental file behavior - preventing deletion, restricting to append-only, or freezing files from any modification.

**Common Attributes:**

| Attribute | Symbol | Description | Use Case |
|-----------|--------|-------------|----------|
| `immutable` | `i` | File cannot be deleted, renamed, or modified | Critical system configs, ensure compliance |
| `append` | `a` | File can only be appended (no overwrite) | Log files, audit trails, guarantee data integrity |
| `secure-delete` | `s` | Data securely deleted (overwritten) | Sensitive files |
| `no-dump` | `d` | File excluded from backups | Temporary files, cache |
| `no-atime` | `A` | Disable atime updates | Performance improvement |
| `compressed` | `c` | File automatically compressed | Large files |
| `undeletable` | `u` | Data not overwritten on deletion | Recovery capability |

### Append-Only Attribute (+a)

**Purpose:** File can only be appended; existing content cannot be modified or deleted. Perfect for log files and audit trails where data integrity is critical.

**Set Append-Only:**
```bash
# Make file append-only
sudo chattr +a /var/log/audit.log

# Verify
lsattr /var/log/audit.log
# Output: -----a----------e-- /var/log/audit.log

# Try to overwrite (will fail)
echo "new data" > /var/log/audit.log
# Error: Permission denied (immutable)

# Append works
echo "new log entry" >> /var/log/audit.log  # ✓ Success

# Try to delete (will fail)
rm /var/log/audit.log
# Error: Operation not permitted
```

**Remove Append-Only:**
```bash
sudo chattr -a /var/log/audit.log
```

**Production Example - Append-Only Logs:**

```bash
#!/bin/bash
# Setup append-only for critical audit logs

LOG_FILES=(
    "/var/log/auth.log"
    "/var/log/syslog"
    "/var/log/audit/audit.log"
    "/var/log/mysql/general_query.log"
)

echo "Setting append-only attribute on critical logs..."
for log in "${LOG_FILES[@]}"; do
    if [[ -f "$log" ]]; then
        sudo chattr +a "$log"
        echo "✓ $log is now append-only"
    else
        echo "⚠ $log not found"
    fi
done

# Verify all logs
echo ""
echo "=== Append-Only Log Status ==="
lsattr "${LOG_FILES[@]}"

# Test: attempt to modify (will fail)
echo ""
echo "Testing write protection..."
echo "test" > /var/log/auth.log 2>&1 || echo "✓ Write overwrite blocked (expected)"

# Append still works
echo "test" >> /var/log/auth.log && echo "✓ Append succeeded (expected)"
```

### Immutable Attribute (+i)

**Purpose:** File becomes "frozen" - cannot be deleted, renamed, or modified. No one (including root) can change it without removing the immutable attribute first.

**Set Immutable:**
```bash
# Make file immutable
sudo chattr +i /etc/hostname

# Verify
lsattr /etc/hostname
# Output: ----i-----------e-- /etc/hostname

# Try to delete (fails even as root)
sudo rm /etc/hostname
# Error: Operation not permitted

# Try to modify (fails)
sudo echo "newhost" > /etc/hostname
# Error: Permission denied

# To remove immutable first, unset attribute
sudo chattr -i /etc/hostname  # Now can be deleted/modified
```

**Production Example - Protect Critical System Files:**

```bash
#!/bin/bash
# Protect critical system configuration files

CRITICAL_FILES=(
    "/etc/passwd"
    "/etc/shadow"
    "/etc/group"
    "/etc/sudoers"
    "/etc/hostname"
    "/root/.ssh/authorized_keys"
)

echo "Protecting critical system files..."
for file in "${CRITICAL_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        sudo chattr +i "$file"
        sudo lsattr "$file"
        echo "✓ $file is immutable"
    fi
done

# Prevent accidental modifications to iptables rules
sudo chattr +i /etc/iptables/rules.v4
sudo chattr +i /etc/iptables/rules.v6

echo ""
echo "=== All critical files are immutable ==="
echo "To modify, first run: sudo chattr -i <filename>"
```

### Viewing File Attributes with lsattr

**Syntax:**
```bash
lsattr <file>                     # View attributes for single file
lsattr -R <directory>             # Recursive view
lsattr -d <directory>             # Directory attributes only
lsattr -v <file>                  # Show version number
```

**Understanding lsattr Output:**

```bash
$ lsattr /var/log/auth.log
-----a----------e-- /var/log/auth.log

# Legend: First 16 characters represent attributes
# Position 1 (-): secure-delete (s)
# Position 2 (-): undelete (u)
# Position 3 (-): compress (c)
# Position 4 (-): no-dump (d)
# Position 5 (a): append-only (a) ← This file is append-only
# Position 6 (-): immutable (i)
# ...
# (e) at end: extent format
```

**Common Outputs Explained:**

```bash
-----a----------e--   # Append-only (logs, audit trails)
----i-----------e--   # Immutable (critical configs)
-----A----------e--   # No-atime updates (performance)
-su--a----------e--   # Append-only + Secure delete (highly protected)
--c--A----------e--   # Compressed + No-atime (large files)
```

### Production Scenario - Multi-Layer File Protection

**Scenario:** Implement comprehensive protection for an e-commerce database backup that must pass compliance audits.

```bash
#!/bin/bash
# Multi-layer protection: permissions + ACL + attributes

BACKUP_FILE="/backup/ecommerce_db_backup.sql.gz"

echo "=== Setting up Compliance-Grade File Protection ==="

# Step 1: Create file with restrictive base permissions
sudo touch "$BACKUP_FILE"
sudo chmod 600 "$BACKUP_FILE"  # Only owner (backup_user) can read/write
sudo chown backup_user:backup_group "$BACKUP_FILE"

# Step 2: Set ACL for multiple DBA access
echo ""
echo "Step 1: Setting ACL for controlled DBA access..."
sudo setfacl -m u:dba_primary:r "$BACKUP_FILE"      # DBA Primary - read-only
sudo setfacl -m u:dba_secondary:r "$BACKUP_FILE"    # DBA Secondary - read-only
sudo setfacl -m g:compliance:r "$BACKUP_FILE"       # Compliance team - read-only

# Step 3: Set append-only attribute (ensure no accidental overwrite)
echo ""
echo "Step 2: Setting append-only attribute..."
# Actually, for read-only backups, use immutable instead
sudo chattr +i "$BACKUP_FILE"

# Step 4: Disable backup (ensure backup software doesn't include it)
sudo chattr +d "$BACKUP_FILE"  # no-dump attribute

# Step 5: Disable atime tracking (performance + security)
sudo chattr +A "$BACKUP_FILE"

# Verify everything
echo ""
echo "=== Final Protection Status ==="
echo ""
echo "File Permissions:"
ls -l "$BACKUP_FILE"

echo ""
echo "File Attributes:"
lsattr "$BACKUP_FILE"

echo ""
echo "ACL Configuration:"
getfacl "$BACKUP_FILE"

echo ""
echo "=== Protection Summary ==="
echo "☑ Base permissions: 600 (owner only)"
echo "☑ ACL: 3 users/groups with read-only access"
echo "☑ Immutable attribute: Cannot be deleted/modified (even by root)"
echo "☑ No-dump attribute: Excluded from regular backups"
echo "☑ No-atime: Performance optimization"
echo ""
echo "To modify/delete this file, admin must:"
echo "  1. sudo chattr -i $BACKUP_FILE"
echo "  2. sudo setfacl -b $BACKUP_FILE (if removing ACL)"
echo "  3. sudo rm/chmod the file"
```

**Output:**
```bash
=== Final Protection Status ===

File Permissions:
-rw------- 1 backup_user backup_group 1.2G backup_file.sql.gz
(Only backup_user can read/write in base permissions)

File Attributes:
---d-i------A--e-- /backup/ecommerce_db_backup.sql.gz
(d=no-dump, i=immutable, A=no-atime)

ACL Configuration:
getfacl: Removing leading '/' from absolute path names
# file: backup/ecommerce_db_backup.sql.gz
# owner: backup_user
# group: backup_group
user::rw-
user:dba_primary:r--       ← Read-only for DBA Primary
user:dba_secondary:r--     ← Read-only for DBA Secondary
group::---
group:compliance:r--       ← Read-only for Compliance team
mask::rw-
other::---

=== Protection Summary ===
☑ Base permissions: 600 (owner only)
☑ ACL: 3 users/groups with read-only access
☑ Immutable attribute: Cannot be deleted/modified (even by root)
☑ No-dump attribute: Excluded from regular backups
☑ No-atime: Performance optimization

To modify/delete this file, admin must:
  1. sudo chattr -i /backup/ecommerce_db_backup.sql.gz
  2. sudo setfacl -b /backup/ecommerce_db_backup.sql.gz (if removing ACL)
  3. sudo rm/chmod the file
```

### Quick Reference: ACL and Attributes

**ACL Commands:**
```bash
# Add user access
sudo setfacl -m u:username:rw /file

# Add group access
sudo setfacl -m g:groupname:r /file

# Remove user access
sudo setfacl -x u:username /file

# Remove all ACL
sudo setfacl -b /file

# View ACL
getfacl /file

# Recursive ACL
sudo setfacl -R -m u:username:rwx /directory
```

**Attribute Commands:**
```bash
# Set append-only (logs)
sudo chattr +a /file

# Remove append-only
sudo chattr -a /file

# Set immutable (critical files)
sudo chattr +i /file

# Remove immutable
sudo chattr -i /file

# View attributes
lsattr /file

# Multiple attributes
sudo chattr +d +A +i /file  # no-dump, no-atime, immutable
```

**Common Use Cases:**
```bash
# Log file protection
sudo chattr +a /var/log/custom.log              # Append-only
sudo setfacl -m g:admins:r /var/log/custom.log # Admins read-only

# Database backup (immutable)
sudo chattr +i /backup/database.sql.gz
sudo setfacl -m u:dba:r /backup/database.sql.gz

# Shared project (collaborative)
sudo setfacl -R -m g:devteam:rwx /projects/app/
sudo setfacl -R -m d:g:devteam:rwx /projects/app/

# Secure sensitive file
sudo chattr +i /etc/shadow                      # Immutable
sudo setfacl -m u:root:r /etc/shadow            # Root read-only
```

---

## ![](../media/File_system/nfs_1.png)