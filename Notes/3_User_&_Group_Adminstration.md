## Content

1. [User Administration](#user-administration)
2. [Types of User](#types-of-user-in-linux)
3. [Creating User](#creating-the-user)
4. [Group Administration](#group-administartion)
5. [Sudoers](#sudoers)
6. [Groups and Owners](#groups-and-owners)
7. [SUID,SGID & Sticky Bit](#suid-sgid--sticky-bit)

## User Administration
![img.png](../media/User_Administartion/User_admin_1.png)

### Commands
#### To know the user name of the current user
```
whoami
```
#### [Username info file passwd file](https://www.cyberciti.biz/faq/understanding-etcpasswd-file-format/)
```commandline
vi /etc/passwd
```
Structure

![img.png](../media/User_Administartion/User_admin_3.png)

#### [Password info file shadow file](https://www.cyberciti.biz/faq/understanding-etcshadow-file/)
Note: Only root user will have the privilege to open or edit the file
```commandline
vi /etc/shadow
```
Structure:

![img.png](../media/User_Administartion/User_admin_4.png)


## Types of User in Linux
![img.png](../media/User_Administartion/User_admin_2.png)

Super User: Root User

System User: Users created on software installation such as mysql, ftp etc.

Normal User: User created by root


## Creation of User
![img.png](../media/User_Administartion/User_admin_5.png)


    Note: !!!!!!! All below commands performed in root user level !!!!!!!

### Creating the user 
```commandline
useradd -u 1024 -g 1024 -d /home/sas/ -c 'sas_user' -s /bin/bash sas
```

Check in `/etc/passwd` file for the user entry

Note: Make sure that the group Id exists

### Creating the group
```commandline
group add -g 1024 sas
```

Check in `/etc/group` for the group entry

### Set password for the user
Note: Good pratice to add the password using the passwd command. There is option -p while using the
useradd command, where is exposes in terminal
```commandline
passwd sas
```
Prompts for the password to be entered.


![img.png](../media/User_Administartion/User_admin_6.png)
### Modify the username

Changing the user name from sas -> sasuser
```commandline
usermod sasuser sas
```

### Unlock / lock the user
Locking the user means, we unable to login with the user 
```commandline
usermod -L sasuser
```

![img.png](../media/User_Administartion/User_admin_7.png)

### Changing the password parameters
```commandline
chage sasuser
```
It prompts the values to be entered

![img.png](../media/User_Administartion/User_admin_8.png)

### Deleting the user
```commandline
userdel sasuser
```

## Group Administartion

The commands specific to group administration as follows

![img.png](../media/User_Administartion/group_admin_1.png)

### Creating the User
```Syntax: groupadd <option>  <name of the group>```
```commandline
groupadd -g 1027 sasgroup
```
Creates the sasgroup with group id 1027

### Viewing the group entries
```commandline
vi /etc/group
```
Structure:

![img.png](../media/User_Administartion/group_admin_4.png)

### Setting the password for the group
```commandline
gpasswd sasgroup

file: vi /etc/gshadow/
```

### Modifying the group details
![img.png](../media/User_Administartion/group_admin_2.png)

### Adding the user to the group
![img.png](../media/User_Administartion/group_admin_3.png)

Command to add the ``sasuser`` under the ``sasgroup``
```commandline
usermod -G sasgroup sasuser
```

### Removing the user from the group
```commandline
Syntax: gpasswd -d <user> <group>
```
Command

```commandline
gpasswd -d sasuser sasgroup 
```

The Addition or deletion of user from the group been verified in ``/etc/group`` file entry.

## Sudoers

- Sudo - Root privileges on the commands
- `/etc/sudoers` contains the info the permission (root) given to the user

![img](../media/User_Administartion/sudoers_1.png)

## Groups and Owners

- `chgrp <group> <file>` To change the group of file or folder
- `chown <user> <file>` To change the owner of file or folder
- `chowb <user>:<group> <file>` To Change both the user and group 

Note: Action requires the `sudo` 

## [SUID, SGID & Sticky-bit](https://www.scaler.com/topics/special-permissions-in-linux/)

- `SUID` Special permission that allows users to run an executable with the permission of the executable's owner

![](../media/User_Administartion/suid.png)

- `S` suid enabled without execute permission
- `s` suid enabled with executable permission

```commandline
# First digit should be 4 on chmod
chmod 4666 <filename>
```

- `SGID` Similar permission, but applies to both executables and directories, used for collaborating

![](../media/User_Administartion/sgid.png)


```commandline
# First Digit can be 2 
chmod 2466 <filename>

find . -perm /6000 - To find the files with permission enabled
```

- `Sticky-bit` A special permission that can be set on directories It restricts file deletion in that directory

![](../media/User_Administartion/stickybit.png)

