# DNS and Hostname Configuration for Beginners

A simple guide to understanding and configuring DNS, /etc/hosts, and /etc/resolv.conf

---

## 1. DNS Basics - Simple Explanation

### What is DNS? (Domain Name System)

**DNS is like a phone book for the internet.**

```
What you type:  google.com
                    ↓
            [DNS looks it up]
                    ↓
What computer uses: 142.251.41.14 (IP address)
```

**Without DNS**, you'd have to remember IP addresses:
```
Instead of: google.com
You'd type: 142.251.41.14
```

### How DNS Works (Step by Step)

```
1. You type: ping google.com
                    ↓
2. Computer asks: "What is google.com's IP?"
                    ↓
3. DNS server (8.8.8.8) says: "It's 142.251.41.14"
                    ↓
4. Computer connects to 142.251.41.14
```

---

## 2. Understanding /etc/hosts File

### What is /etc/hosts?

**A local phone book on YOUR computer** (before asking the internet DNS).

Think of it as:
- **Local file** = only on this  machine
- **No internet needed** = works offline
- **Checked first** = before consulting DNS servers
- **Manual entries** = you add them yourself

### Real-World Analogy

```
Your computer's phone book (/etc/hosts):
┌─────────────────────────────────────┐
│ IP Address      Name                │
├─────────────────────────────────────┤
│ 10.0.0.100      web-server          │
│ 10.0.0.101      database            │
│ 127.0.0.1       localhost           │
└─────────────────────────────────────┘

When you type: ping web-server
Your computer checks this file FIRST and finds: 10.0.0.100
```

### View /etc/hosts File

```bash
# Read the file
cat /etc/hosts

# Example output:
127.0.0.1       localhost
127.0.1.1       my-laptop    my-laptop.example.com
10.0.0.100      web-server   web-server.example.com
10.0.0.101      database     database.example.com
```

### Understanding Each Line

```
10.0.0.100      web-server      web-server.example.com
│               │               │
IP Address      Name            Full name (optional)
                (short name)
```

**Example:**
```
10.0.0.100
  ↓
This IP address

web-server
  ↓
When I type "web-server", use this IP

web-server.example.com
  ↓
Also works with this full name
```

### Edit /etc/hosts (Add Your Own Entries)

```bash
# Open the file
sudo nano /etc/hosts

# Add these lines at the end:
10.0.0.100      web-server      web-server.example.com
10.0.0.101      database        database.example.com
10.0.0.102      mail            mail.example.com

# Save: Ctrl+O, Enter, Ctrl+X
```

### Now You Can Use Names Instead of IPs

```bash
# Instead of:
ssh 10.0.0.100

# You can now type:
ssh web-server

# Instead of:
ping 10.0.0.101

# You can type:
ping database
```

### When to Use /etc/hosts

✅ **Use when:**
- Setting up small networks (your office)
- Testing servers before putting in real DNS
- Offline environments (no internet)
- Local development

❌ **Don't use when:**
- Managing 100+ computers (too many entries)
- Need automatic updates (use DNS servers instead)
- Need to work from anywhere

---

## 3. Understanding /etc/resolv.conf File

### What is /etc/resolv.conf?

**Settings that tell your computer which DNS servers to use.**

Like writing down:
```
"If /etc/hosts doesn't have the answer, ask these people:"
- 8.8.8.8 (Google's DNS)
- 1.1.1.1 (Cloudflare's DNS)
```

### View Your Current DNS Settings

```bash
# Show DNS configuration
cat /etc/resolv.conf

# Example output:
nameserver 8.8.8.8
nameserver 1.1.1.1
search example.com
```

### Understanding Each Line

```
nameserver 8.8.8.8
├─ nameserver = "Ask this DNS server"
└─ 8.8.8.8 = Google's public DNS (trusted company)

nameserver 1.1.1.1
└─ Cloudflare's DNS (backup, if first is down)

search example.com
├─ search = "Add this domain automatically"
└─ When you type: ping server
   Really means: ping server.example.com
```

