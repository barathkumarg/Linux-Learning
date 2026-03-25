# Content
- [SSH](#ssh)
- [SSH Process on VM](#ssh-process-in-virtual-machine)
- [SSH Configuration Files](#ssh-configuration-files)
- [Password Authentication Configuration](#password-authentication-configuration)
- [SSH Passwordless Login](#ssh-passwordless-login)
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

## SSH Configuration Files

### Global SSH Configuration - /etc/ssh/ssh_config
The global SSH client configuration file applies to all users connecting from the local machine. This file controls SSH client behavior and default settings.

**Important Parameters:**

| Parameter | Description | Example |
|-----------|-------------|---------|
| `Host` | Pattern to match hostnames | `Host prod-*` |
| `HostName` | Actual hostname/IP of remote server | `HostName 192.168.1.100` |
| `User` | Default username for connection | `User admin` |
| `Port` | SSH port (default: 22) | `Port 2222` |
| `IdentityFile` | Path to private key file | `IdentityFile ~/.ssh/id_rsa` |
| `PasswordAuthentication` | Enable/disable password auth | `PasswordAuthentication no` |
| `PubkeyAuthentication` | Enable/disable key-based auth | `PubkeyAuthentication yes` |
| `StrictHostKeyChecking` | Verify host key authenticity | `StrictHostKeyChecking accept-new` |
| `UserKnownHostsFile` | Location of known_hosts file | `UserKnownHostsFile ~/.ssh/known_hosts` |
| `ConnectTimeout` | Connection timeout in seconds | `ConnectTimeout 10` |
| `ServerAliveInterval` | Keep-alive interval in seconds | `ServerAliveInterval 60` |
| `Compression` | Enable/disable compression | `Compression yes` |
| `ProxyCommand` | Use proxy for connection | `ProxyCommand ssh bastion -W %h:%p` |
| `LocalForward` | Forward local port to remote | `LocalForward 3306 db-server:3306` |
| `RemoteForward` | Forward remote port to local | `RemoteForward 8080 localhost:8080` |

**Example Global Configuration:**
```
# /etc/ssh/ssh_config - Global SSH client configuration

# Match all hosts
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
    Compression yes
    StrictHostKeyChecking accept-new

# Production servers
Host prod-* web-*
    User admin
    Port 22
     passwordAuthentication no
    PubkeyAuthentication yes
    IdentityFile ~/.ssh/prod_key

# Development servers
Host dev-*
    User devuser
    Port 2222
    ConnectTimeout 20
```

### User SSH Configuration - ~/.ssh/config

The user-specific SSH configuration file allows individual users to customize SSH behavior for different hosts without needing to memorize IPs or typing long commands. This is much more convenient for frequent connections.

**Directory Structure:**
```
~/.ssh/
├── config                  # SSH client configuration
├── id_rsa                  # Private key (keep secure - chmod 600)
├── id_rsa.pub              # Public key
├── authorized_keys         # Keys allowed to login to this machine
├── known_hosts             # Fingerprints of servers you've connected to
└── config.d/               # Additional config files (included in main config)
```

**Setting up ~/.ssh folder:**
```bash
# Create .ssh directory with proper permissions
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Create empty config file
touch ~/.ssh/config
chmod 600 ~/.ssh/config
```

**Example ~/.ssh/config with Passwordless Login:**
```
# Production Web Server - Passwordless login with shorthand
Host web-prod
    HostName 192.168.100.50
    User admin
    Port 22
    IdentityFile ~/.ssh/prod_key
    PasswordAuthentication no
    PubkeyAuthentication yes
    StrictHostKeyChecking accept-new

# Database Server - Using shorthand hostname
Host db-primary
    HostName db-primary.company.internal
    User dbadmin
    Port 3306
    IdentityFile ~/.ssh/db_key
    PasswordAuthentication no

# Development Server - Multiple identity files (fallback)
Host dev-box
    HostName 10.0.1.100
    User developer
    IdentityFile ~/.ssh/dev_key
    IdentityFile ~/.ssh/backup_key
    PasswordAuthentication no

# Jump host / Bastion configuration
Host bastion
    HostName bastion.company.com
    User jump_user
    IdentityFile ~/.ssh/bastion_key

# Through bastion to internal server
Host internal-db
    HostName 10.0.2.50
    User dbadmin
    IdentityFile ~/.ssh/db_key
    ProxyCommand ssh bastion -W %h:%p
```

**Usage after configuration:**
```bash
# Instead of: ssh -i ~/.ssh/prod_key admin@192.168.100.50
ssh web-prod

# Instead of: ssh -i ~/.ssh/db_key dbadmin@db-primary.company.internal -p 3306
ssh db-primary

# SCP using aliases
scp file.txt web-prod:/home/admin/
scp db-primary:/backup/data.sql ./
```

---

## Password Authentication Configuration

### Server-side Password Authentication (/etc/ssh/sshd_config)
Password authentication can be enabled or disabled on the server side by modifying `/etc/ssh/sshd_config`:

```bash
# Enable password authentication
PasswordAuthentication yes

# Disable password authentication (force key-based auth)
PasswordAuthentication no

# Permit empty passwords (NOT RECOMMENDED for production)
PermitEmptyPasswords no
```

**After making changes, restart SSH service:**
```bash
sudo systemctl restart sshd
```

**Production Best Practices:**
```
# /etc/ssh/sshd_config
Protocol 2
PasswordAuthentication no          # Disable password auth
PubkeyAuthentication yes           # Enforce key-based auth
PermitRootLogin no                 # Disable root login
X11Forwarding no                   # Disable X11 for security
PermitEmptyPasswords no            # Prevent empty passwords
MaxAuthTries 3                     # Limit failed attempts
ClientAliveInterval 300            # Keep-alive
ClientAliveCountMax 2
```

---

## [SSH Passwordless Login](https://www.techtarget.com/searchsecurity/tutorial/Use-ssh-keygen-to-create-SSH-key-pairs-and-more)
SSH passwordless login uses public-key cryptography to authenticate without requiring password entry each time. The server stores your public key, and you authenticate using your private key.

### Step 1: SSH Key Pair Generation
```bash
# Generate SSH key pair (creates id_rsa and id_rsa.pub)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""

# Generate with custom filename and passphrase
ssh-keygen -t rsa -b 4096 -f ~/.ssh/prod_key -C "produser@prod-server"

# Parameters:
# -t rsa           : Key type (rsa, ed25519, ecdsa)
# -b 4096          : Key size in bits (4096 recommended for RSA)
# -f path          : File location to save key
# -N ""            : No passphrase (use -N "passphrase" for secure key)
# -C "comment"     : Comment/identifier for the key
```

**Key pair generation output:**
```
Generating public/private rsa key pair.
Your identification has been saved in /root/.ssh/id_rsa
Your public key has been saved in /root/.ssh/id_rsa.pub
```

### Step 2: Copy Public Key to Remote Server
```bash
# Recommended method - uses SSH to copy and set permissions correctly
ssh-copy-id -i ~/.ssh/id_rsa.pub admin@192.168.1.100

# Alternative - specific port
ssh-copy-id -i ~/.ssh/prod_key.pub -p 2222 admin@server.com

# Manual method (if ssh-copy-id not available)
cat ~/.ssh/id_rsa.pub | ssh admin@192.168.1.100 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

### Step 3: Verify Public Key on Remote Server
```bash
# On the destination server, verify the key was added
cat ~/.ssh/authorized_keys

# Should contain your public key
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC... admin@laptop
```

### Step 4: Test Passwordless Login
```bash
# Should connect without password prompt
ssh admin@192.168.1.100

# If prompted for passphrase, your private key has a passphrase
```

### Step 5: Configure SSH Client (~/.ssh/config)
For maximum convenience, use SSH config aliases - no need to remember IPs or typing passwords:

```bash
# Create/edit config file
nano ~/.ssh/config

# Add entry:
Host web-server
    HostName 192.168.1.100
    User admin
    IdentityFile ~/.ssh/id_rsa
    PasswordAuthentication no

# From next time, simple login with shorthand:
ssh web-server
```

**Production Example - Multiple Servers:**
```
# ~/.ssh/config - Complete passwordless setup

# Web tier
Host web-prod-1
    HostName 10.1.10.50
    User webadmin
    IdentityFile ~/.ssh/prod_key
    PasswordAuthentication no

Host web-prod-2
    HostName 10.1.10.51
    User webadmin
    IdentityFile ~/.ssh/prod_key
    PasswordAuthentication no

# Database tier
Host db-prod
    HostName 10.2.10.100
    User dbadmin
    IdentityFile ~/.ssh/db_key
    PasswordAuthentication no

# Use like:
ssh web-prod-1   # Instead of: ssh -i ~/.ssh/prod_key webadmin@10.1.10.50
ssh db-prod      # Instead of: ssh -i ~/.ssh/db_key dbadmin@10.2.10.100
```

### Troubleshooting Passwordless Login
```bash
# Enable verbose output to debug connection issues
ssh -v web-server

# Check file permissions (critical for security)
ls -la ~/.ssh/
# Should show:
# drwx------  .ssh
# -rw-------  config
# -rw-------  id_rsa (private key)
# -rw-r--r--  id_rsa.pub (public key)

# On remote server, check authorized_keys permissions
ssh web-server "ls -la ~/.ssh/"
ssh web-server "cat ~/.ssh/authorized_keys"
```

### Security Best Practices
```bash
# 1. Set proper permissions on private key
chmod 600 ~/.ssh/id_rsa

# 2. Set proper permissions on .ssh directory
chmod 700 ~/.ssh

# 3. Use strong key size (4096 or higher for RSA)
ssh-keygen -t rsa -b 4096

# 4. Or use modern ED25519 algorithm (recommended)
ssh-keygen -t ed25519 -C "user@machine"

# 5. Remove old/unused keys
rm ~/.ssh/old_key ~/.ssh/old_key.pub

# 6. Regularly rotate keys (annually or after personnel changes)

# 7. Disable password authentication on server
# In /etc/ssh/sshd_config:
# PasswordAuthentication no
# Then: sudo systemctl restart sshd
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

