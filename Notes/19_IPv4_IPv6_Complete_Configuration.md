# IPv4 and IPv6 Network Configuration - Complete Guide

Complete guide covering both IPv4 and IPv6 network configuration with practical examples and production scenarios.

---

## PART 1: IPv4 NETWORK CONFIGURATION

---

## 1. Understanding IPv4 Address Structure

### What is an IPv4 Address?

An IPv4 address is a **32-bit number** divided into **4 octets** (8-bit sections), written in decimal format separated by dots.

Example: `192.168.1.100`

```
192   .  168   .    1    .   100
 ↓        ↓         ↓        ↓
Octet1  Octet2   Octet3   Octet4
(0-255)(0-255)  (0-255)  (0-255)
```

### Three Key Components: Network, Subnet, and Device

| Component | Example | Purpose |
|-----------|---------|---------|
| **Network Address** | `10.0.0.0` | Identifies the entire network |
| **Device Address** | `10.0.0.40` | Individual host on the network |
| **Broadcast Address** | `10.0.0.255` | Reaches all devices on network |

**Example: Network `10.0.0.0/24`**

```
Network:     10.0.0.0     (gateway identifies the network)
Range:       10.0.0.1 to 10.0.0.254  (usable host addresses)
Broadcast:   10.0.0.255   (reaches all 254 hosts at once)
Device:      10.0.0.40    (individual host in that network)
```

---

## 2. CIDR Notation: Understanding the Prefix (/24, /23, etc.)

### What Does /X Mean?

The `/X` notation indicates **how many bits are used for the network portion**.

- `/24` = First 24 bits = Network, Last 8 bits = Hosts
- `/23` = First 23 bits = Network, Last 9 bits = Hosts
- `/32` = All bits for network (single host)

### Common CIDR Prefixes

| Notation | Subnet Mask | Usable Hosts | Typical Use |
|----------|-------------|--------------|-------------|
| `/24` | 255.255.255.0 | 254 | Small office, single LAN |
| `/25` | 255.255.255.128 | 126 | Half of a /24 network |
| `/23` | 255.255.254.0 | 510 | Two /24 networks combined |
| `/22` | 255.255.252.0 | 1,022 | Small data center |
| `/16` | 255.255.0.0 | 65,534 | Medium enterprise |

### Breaking Down /23 (Two Subnets in One)

**Example: `192.168.0.0/23`**

```
/23 divides like this:
│ First 23 bits (same) │ Last 9 bits (varies) │

First subnet:  192.168.0.0 - 192.168.0.255 (254 hosts)
Second subnet: 192.168.1.0 - 192.168.1.255 (254 hosts)
Together: 510 usable hosts in /23 network
```

---

## 3. Basic IPv4 Configuration Commands

### View Current Network Interfaces

```bash
# Show all interfaces and their IPs
ip addr show

# Brief format (cleaner output)
ip -br addr show

# IPv4 only
ip -4 addr show

# Show specific interface
ip addr show dev enp0s3
```

### Enable/Disable Network Interface

```bash
# Bring interface UP (enable)
sudo ip link set dev enp0s3 up

# Bring interface DOWN (disable)
sudo ip link set dev enp0s3 down

# Check interface status
ip link show dev enp0s3
```

### Assign IP Address (Temporary)

```bash
# Add single IPv4 address
sudo ip addr add 10.0.0.40/24 dev enp0s3

# Add multiple IPs to same interface
sudo ip addr add 10.0.0.41/24 dev enp0s3
sudo ip addr add 10.0.0.42/24 dev enp0s3

# Remove specific IP
sudo ip addr del 10.0.0.40/24 dev enp0s3

# Remove all IPs from interface
sudo ip addr flush dev enp0s3
```

**⚠️ Note:** These changes are **temporary** and disappear after reboot. For permanent config, use Netplan.

---

## 4. Permanent Configuration Using Netplan

### What is Netplan?

Netplan is a network configuration tool that uses **YAML files** for persistence. Configuration survives reboots.

Location: `/etc/netplan/` (usually `01-netcfg.yaml` or similar)

### View Current Netplan Configuration