### Example: How /etc/resolv.conf Works

```
You type: ping google.com

Step 1: Check /etc/hosts
  → Not found

Step 2: Check /etc/resolv.conf
  It says: "Use DNS 8.8.8.8"

Step 3: Ask Google DNS
  8.8.8.8 replies: "google.com = 142.251.41.14"

Step 4: Connect
  Your computer connects to 142.251.41.14
```

---

## 4. Order of Name Resolution (Important!)

### Three Steps Your Computer Takes

```
┌─────────────────────────────────────────┐
│ Step 1: Check /etc/hosts file (fastest) │
│ "Is web-server in my local phone book?" │
└──────────────┬──────────────────────────┘
               │
               ↓ (if not found)
┌─────────────────────────────────────────┐
│ Step 2: Ask DNS servers (from           │
│         /etc/resolv.conf)               │
│ "Hey 8.8.8.8, what's google.com?"       │
└──────────────┬──────────────────────────┘
               │
               ↓ (if still not found)
┌─────────────────────────────────────────┐
│ Step 3: Error - "Cannot find it"        │
│ "Unknown host" message                  │
└─────────────────────────────────────────┘
```

### Real Example

**Scenario: You type `ping web-server`**

```
1. Is web-server in /etc/hosts?
   → YES! It says: 10.0.0.100
   → DONE! Use 10.0.0.100
   
2. If it wasn't in /etc/hosts, ask DNS:
   → 8.8.8.8 says: "No idea"
   → Try 1.1.1.1: "No idea either"
   → ERROR: "web-server not found"
```

**This is why /etc/hosts is checked FIRST** - it's fast and you control it!

---

## 5. How to Configure DNS (Modern Way: Netplan)

### ⚠️ Important Note

On modern systems, **don't edit /etc/resolv.conf directly!**

Why? Because systemd-resolved overwrites it automatically.

Instead, use **Netplan** (the right way).

### Configure DNS in Netplan (Beginner Example)

```yaml
# Edit this file:
sudo nano /etc/netplan/01-netcfg.yaml

# Add these lines:
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: no
      addresses:
        - 10.0.0.100/24
      gateway4: 10.0.0.1
      
      nameservers:
        addresses:
          - 8.8.8.8           # Google DNS (Primary)
          - 1.1.1.1           # Cloudflare DNS (Backup)
        search:
          - example.com       # Search domain
```

### What These Lines Mean

```yaml
nameservers:
  │
  ├─ addresses:
  │   ├─ 8.8.8.8         "Use this for DNS"
  │   └─ 1.1.1.1         "Use this if first fails"
  │
  └─ search:
      └─ example.com     "Add .example.com if needed"
```

### Apply the Configuration

```bash
# Test first (safe)
sudo netplan try

# Apply permanently
sudo netplan apply

# Verify DNS setting
resolvectl status
```

---

## 6. Hostname Configuration (Beginner Guide)

### What is a Hostname?

**Your computer's nickname on the network.**

```
Your computer's name = web-server
Instead of calling it: 10.0.0.100

Like in school:
Teacher doesn't say: "Hey student #142"
Teacher says: "Hey John"
```

### Check Your Current Hostname

```bash
# Show hostname
hostname

# Example output:
my-laptop

# Show full name (FQDN)
hostname -f

# Example output:
my-laptop.example.com
```

### Set Your Hostname (Permanently)

```bash
# Set new hostname (choose one):
sudo hostnamectl set-hostname web-server

# Verify it changed
hostname

# Now you can SSH to it (from other computers)
ssh web-server
```

### Hostname + /etc/hosts (How They Work Together)

```
Step 1: Set hostname
  sudo hostnamectl set-hostname web-server

Step 2: Update /etc/hosts
  sudo nano /etc/hosts
  Add this line:
  127.0.1.1    web-server    web-server.example.com

Step 3: Other computers can now find you
  ssh web-server  (works!)
```

---

