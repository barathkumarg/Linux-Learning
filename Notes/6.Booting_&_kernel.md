## Booting & Kernel

Components in the Booting procedure
- BIOS [Basic Input and Output System]
- MBR [Master Boot Recorder]
- GRUB [Grand Unified Boot Loader]
- Kernel
- Init

## BIOS
- Checks the system integrity
- Searches and loads the MBR

## MBR
- Located in the first sector of the disk, which storage in 512 MB
- Parted into 3 sections


    1.Primary Boot Loader - 456 bytes

    2.Partition Table - 16 Bytes

    3.MBR Validation check - 2 Bytes

- Contains the information of grub, it executes the GRUB Part 

## GRUB 
- Selects the apt kernel, available. E.g. selecting the OS in dual boot OS page.
- `unmae -r` To get the kernel name or type
- `cat /boot/grub/grub.conf` Contains the kernel information

## Kernel
- Mount the filesystem in grub.conf
- execute the init.d (Process PID : 1)
- initrd act as the Temporary RAM


## Init
- First Process created in the system
- run level (backgroung process on deamon, responsible to run the services)
- Starts the services associated with the rc.init files in /etc directory

#
3Run level
- Types on runlevel
- 
| Runlevel |  Description   |
|----------|-----|
| 0        |  System halt i.e., the system can be safely powered off with no activity. |
| 1        |   Single user mode.  | 
| 2        |  Multiple user mode with no NFS (network file system).      |
| 3        | Multiple user modes under the command line interface and not under the graphical user interface. |
| 4        |User-definable. |
| 5        |Multiple user mode under GUI (graphical user interface) and this is the standard runlevel for most of the LINUX-based systems.|
| 6        |Reboot which is used to restart the system.|


**References**

[runlevel](https://www.geeksforgeeks.org/run-levels-linux/)

[Run - 1 To recover the root user password](https://gcore.com/learning/how-to-reset-password-in-linux/)