```bash
# See all netplan settings
sudo netplan get

# See only ethernet settings
sudo netplan get ethernet

# View the YAML config file
sudo cat /etc/netplan/01-netcfg.yaml
```

### Edit Netplan Configuration

```bash
# Edit with nano
sudo nano /etc/netplan/01-netcfg.yaml

# Edit with vi
sudo vi /etc/netplan/01-netcfg.yaml
```

### Example: Basic Static IP Configuration

```yaml
network:
  version: 2
  renderer: networkd           # or 'NetworkManager'
  
  ethernets:
    enp0s3:                    # Interface name
      dhcp4: no                # Disable DHCP
      addresses:
        - 10.0.0.40/24         # Static IP with CIDR prefix
      gateway4: 10.0.0.1       # Default gateway
      nameservers:
        addresses:
          - 8.8.8.8            # Google DNS
          - 1.1.1.1            # Cloudflare DNS
```

### Test Configuration (Safe Method)

```bash
# Test the config - auto-reverts if no confirmation in 120 seconds
sudo netplan try

# Answer "yes" when prompted to accept changes
```

### Apply Configuration Permanently

```bash
# Apply changes permanently
sudo netplan apply

# Verify the configuration was applied
ip addr show dev enp0s3
ip route show
```

---

## 5. IPv4 Production Scenarios

### Scenario 1: Web Server with Static IP

**Requirement:** Web server needs fixed IP that survives reboots

```yaml
network:
  version: 2
  renderer: networkd
  
  ethernets:
    enp0s3:
      dhcp4: no
      addresses:
        - 203.0.113.50/24      # Fixed public IP
      gateway4: 203.0.113.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
```

### Scenario 2: Dual Network Interface (Two NICs)

**Requirement:** Server with 2 NICs - one for production, one for management

```yaml
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: no
      addresses:
        - 10.0.0.100/24
      gateway4: 10.0.0.1
    
    enp0s8:
      dhcp4: no
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
```

### Scenario 3: DHCP with Static Fallback

```yaml
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: yes
      addresses:
        - 10.0.0.100/24
      dhcp4-overrides:
        use-dns: no
      nameservers:
        addresses:
          - 8.8.8.8
```

### Scenario 4: Multiple IPs on Single Interface

```yaml
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: no
      addresses:
        - 10.0.0.100/24
        - 10.0.0.101/24
        - 10.0.0.102/24
      gateway4: 10.0.0.1
```

---

## 6. Quick Reference: IPv4 Commands

| Task | Command |
|------|---------|
| Show all IP addresses | `ip -4 addr show` |
| Add temporary IP | `sudo ip addr add 10.0.0.40/24 dev enp0s3` |
| Remove IP | `sudo ip addr del 10.0.0.40/24 dev enp0s3` |
| Enable interface | `sudo ip link set dev enp0s3 up` |
| Disable interface | `sudo ip link set dev enp0s3 down` |
| View netplan config | `sudo netplan get` |
| Test netplan | `sudo netplan try` |
| Apply netplan | `sudo netplan apply` |

---

---

## PART 2: IPv6 NETWORK CONFIGURATION

---

## 1. Understanding IPv6 Address Structure

### What is IPv6?

