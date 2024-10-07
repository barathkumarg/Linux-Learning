# Create a partition and change the id to LVM(8e) for the partition
pvcreate /dev/sdd1
# creation of physical volume
vgcreate redhat /dev/sdd1
# creation of  volume group
lvcreate -L 1GB -n centos redhat 
# creation of logical  volume 
mkfs.ext4 /dev/redhat/centos
# creation of file system
mkdir ubuntu
vim /etc/fstab
# make the permanent mounting in that file.  ex: /dev/redhat/centos /ubuntu  ext4 defaults 0 0
mount -a
lvextend -L +1GB /dev/redhat/centos
# extending logical volume
resize2fs /dev/redhat/centos
# need to update file system for extending logical volume

# reducing logical volume
vim /etc/fstab
# make a comment on ubunut directory as we are removing the extended volume
umount /ubuntu/
e2fsck -f /dev/redhat/centos
# force check whether file seems to be cleaned for removing
resize2fs /dev/redhat/centos 1G
# we need to give actual size which after the reduction size value
lvreduce -L -1G /dev/redhat/centos
# uncomment in fstab and mount again tocheck whether sizes are affected


#deletion
#umount volumes b4 deletion
lvremove /dev/redhat/centos
# removal of logical volume
vgremove redhat
# removal of volume group
pvremove /dev/sdd1

#creation of PE and LE
pvcreate /dev/sdd1
# convert your physical volume size into mebibit for physical extent(PE)
vgcreate redhat -s 5120 /dev/sdd1
lvcreate -l 1024 -n centos redhat
# -l is used as logical extent
# make mkfs and permanent mounting








