# Complete Network Configuration Cheat Sheet

Quick reference guide for IPv4, IPv6, routing, DNS, and hostname configuration.

---

## IP Configuration at a Glance

### IPv4: 4 Octets, Decimal Format
```
192.168.1.100/24
│  │    │  │  │
└──┴────┴──┴──┴─ 4 octets (0-255 each) + /24 CIDR prefix
```

### IPv6: 8 Groups, Hex Format
```
2001:db8::100/64
8 groups of 4 hex digits + /64 CIDR prefix
```

---

## 1. Temporary IP Configuration Commands

### View Interfaces
```bash
ip addr show              # Show all IPs
ip -4 addr show          # IPv4 only
ip -6 addr show          # IPv6 only
ip addr show dev eth0    # Specific interface
ip -br addr show         # Brief format
```

### Add/Remove IPs (Temporary - Lost on Reboot)
```bash
# Add IPv4
sudo ip addr add 10.0.0.40/24 dev eth0

# Add IPv6
sudo ip -6 addr add 2001:db8::100/64 dev eth0

# Add multiple
sudo ip addr add 10.0.0.41/24 dev eth0
sudo ip addr add 10.0.0.42/24 dev eth0

# Remove
sudo ip addr del 10.0.0.40/24 dev eth0

# Remove all
sudo ip addr flush dev eth0
```

### Enable/Disable Interface
```bash
sudo ip link set dev eth0 up      # Enable
sudo ip link set dev eth0 down    # Disable
ip link show dev eth0             # Check status
```

---

## 2. Permanent Configuration with Netplan

### Check Current Config
```bash
sudo netplan get              # View all settings
sudo netplan get ethernet     # View ethernet settings
cat /etc/netplan/01-netcfg.yaml
```

### Edit Configuration
```bash
sudo nano /etc/netplan/01-netcfg.yaml
```

### Test & Apply
```bash
sudo netplan try              # Test (auto-reverts in 120s)
sudo netplan apply            # Apply permanently
```

### Basic Static IPv4
```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: no
      addresses:
        - 10.0.0.100/24
      gateway4: 10.0.0.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1
```

### Static IPv6
```yaml
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - 2001:db8::100/64
      gateway6: 2001:db8::1
```

### Dual Stack (IPv4 + IPv6)
```yaml
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - 10.0.0.100/24
        - 2001:db8::100/64
      gateway4: 10.0.0.1
      gateway6: 2001:db8::1
      nameservers:
        addresses:
          - 8.8.8.8
          - 2001:4860:4860::8888
```

### DHCP with Static Fallback
```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: yes
      addresses:
        - 10.0.0.100/24
      dhcp4-overrides:
        use-dns: no
      nameservers:
        addresses:
          - 8.8.8.8
```

---

## 3. CIDR Notation Reference

| /X | Subnet Mask | Hosts | Typical Use |
|----|------------|-------|------------|
| /32 | 255.255.255.255 | 1 | Single host |
| /31 | 255.255.255.254 | 2 | Point-to-point |
| /24 | 255.255.255.0 | 254 | Small LAN |
| /23 | 255.255.254.0 | 510 | Medium network |
| /22 | 255.255.252.0 | 1022 | Larger network |
| /16 | 255.255.0.0 | 65,534 | Enterprise |

```
/24 means: First 24 bits = network, Last 8 bits = hosts
/23 means: First 23 bits = network, Last 9 bits = hosts (2x /24)
/8  means: First 8 bits = network, Last 24 bits = hosts
```

---

## 4. Routing Configuration

### View Routes
```bash
ip route show              # Show IPv4 routes
ip -6 route show          # Show IPv6 routes
ip route show table all   # All routing tables
```

### Add/Delete Routes (Temporary)
```bash
# Add route
sudo ip route add 10.0.0.0/24 via 192.168.1.1 dev eth0

# Add default gateway
sudo ip route add default via 192.168.1.1

# Delete route
sudo ip route del 10.0.0.0/24

# Delete default gateway
sudo ip route del default
```

### Permanent Routes (Netplan)
```yaml
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      
      routes:
        # Default route
        - to: 0.0.0.0/0
          via: 192.168.1.1
          metric: 100
        
        # Specific subnet
        - to: 10.0.0.0/24
          via: 192.168.1.254
          metric: 50
        
        # Specific host
        - to: 172.16.0.50/32
          via: 192.168.1.253
```