IPv6 is the **next-generation** IP protocol using **128-bit addresses** (vs IPv4's 32-bit).

IPv6 uses **8 groups of 4 hexadecimal digits**, separated by colons:

```
2001:0db8:85a3:0000:0000:8a2e:0370:7334
│    │    │    │    │    │    │    │
└────┴────┴────┴────┴────┴────┴────┘
  8 groups of 4 hex digits
```

### Breaking Down IPv6 Components

```
2001:0db8:85a3:0000:0000:8a2e:0370:7334
│                  │                    │
├── Global Routing ┤── Subnet ID ─┬─── Interface ID (Host)
    Prefix (48-64)    (varies)      (64 bits)

Simplified: 2001:db8:85a3::8a2e:370:7334
```

| Component | Example | Purpose |
|-----------|---------|---------|
| **Global Routing Prefix** | `2001:db8:85a3::/48` | Identifies organization (ISP assigns) |
| **Subnet ID** | `:0000:/0000:` | Internal subnetting |
| **Interface ID** | `8a2e:0370:7334` | Identifies device on network |

---

## 2. IPv6 Address Types

### Global Unicast (Publicly Routable)

Used for public internet traffic.

```
Prefix: 2001:db8::/32
Example: 2001:db8::1
Use case: Web servers, production systems accessible from internet
```

### Link-Local (Automatically Assigned)

Used only on local network segment, never routes beyond local link.

```
Prefix: fe80::/10
Format: fe80::1
Use case: Automatic router discovery, local communication
```

### Loopback

Local interface for testing (equivalent to 127.0.0.1 in IPv4).

```
::1
Use case: Testing local services
```

### Unspecified

"No address" (equivalent to 0.0.0.0 in IPv4).

```
::
Use case: Used by kernel internally
```

---

## 3. IPv6 Shorthand Notation

### Rule 1: Drop Leading Zeros

```
2001:0db8:0000:0000:0000:8a2e:0370:7334
    ↓
2001:db8:0:0:0:8a2e:370:7334
```

### Rule 2: Replace Consecutive Zeros with ::

```
2001:db8:0:0:0:8a2e:370:7334
    ↓
2001:db8::8a2e:370:7334

⚠️ Can only use :: ONCE per address!
```

### Examples

| Full Address | Shortened | Explanation |
|--------------|-----------|-------------|
| `2001:0db8:0000:0000:0000:0000:0000:0001` | `2001:db8::1` | Drops zeros, uses :: |
| `fe80:0000:0000:0000:0250:0056:0000:0001` | `fe80::250:56:0:1` | Link-local shortened |
| `0000:0000:0000:0000:0000:0000:0000:0001` | `::1` | Loopback address |

---

## 4. IPv6 CIDR Notation

### Common IPv6 Prefixes

| Prefix | Size | Use Case |
|--------|------|----------|
| `/32` | ISP assignment | Organization gets this from ISP |
| `/48` | Large organization | Still room for subnetting |
| `/64` | Single subnet | Single LAN (most common) |
| `/128` | Single host | Host route |

**Example: `2001:db8:85a3::/64`**

```
/64 means first 64 bits = network, last 64 bits = hosts

Network portion: 2001:db8:85a3:0000
Host portion: 0000:0000:0000:0001 to ffff:ffff:ffff:fffe

This single /64 subnet can have 2^64 devices
```

---

## 5. Basic IPv6 Configuration Commands

### View IPv6 Addresses

```bash
# Show IPv6 only
ip -6 addr show

# Show specific interface
ip -6 addr show dev enp0s3

# Brief format
ip -br addr show

# Show link-local automatically assigned
ip addr show dev enp0s3 | grep fe80
```

### Assign IPv6 Address (Temporary)

```bash
# Add IPv6 address
sudo ip -6 addr add 2001:db8::100/64 dev enp0s3

# Add multiple IPv6 addresses
sudo ip -6 addr add 2001:db8::101/64 dev enp0s3
sudo ip -6 addr add 2001:db8::102/64 dev enp0s3

# Remove IPv6 address
sudo ip -6 addr del 2001:db8::100/64 dev enp0s3
```

### Enable IPv6 on Interface

```bash
# Enable IPv6 (already on by default)
sudo sysctl -w net.ipv6.conf.enp0s3.disable_ipv6=0

# Disable IPv6 (if needed)
sudo sysctl -w net.ipv6.conf.enp0s3.disable_ipv6=1
```

---

## 6. Permanent IPv6 Configuration with Netplan

### Example 1: Static IPv6 Only

```yaml
network:
  version: 2
  renderer: networkd
  
  ethernets:
    enp0s3:
      addresses:
        - 2001:db8::100/64
      gateway6: 2001:db8::1
      nameservers:
        addresses:
          - 2001:4860:4860::8888
```

### Example 2: Dual Stack (IPv4 + IPv6)

```yaml
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: no
      dhcp6: no
      addresses:
        - 10.0.0.100/24          # IPv4
        - 2001:db8::100/64       # IPv6
      gateway4: 10.0.0.1
      gateway6: 2001:db8::1
      nameservers:
        addresses:
          - 8.8.8.8
          - 2001:4860:4860::8888
```

### Example 3: DHCPv6 Auto-Configuration

```yaml
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp6: yes
      accept-ra: yes
```

### Example 4: SLAAC (Stateless Auto-Configuration)

```yaml
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: no
      dhcp6: no
      accept-ra: yes
```

---

## 7. IPv6 Production Scenarios

### Scenario 1: Web Server with Dual Stack

**Requirement:** Web server needs IPv4 and IPv6

```yaml
network:
  version: 2
  ethernets:
    enp0s3:
      addresses:
        - 10.0.0.50/24
        - 2001:db8:85a3::50/64
      gateway4: 10.0.0.1
      gateway6: 2001:db8:85a3::1
      nameservers:
        addresses:
          - 8.8.8.8
          - 2001:4860:4860::8888
```

### Scenario 2: Cloud Instance Auto-Configuration

```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: yes
      dhcp6: yes
      accept-ra: yes
```

### Scenario 3: Enterprise Dual Stack

```yaml
network:
  version: 2
  ethernets:
    enp0s3:
      addresses:
        - 192.168.1.100/24
        - 2001:db8:1::100/64
      gateway4: 192.168.1.1
      gateway6: 2001:db8:1::1
      nameservers:
        addresses:
          - 8.8.8.8
          - 2001:4860:4860::8888
        search:
          - company.internal
          - example.com
```

---

## 8. IPv6 vs IPv4 Comparison

| Aspect | IPv4 | IPv6 |
|--------|------|------|
| **Address Length** | 32 bits | 128 bits |
| **Format** | Dotted decimal (192.168.1.1) | Colon hex (2001:db8::1) |
| **Total Addresses** | 4.3 billion | 340 undecillion |
| **Loopback** | 127.0.0.1 | ::1 |
| **Unspecified** | 0.0.0.0 | :: |
| **Common Subnet** | /24 (254 hosts) | /64 (2^64 hosts) |

---

## 9. Troubleshooting IPv4 & IPv6

```bash
# Check if IPv6 is enabled
cat /proc/sys/net/ipv6/conf/all/disable_ipv6

# View all IPv6 addresses
ip -6 addr show

# View IPv6 routes
ip -6 route show

# Test IPv6 connectivity
ping6 2001:4860:4860::8888

# Check DNS
nslookup google.com
resolvectl status
```

---

## 10. Finding Netplan Examples

```bash
# View available netplan examples
ls /usr/share/doc/netplan/examples/

# View example files
cat /usr/share/doc/netplan/examples/dhcp.yaml
cat /usr/share/doc/netplan/examples/static.yaml
cat /usr/share/doc/netplan/examples/ipv6.yaml
```

---

## 11. Service Management & Verification

### Network Service Commands

```bash
# Check service status
sudo systemctl status systemd-networkd

# Restart service
sudo systemctl restart systemd-networkd

# View real-time logs
journalctl -u systemd-networkd -f
```

### View Listening Ports

```bash
# Show all listening ports
sudo ss -tulpn

# Check specific port
sudo ss -tulpn | grep :80

# Monitor in real-time
watch -n1 'sudo ss -tulpn'
```

---

## Key Takeaways

**IPv4:**
1. IPv4 = 4 octets (192.168.1.100)
2. CIDR /X = network bits (/24 = 256 addresses)
3. Temporary changes = `ip` command (lost on reboot)
4. Permanent changes = Netplan YAML

**IPv6:**
1. IPv6 = 128 bits in 8 groups (2001:db8::1)
2. Address types = Global Unicast, Link-Local, Loopback, Unspecified
3. /64 is standard for single subnet
4. Dual Stack = IPv4 + IPv6 on same interface (production standard)

**Configuration:**
1. Always test first with `sudo netplan try`
2. Apply with `sudo netplan apply`
3. Use official examples: `/usr/share/doc/netplan/examples/`
4. Verify with `ip addr show` and `ss -tulpn`
