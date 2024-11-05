## Content

- [Introduction](#introductionhttpswwwgeeksforgeeksorgwhat-is-selinux)
- [Modes in Selinux](#modes-in-selinux)

## [Introduction](https://www.geeksforgeeks.org/what-is-selinux/)

SELinux is a special security system built into Linux computers. 
It helps keep your computer safe and secure. With SELinux, different programs and users on the computer have limited permissions. This means each program or user can only access certain files and do certain actions that they are allowed to do. For example, The web browser can connect to the internet but it cannot read your private documents. This prevents viruses and hackers from gaining full control over your system if they get into one program.

## Modes in SElinux
  SELinux Modes
1. Enforcing mode : This is default and most secure. SELinux actively enforces the policy rules, denying any unauthorized access attempts. Blocked attempts are logged.


2. Permissive mode : Less secure but still monitors access. SELinux just logs what would be blocked by policies, but doesn't actually block it. Useful for testing.


3. Disabled mode : SELinux is completely turned off removing all the access protection. This mode is Only for the troubleshooting.

## Steps and commands 

### Installation 
```commandline
sudo apt-get install selinux
```

### Fie associated with selinux-config
```commandline
cat /etc/selinux/config
```

### To see the status of the se-linux
Displays the status of the selinux
```commandline
sestatus

getenforce
```

### Change the status or mode of SElinux
0 -> permissive
1 -> enforcing
```commandline
setenforce 0

selinux-config-enforcing enforcing
```

[Example on applying the policy](https://www.computernetworkingnotes.com/linux-tutorials/selinux-explained-with-examples-in-easy-language.html)