## 7. Complete Beginner Setup Example

### Scenario: Setting Up a Server

**Goal:** Create a server named "database" that others can find

### Step 1: Set the Hostname

```bash
# Give it a name
sudo hostnamectl set-hostname database

# Verify
hostname
# Output: database
```

### Step 2: Update /etc/hosts

```bash
# Edit the file
sudo nano /etc/hosts

# Add this line:
127.0.1.1    database    database.example.com

# Save: Ctrl+O, Enter, Ctrl+X
```

### Step 3: Configure DNS (on your network)

```bash
# Edit netplan
sudo nano /etc/netplan/01-netcfg.yaml

# Add:
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: no
      addresses:
        - 10.0.0.101/24
      gateway4: 10.0.0.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1

# Save
```

### Step 4: Apply Everything

```bash
# Apply network config
sudo netplan apply

# Test DNS
nslookup example.com

# Verify
hostname
# Output: database
```

### Step 5: Update Other Computers' /etc/hosts

On other computers, add:
```bash
sudo nano /etc/hosts

# Add:
10.0.0.101    database    database.example.com

# Now they can reach your server:
ping database
ssh database
```

---

## 8. Common Beginner Mistakes

### ❌ Mistake 1: Forgetting sudo

```bash
# WRONG - Permission denied
nano /etc/hosts

# RIGHT
sudo nano /etc/hosts
```

### ❌ Mistake 2: Wrong /etc/resolv.conf Format

```bash
# WRONG
8.8.8.8

# RIGHT
nameserver 8.8.8.8
```

### ❌ Mistake 3: Bad /etc/hosts Format

```bash
# WRONG (missing tab or space)
10.0.0.100web-server

# RIGHT (has space/tab)
10.0.0.100    web-server
```

### ❌ Mistake 4: Editing /etc/resolv.conf Directly

```bash
# WRONG - Changes disappear!
sudo nano /etc/resolv.conf

# RIGHT - Use netplan
sudo nano /etc/netplan/01-netcfg.yaml
```

---

## 9. Quick Reference for Beginners

| Task | Command |
|------|---------|
| Show hostname | `hostname` |
| Set hostname | `sudo hostnamectl set-hostname NAME` |
| View /etc/hosts | `cat /etc/hosts` |
| Edit /etc/hosts | `sudo nano /etc/hosts` |
| View DNS servers | `resolvectl status` |
| Test DNS | `nslookup google.com` |
| Check name resolves | `ping google.com` |
| Edit network config | `sudo nano /etc/netplan/01-netcfg.yaml` |
| Apply changes | `sudo netplan apply` |
| Test before applying | `sudo netplan try` |

---

## 10. Simple Troubleshooting

### "I can't reach web-server"

Check in order:

```bash
# 1. Is hostname set?
hostname
# Should show the name

# 2. Is it in /etc/hosts?
cat /etc/hosts | grep web-server
# Should show IP

# 3. Is DNS working?
nslookup web-server
# Should show IP

# 4. Can I reach the IP directly?
ping 10.0.0.100
# Should work if network is fine
```

### "DNS is not working"

```bash
# 1. Check DNS servers are set
resolvectl status

# 2. Test with known server
nslookup 8.8.8.8

# 3. Restart DNS service
sudo systemctl restart systemd-resolved

# 4. Check network service
sudo systemctl status systemd-networkd
```

---

## Key Takeaways for Beginners

1. **Hostname** = Your computer's name (like a nickname)
2. **/etc/hosts** = Local phone book (checked first)
3. **/etc/resolv.conf** = DNS server settings (don't edit directly!)
4. **Name resolution order:** /etc/hosts → DNS servers → Error
5. **Use Netplan** to configure DNS permanently
6. **Always use sudo** to edit system files
7. **Test with ping** or **nslookup** to verify DNS works
8. **Restart services** after changes: `sudo systemctl restart systemd-networkd`

---

This guide covers the essentials. For more complex setups, see the other network configuration guides!