### Dual Gateway (Failover)
```yaml
routes:
  - to: 0.0.0.0/0
    via: 192.168.1.1
    metric: 100          # Primary (lower = preferred)
  - to: 0.0.0.0/0
    via: 192.168.1.2
    metric: 200          # Secondary (higher = fallback)
```

---

## 5. DNS Configuration

### Check Current DNS
```bash
resolvectl status         # See DNS servers being used
resolvectl dns           # List DNS servers only
resolvectl status eth0   # DNS for specific interface
cat /etc/resolv.conf     # Legacy way
```

### Test DNS
```bash
nslookup google.com
dig google.com
nslookup google.com 8.8.8.8    # Query specific server
resolvectl query google.com
```

### Configure DNS (Netplan)
```yaml
network:
  ethernets:
    eth0:
      addresses:
        - 10.0.0.100/24
      gateway4: 10.0.0.1
      nameservers:
        addresses:
          - 8.8.8.8           # Primary DNS
          - 1.1.1.1           # Secondary DNS
        search:
          - example.com       # Domain suffix
          - internal.local    # Another suffix
```

### Corporate DNS with Fallback
```yaml
nameservers:
  addresses:
    - 10.0.0.10         # Corporate DNS
    - 10.0.0.11         # Corporate backup
    - 8.8.8.8           # Internet fallback
  search:
    - company.internal
    - example.com
```

---

## 6. Hostname Configuration

### View Hostname
```bash
hostname               # Just the hostname
hostname -f           # Fully qualified domain name
hostnamectl status    # Full hostname info
```

### Set Hostname (Permanent)
```bash
sudo hostnamectl set-hostname web-server-01
sudo hostnamectl set-hostname web-server-01 --pretty "Production Web Server"
```

### Edit /etc/hosts (Local Resolution)
```bash
sudo nano /etc/hosts

# Format: IP    Hostname    FQDN
127.0.0.1       localhost
127.0.1.1       web-server-01    web-server-01.example.com
10.0.0.100      web-server-01    web-server-01.example.com
10.0.0.101      database-01      database-01.example.com
::1             localhost        ip6-localhost
```

### Name Resolution Priority
```
1. /etc/hosts file     (checked first)
2. DNS servers         (checked second)
3. Not found error     (if both fail)
```

---

## 7. Complete Production Example

### Fully Configured Server

**1. Set Hostname:**
```bash
sudo hostnamectl set-hostname db-prod-01 --pretty "Production Database"
```

**2. Edit /etc/hosts:**
```bash
sudo nano /etc/hosts
# Add:
127.0.1.1       db-prod-01      db-prod-01.example.com
10.0.0.100      web-prod-01     web-prod-01.example.com
10.0.0.101      db-prod-01      db-prod-01.example.com
```

**3. Configure Network (Netplan):**
```yaml
network:
  version: 2
  renderer: networkd
  
  ethernets:
    eth0:
      dhcp4: no
      dhcp6: no
      addresses:
        - 10.0.0.101/24
        - 2001:db8::101/64
      gateway4: 10.0.0.1
      gateway6: 2001:db8::1
      
      routes:
        - to: 0.0.0.0/0
          via: 10.0.0.1
          metric: 100
        - to: 172.16.0.0/16
          via: 10.0.0.254
          metric: 200
      
      nameservers:
        addresses:
          - 10.0.0.10
          - 8.8.8.8
          - 2001:4860:4860::8888
        search:
          - example.com
          - internal.local
```

**4. Apply Everything:**
```bash
sudo netplan apply
sudo reboot
```

**5. Verify:**
```bash
hostnamectl status
ip addr show
ip route show
resolvectl status
ping 10.0.0.100  # Test connectivity
nslookup example.com
```

---

## 8. Network Troubleshooting Commands

```bash
# Check interface status
ip link show
ip addr show

# Check routes
ip route show
ip -6 route show

# Test connectivity
ping 8.8.8.8                    # Internet
ping 10.0.0.1                   # Gateway
ping web-server                 # Hostname

# Check DNS
resolvectl status
nslookup google.com
dig google.com +short

# Interface statistics
ethtool -S eth0

# Network stack errors
dmesg | grep network

# Monitor traffic
watch -n1 'ip -s link show eth0'
```

