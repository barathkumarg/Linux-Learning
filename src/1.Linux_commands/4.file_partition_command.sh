fdisk -l
# to view existing partition
lsblk
# to list disk with minimal info
echo "---" > /sys/class/scsi_host/host0/scan
echo "---" > /sys/class/scsi_host/host1/scan
echo "---" > /sys/class/scsi_host/host2/scan
# to check whether the new disk is added or not without restarting
fdisk /dev/sdc
# used to partition the disk. inside the creation terminal we can have options to create the partition
partprobe /dev/sdc
# used to update partition
mkfs.ext4 /dev/sdc1
# used to format the file system in the partition
mount /dev/sdc1 /respected-file
# if you want use formatted file sytem partition, u need to mount it. above one is temporary mounting
vim /etc/fstab
# in this file, you need insert your mounted partition. so it would become permanent
umount /respected-file/
# used to unmount
mount -a
# is used to mount all the dirs which are all unmounted
fuser -cu /dev/sdc1
# is used to check who are all accessing the dir now.
free -m
# is used to show swap and RAM space
mkswap /dev/sdc1
# is used to make use of swap memory in partition
swapon /dev/sdc1
# activate swap memory
swapoff /dev/sdc1
# deactivate swap memory

