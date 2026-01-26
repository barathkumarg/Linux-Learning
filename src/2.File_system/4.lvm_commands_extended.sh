#!/bin/bash

# Logical Volume Management (LVM) Extended Commands
# Reference: 2_File_systems.md

# LVM enables dynamic storage management, allowing seamless resizing and allocation

# ============ LVM Components ============
# Physical Volume (PV) - Physical disk or partition
# Volume Group (VG) - Collection of PVs
# Logical Volume (LV) - Virtual partitions carved from VG

# ============ Physical Volume Commands ============

# Create a physical volume
sudo pvcreate /dev/sdb /dev/sdc

# Display physical volumes
sudo pvdisplay

# List physical volumes in short format
sudo pvs

# Remove a physical volume
sudo pvremove /dev/sdb

# ============ Volume Group Commands ============

# Create a volume group
sudo vgcreate vg01 /dev/sdb /dev/sdc

# Display volume groups
sudo vgdisplay

# List volume groups in short format
sudo vgs

# Extend a volume group by adding new PV
sudo vgextend vg01 /dev/sdd

# Reduce a volume group by removing PV
sudo vgreduce vg01 /dev/sdd

# Remove a volume group
sudo vgremove vg01

# ============ Logical Volume Commands ============

# Create a logical volume
# -L size -n name volume_group
sudo lvcreate -L 10G -n lv_data vg01

# Create with percentage of VG
sudo lvcreate -l 50%VG -n lv_data vg01

# Display logical volumes
sudo lvdisplay

# List logical volumes in short format
sudo lvs

# Extend a logical volume
sudo lvextend -L +5G /dev/vg01/lv_data

# Reduce a logical volume (CAUTION: may lose data)
sudo lvreduce -L -5G /dev/vg01/lv_data

# Remove a logical volume
sudo lvremove /dev/vg01/lv_data

# ============ Filesystem Operations on LV ============

# Create filesystem on logical volume
sudo mkfs.ext4 /dev/vg01/lv_data

# Mount the logical volume
sudo mkdir -p /mnt/lv_data
sudo mount /dev/vg01/lv_data /mnt/lv_data

# Resize filesystem after extending LV
sudo resize2fs /dev/vg01/lv_data

# For XFS filesystem
# sudo xfs_growfs /mnt/lv_data

# ============ Snapshots ============

# Create a snapshot of a logical volume
sudo lvcreate -L 2G -s -n lv_data_snap /dev/vg01/lv_data

# Merge snapshot back to original
sudo lvconvert --merge /dev/vg01/lv_data_snap

echo "LVM extended commands examples completed!"