---

## 9. Common Mistakes to Avoid

❌ **WRONG:**
```bash
# Using temporary commands only (lost on reboot)
sudo ip addr add 10.0.0.100/24 dev eth0
```

✅ **RIGHT:**
```bash
# Edit netplan file for permanent config
sudo nano /etc/netplan/01-netcfg.yaml
sudo netplan apply
```

❌ **WRONG:**
```bash
# Forgetting to test first
sudo netplan apply
```

✅ **RIGHT:**
```bash
# Always test before applying
sudo netplan try
# Confirm if working
sudo netplan apply
```

❌ **WRONG:**
```yaml
# Using DHCP and static addresses together
dhcp4: yes
addresses:
  - 10.0.0.100/24
```

✅ **RIGHT:**
```yaml
# Choose one approach
dhcp4: no
addresses:
  - 10.0.0.100/24
```

---

## 10. Quick Command Reference

| Task | Command |
|------|---------|
| **Show IPs** | `ip addr show` |
| **Add IP** | `sudo ip addr add 10.0.0.100/24 dev eth0` |
| **Remove IP** | `sudo ip addr del 10.0.0.100/24 dev eth0` |
| **Enable interface** | `sudo ip link set dev eth0 up` |
| **Disable interface** | `sudo ip link set dev eth0 down` |
| **View netplan** | `sudo netplan get` |
| **Edit netplan** | `sudo nano /etc/netplan/01-netcfg.yaml` |
| **Test netplan** | `sudo netplan try` |
| **Apply netplan** | `sudo netplan apply` |
| **View routes** | `ip route show` |
| **Add route** | `sudo ip route add 10.0.0.0/24 via 192.168.1.1` |
| **Delete route** | `sudo ip route del 10.0.0.0/24` |
| **Check DNS** | `resolvectl status` |
| **Test DNS** | `nslookup google.com` |
| **Set hostname** | `sudo hostnamectl set-hostname new-name` |
| **View hostname** | `hostname` |
| **Edit hosts file** | `sudo nano /etc/hosts` |
| **Restart network** | `sudo systemctl restart systemd-networkd` |

---

## 11. Essential Concepts Summary

### IPv4 Address Structure
```
192.168.1.100/24
└─ 4 octets + CIDR prefix
└─ /24 = 256 addresses (254 usable)
└─ /23 = 512 addresses (510 usable)
```

### IPv6 Address Structure
```
2001:db8::100/64
└─ 8 groups of hex + CIDR prefix
└─ /64 = standard subnet for single LAN
└─ Can be shortened with ::
```

### Three Network Roles
```
Network:   10.0.0.0    (identifies the network)
Device:    10.0.0.100  (individual host)
Broadcast: 10.0.0.255  (reaches all devices)
```

### Configuration Priority
```
1. Temporary (ip commands) → Lost on reboot
2. Permanent (Netplan) → Survives reboot ✓
```

### Name Resolution
```
/etc/hosts → DNS servers → Failure
```

---

## 12. Netplan Examples & Documentation

### Official Examples Location

```bash
# Browse built-in netplan examples
ls /usr/share/doc/netplan/examples/

# View example configurations
cat /usr/share/doc/netplan/examples/dhcp.yaml
cat /usr/share/doc/netplan/examples/static.yaml
cat /usr/share/doc/netplan/examples/ipv6.yaml
cat /usr/share/doc/netplan/examples/bonds.yaml
cat /usr/share/doc/netplan/examples/bridges.yaml
cat /usr/share/doc/netplan/examples/wifi.yaml
```

**Use these as templates for your own configurations!**

---

## 13. Service Management

### Network Service Commands

```bash
# Check service status
sudo systemctl status systemd-networkd

# Start service
sudo systemctl start systemd-networkd

# Stop service
sudo systemctl stop systemd-networkd

# Restart service (apply changes)
sudo systemctl restart systemd-networkd

# Enable on boot
sudo systemctl enable systemd-networkd

# Disable on boot
sudo systemctl disable systemd-networkd
```

### Service Logs

```bash
# View latest logs
journalctl -u systemd-networkd

# Follow logs in real-time
journalctl -u systemd-networkd -f

# Last 50 lines
journalctl -u systemd-networkd -n 50

# Errors only
journalctl -u systemd-networkd --priority=err
```

