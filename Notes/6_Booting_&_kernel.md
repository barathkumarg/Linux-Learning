# Content
1. [Booting and Kernel](#booting--kernel) 
2. [System Boot Restart Commands]

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


## System Boot Restart Commands

- To reboot the system 
```commandline 
systemctl reboot
```

- To Power Off the system 
```commandline 
systemctl poweroff
```

Used  -f to force and `sudo` to elavate permission

- Shutdown commands - handy om scheduled actions

```commandline
# To shutdown at 2 A.M
shutdown 02:00

# To shutdown after specified minutes (here :15)
shutdown +15

# With message, users will be notified on shutdown
shutdown +1 'Machine Scheduled for shutdown'


Note: use `-r` option to reboot
```

## System info change

- We can change the system prop to use graphical interface, multi user login and so. Following commands modifies

```commandline
systemctl get default

# Change the mode to multiple user mode
systemctl set-default multi-user.target


Note: requires machine re-boot

# Without reboot use the following
systemctl isolate graphical.target

```

## Runtime Parameters (sysctl)

Runtime parameters are kernel settings that can be viewed and modified using `sysctl`.

### View Runtime Parameters

- **View all parameters:**
```commandline
sudo sysctl -a
```

- **Check a specific parameter:**
```commandline
sudo sysctl <parameter>
```

### Modify Runtime Parameters

- **Set parameter temporarily (not persistent, reverted on reboot):**
```commandline
sudo sysctl -w <parameter>=<value>
```

### Make Changes Persistent

To ensure sysctl changes survive a reboot:

1. **Save configuration** in `/etc/sysctl.d/*.conf`:
```commandline
sudo vi /etc/sysctl.d/99-custom.conf
# Add your parameters here
```

2. **Apply changes immediately from configuration file:**
```commandline
sudo sysctl -p /etc/sysctl.d/99-custom.conf
```

Changes will be automatically applied on next boot from the configuration files in `/etc/sysctl.d/`.