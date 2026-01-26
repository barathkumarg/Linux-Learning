# Content
- [SSH](#ssh)
- [SSH Process on VM](#ssh-process-in-virtual-machine)
- [SSH Passwordless login](#ssh-passwordless-login)
- [SCP](#scp-secure-copy)
- [Rsync](#rsync)
- [Disk imaging](#disk-imaging)


## [SSH](https://www.techtarget.com/searchsecurity/definition/Secure-Shell)
SSH stands for secure shell, helps to remotely connect to the servers.
Before using SSH `Telnet` used to remotely connect the servers, which not involves any encryption
and prone to man in the middle attacks.

SSH creating a secure channel between local and remote computers,
SSH is used to manage routers, server hardware, virtualization platforms, 
operating systems (OSes), and inside systems management and file transfer applications.

## [SSH Process in virtual machine](https://averagelinuxuser.com/ssh-into-virtualbox/)
- Installation of ssh-server (sshd automatically installed) in the host machine, such that which the machine to be accessed
- Installation of ssh-client in the machine which supposed to be accessing the remote server
- Applying the NAT Rule 

SSH Syntax
```
ssh <username>@<ip-address>

logs into the specified user directory
```

e.g.
```
ssh username@10.10.10.10

Logs into the username's space in the machine, probably in /home/username directory
```

## [SSH Passwordless Login](https://www.techtarget.com/searchsecurity/tutorial/Use-ssh-keygen-to-create-SSH-key-pairs-and-more)
- In general ssh into the system was password protected, everytime we enter the system  we need to give the password
- We can achieve the passwordless login on sharing the ssh public key to the destination machine

Steps:
### SSH key pair generation
```
// generating the ssh key pair
ssh-keygen

```

### Copy the public key to the destination machine (where we do need to connect)
```
// copy public key from source to destination
ssh-copy-id -i /root/.ssh/<name>.pub <detination-server>
```

### To verify cat on the authorized_keys
```
// can find the public key here (destination server)
cat /root/.ssh/authorized_keys
```
- After this config, password prompt is skipped while doing ssh


### Add the SSH Config entry

- Add the host config to ssh in the servers
```commandline
mkdir -p ~/.ssh
nano ~/.ssh/config

// Add the host entry as such

Host <name>
    HostName <ip>
    User <user name>
    Port 22
    IdentityFile ~/.ssh/id_rsa

// From the next time 
ssh <name>

```




## SCP Secure-Copy
- Secure copy - Copies the files or directory from one server to another server.
- internally uses the ssh

Syntax
```
scp -r <source file/directory>  <destination file/directory>

-r (recursive) -> incase copyig the directory with files or dir in it
```
e.g.

To copy the file from current server to destination
```
scp -r /home/file/ username@10.10.10.10:/home/

copies the files folder from on the current server to the 10.10.10.10's server
```

Reverse is also possible
```
scp -r username@10.10.10.10:/home/file/ /home/

copies the file from destination server to the current server
```

- `-p` flag is used to preserve the ownership of the files

Note : while scp it requires the ssh password (if passwordless authentication bot configured) to copy or transfer the files.


## [rsync](https://www.digitalocean.com/community/tutorials/how-to-use-rsync-to-sync-local-and-remote-directories)
- Helps to keep the files of 2 directories in sync
- Helpful when we are freuently updating the particular file over the remote server (when it is useful between 2 local directory sync)

Syntax
```
rsync -rv -e ssh <source location> <destination location>

-r recursive
-v verbose (display the info of an action)
-e encrypts the data over the 

--delete - since the rsync does not deletes the files while sync (actual not 100% sync) only additional file get added
using this delete flage ensures the 100% sync

--exclude=<expression or filename> - excludes the file to sync
```

e.g.

```
rsync -rv -e ssh /home/file/ username@10.10.10.10:/home/file
```

keeps the file directory in sync between the 2 servers

## Disk Imaging
- To backup the disk partition 

Syntax
```commandline
sudo dd if=/dev/vda of=diskimage.raw bs=1M status=progress

if  - input file 
of  - output file
bs  - block size (default 1 MB)
status=progress  -  to show the info

reverse the if, of to import the backup file into disk 

```