---

## 14. Network Socket Inspection (ss Command)

### Basic ss Usage

```bash
# Show ALL listening TCP and UDP ports with process info
sudo ss -tulpn

# Show TCP listening only
sudo ss -tln

# Show UDP listening only
sudo ss -uln

# Show all established connections
sudo ss -tan

# Show IPv6 sockets
sudo ss -6tulpn
```

### Understanding ss Output

```
sudo ss -tulpn

Netid  State   Recv-Q  Send-Q  Local Address:Port  Peer Address:Port  Process
tcp    LISTEN  0       128     0.0.0.0:22         0.0.0.0:*          (sshd,pid=1234)
tcp    LISTEN  0       128     127.0.0.1:5432     0.0.0.0:*          (postgres,pid=5678)
udp    UNCONN  0       0       0.0.0.0:53         0.0.0.0:*          (systemd-resolved,pid=999)

LISTEN = Waiting for connections
UNCONN = Not connected (UDP)
Recv-Q = Pending receives
Send-Q = Pending sends
```

### Common ss Filters & Examples

| Task | Command |
|------|---------|
| All listening ports | `sudo ss -tulpn` |
| TCP only | `sudo ss -tln` |
| UDP only | `sudo ss -uln` |
| SSH connections (port 22) | `sudo ss -tulpn \| grep :22` |
| HTTP/HTTPS (port 80/443) | `sudo ss -tulpn \| grep -E ':(80\|443)'` |
| Database connections (5432) | `sudo ss -tulpn \| grep :5432` |
| DNS queries (port 53) | `sudo ss -tulpn \| grep :53` |
| Established connections | `sudo ss -tan \| head -20` |
| TIME_WAIT connections | `sudo ss -tan \| grep TIME_WAIT` |
| Connection count | `sudo ss -tan \| wc -l` |
| Real-time monitoring | `watch -n1 'sudo ss -tulpn'` |

### Practical Service Verification

```bash
# Is web server accessible?
sudo ss -tulpn | grep :80

# Is SSH running?
sudo ss -tulpn | grep :22

# Is database listening?
sudo ss -tulpn | grep :5432

# How many active connections?
sudo ss -tan | tail -n +2 | wc -l

# Monitor in real-time
watch -n 1 'sudo ss -tan | head -20'
```

---

## 15. Complete Verification Script

```bash
#!/bin/bash
# Complete network verification

echo "========== HOSTNAME ==========="
hostname -f

echo ""
echo "========== IP ADDRESSES ==========="
echo "IPv4:" && ip -4 addr show | grep -oP 'inet \K[^/]+'
echo "IPv6:" && ip -6 addr show | grep -oP 'inet6 \K[^/]+' | grep -v fe80

echo ""
echo "========== ROUTES ==========="
ip route show | grep -E 'default|^[0-9]'

echo ""
echo "========== DNS ==========="
resolvectl dns

echo ""
echo "========== LISTENING PORTS ==========="
sudo ss -tulpn | grep LISTEN

echo ""
echo "========== SERVICE STATUS ==========="
sudo systemctl status systemd-networkd --no-pager | grep Active

echo ""
echo "========== CONNECTIVITY TESTS ==========="
ping -c 1 8.8.8.8 > /dev/null && echo "✓ Internet" || echo "✗ Internet Down"
nslookup google.com > /dev/null 2>&1 && echo "✓ DNS" || echo "✗ DNS Failed"
```

---

## 16. Configuration Checklist

Before deploying a server:

- [ ] Set hostname: `sudo hostnamectl set-hostname NAME`
- [ ] Update /etc/hosts with all servers
- [ ] Configure all IPs (IPv4 + IPv6) in Netplan
- [ ] Add default gateway
- [ ] Add specific routes (if needed)
- [ ] Configure DNS servers
- [ ] Test with `sudo netplan try`
- [ ] Apply with `sudo netplan apply`
- [ ] Check with `sudo ss -tulpn` (all ports listening)
- [ ] Verify: `ip addr show`, `ip route show`, `resolvectl status`
- [ ] Check service: `sudo systemctl status systemd-networkd`
- [ ] Reboot and verify again

---

This cheat sheet covers all essential Linux network configuration tasks. Bookmark this page for quick reference!
