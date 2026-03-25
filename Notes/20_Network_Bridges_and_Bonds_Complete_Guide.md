# Network Bridges and Bonds - Concise Guide

Quick reference guide for configuring network bridges and bonds in Linux.

---

# TABLE OF CONTENTS

1. [Network Bridges](#network-bridges)
2. [Network Bonds](#network-bonds)
3. [Bonding Modes 0-6](#bonding-modes-0-6)
4. [Netplan Configuration](#netplan-configuration)
5. [Configuration Examples](#configuration-examples)
6. [Verification & Troubleshooting](#verification--troubleshooting)

---

---

# NETWORK BRIDGES

## What is a Bridge?

A bridge connects multiple network interfaces as a single logical interface, making them appear on the same network segment.

```
eth0 ─┐
      ├─→ br0 (Bridge) → VMs appear on same network as host
eth1 ─┘
```

## When to Use

✅ VM hosts (KVM, Proxmox) - VMs get direct network access  
✅ Container networking (Docker, LXC)  
✅ Network segmentation  
✅ Transparent network forwarding

## Bridge Architecture

```
Physical Network ─── eth0 ───┐
                              ├─→ Bridge (br0) ─→ IP: 192.168.1.100
VM Network ─── vnet0 ────────┘

Packets examined by MAC address
Forwarded to appropriate interface
```

---

---

# NETWORK BONDS

## What is Bonding?

Combines multiple NICs into one logical interface for:
- **Redundancy** - If one NIC fails, others take over
- **Bandwidth** - Multiple NICs working together
- **Load balancing** - Traffic spread across NICs

```
eth0 (1Gbps) ┐
eth1 (1Gbps) ├─→ bond0 (1-3Gbps + failover)
eth2 (1Gbps) ┘
```

## Why Bonding?

| Problem | Solution |
|---------|----------|
| Single NIC failure = offline | Bond provides automatic failover |
| Limited to 1NIC speed | Bond combines all NICs |
| Manual failover needed | Automatic detection & switch |

---

---

# BONDING MODES 0-6

## Mode 0: balance-rr (Round-Robin)

**What:** Distributes packets sequentially across NICs  
**Load Balancing:** ✅ Both transmit and receive  
**Failover:** ✅ Yes  
**Switch Config:** Required (etherchannel)  
**Use Case:** Rare, requires switch support

```bash
mode: balance-rr
# P1→eth0, P2→eth1, P3→eth2, P4→eth0, ...
```

---

## Mode 1: active-backup (Active-Backup) ⭐ COMMON

**What:** Only one NIC active at a time, others standby  
**Load Balancing:** ❌ No  
**Failover:** ✅ Excellent (automatic)  
**Switch Config:** Not required  
**Use Case:** High availability, simple failover

```bash
mode: active-backup
primary: eth0
# eth0 active, eth1 waiting
# If eth0 fails → eth1 takes over instantly
```

**Real World:**
```
Bank ATM server needs 99.99% uptime
eth0 → Main network
eth1 → Backup network
If main fails → Automatically switches to backup
```

---

## Mode 2: balance-xor (XOR)

**What:** Uses XOR logic to distribute packets  
**Load Balancing:** ✅ Transmit only  
**Failover:** ✅ Yes  
**Switch Config:** Required  
**Use Case:** Balanced networks needing switch support

```bash
mode: balance-xor
# Same sender-receiver pair → same NIC
# Different pairs distributed across NICs
```

---

## Mode 3: broadcast (Broadcast)

**What:** Sends same packet on all NICs  
**Load Balancing:** ❌ No  
**Failover:** ❌ All send regardless  
**Switch Config:** Required  
**Use Case:** Testing, medical equipment needing 100% delivery

```bash
mode: broadcast
# Every packet sent 3 times (one per NIC)
# Guarantees delivery but wastes bandwidth
```

---

## Mode 4: 802.3ad (LACP) ⭐⭐⭐ RECOMMENDED

**What:** Standard link aggregation, negotiates with switch  
**Load Balancing:** ✅ Both transmit and receive  
**Failover:** ✅ Excellent  
**Switch Config:** Automatic negotiation  
**Use Case:** Modern networks, best performance

```bash
mode: 802.3ad
lacp-rate: fast
# All NICs active simultaneously
# Switch auto-configures aggregation
# Best for 99% of cases
```

**Real World:**
```
Data center server with 3x 1Gbps NICs
Total: 3Gbps throughput
If 1 fails: 2Gbps available
All NICs automatically negotiated by switch
No configuration on switch needed
```

---

## Mode 5: balance-tlb (Transmit Load Balancing)

**What:** Load balances transmit, ARP for receive failover  
**Load Balancing:** ✅ Transmit only  
**Failover:** ✅ Yes (via ARP)  
**Switch Config:** Not required  
**Use Case:** Old switches, no aggregation support

```bash
mode: balance-tlb
# Outgoing: Distributed
# Incoming: All via one NIC
```

---

## Mode 6: balance-alb (Adaptive Load Balancing)

**What:** Load balances both directions using ARP manipulation  
**Load Balancing:** ✅ Both transmit and receive  
**Failover:** ✅ Yes  
**Switch Config:** Not required  
**Use Case:** Asymmetric traffic, ARP-based adaptation

```bash
mode: balance-alb
# Both transmit and receive distributed
# Adapts to traffic patterns
# Works without switch configuration
```

---

## Mode Comparison

| Mode | Name | Both TX/RX | No Config | Best For |
|------|------|---|---|---|
| 0 | Round-Robin | ✅ | ❌ | Rare |
| 1 | Active-Backup | ❌ | ✅ | **HA** |
| 2 | Balance-XOR | ❌ | ❌ | Balanced |
| 3 | Broadcast | ❌ | ❌ | Testing |
| **4** | **802.3ad** | **✅** | **✅** | **BEST** |
| 5 | Balance-TLB | ❌ | ✅ | Old switch |
| 6 | Balance-ALB | ✅ | ✅ | Asymmetric |

---

---

# NETPLAN CONFIGURATION

## File Location

```bash
/etc/netplan/01-netcfg.yaml
```

## Basic Bond Configuration

```yaml
network:
  version: 2
  renderer: networkd
  
  ethernets:
    eth0:
      dhcp4: no
    eth1:
      dhcp4: no
  
  bonds:
    bond0:
      interfaces: [eth0, eth1]
      parameters:
        mode: 802.3ad
        mii-monitor-interval: 100
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
```

## Basic Bridge Configuration

```yaml
network:
  version: 2
  renderer: networkd
  
  ethernets:
    eth0:
      dhcp4: no
  
  bridges:
    br0:
      interfaces: [eth0]
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
```

## Parameters Reference

### Bond Parameters

```yaml
bonds:
  bond0:
    interfaces: [eth0, eth1]      # NICs to bond
    parameters:
      mode: 802.3ad               # Bonding mode (0-6 or name)
      mii-monitor-interval: 100   # Monitor period (ms)
      primary: eth0               # Preferred (active-backup only)
      lacp-rate: fast             # Fast (1s) or slow (30s)
    addresses:
      - 192.168.1.100/24
    gateway4: 192.168.1.1
```

### Bridge Parameters

```yaml
bridges:
  br0:
    interfaces: [eth0, eth1]
    parameters:
      stp: false                  # Spanning Tree Protocol
    addresses:
      - 192.168.1.100/24
```

---

---

# CONFIGURATION EXAMPLES

## Example 1: Active-Backup Bond (Simple HA)

```yaml
network:
  version: 2
  renderer: networkd
  
  ethernets:
    eth0: { dhcp4: no }
    eth1: { dhcp4: no }
  
  bonds:
    bond0:
      interfaces: [eth0, eth1]
      parameters:
        mode: active-backup
        primary: eth0
        mii-monitor-interval: 100
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]
```

**Result:**
- eth0 is active, eth1 is standby
- If eth0 fails → eth1 automatically takes over
- Perfect for: HA servers, mission-critical systems

---

## Example 2: 802.3ad Bond (Load Balanced)

```yaml
network:
  version: 2
  renderer: networkd
  
  ethernets:
    eth0: { dhcp4: no }
    eth1: { dhcp4: no }
    eth2: { dhcp4: no }
  
  bonds:
    bond0:
      interfaces: [eth0, eth1, eth2]
      parameters:
        mode: 802.3ad
        lacp-rate: fast
      addresses:
        - 10.0.0.100/24
      gateway4: 10.0.0.1
```

**Result:**
- All 3 NICs active simultaneously
- 3Gbps total bandwidth
- Automatic failover if one fails
- Perfect for: High-performance servers, data centers

---

## Example 3: Bridge with Bond (VM Host)

```yaml
network:
  version: 2
  renderer: networkd
  
  ethernets:
    eth0: { dhcp4: no }
    eth1: { dhcp4: no }
  
  bonds:
    bond0:
      interfaces: [eth0, eth1]
      parameters:
        mode: 802.3ad
  
  bridges:
    br0:
      interfaces: [bond0]
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
```

**Result:**
- VMs connect to br0
- All VMs on same network as host
- Redundancy via bonded NICs
- Perfect for: Hypervisors (KVM, Proxmox)

---

## Example 4: Multiple Bonds (Production Database)

```yaml
network:
  version: 2
  renderer: networkd
  
  ethernets:
    eth0: { dhcp4: no }
    eth1: { dhcp4: no }
    eth2: { dhcp4: no }
    eth3: { dhcp4: no }
  
  bonds:
    # Production bond
    bond-prod:
      interfaces: [eth0, eth1]
      parameters:
        mode: active-backup
        primary: eth0
      addresses:
        - 10.0.0.100/24
      gateway4: 10.0.0.1
    
    # Management bond
    bond-mgmt:
      interfaces: [eth2, eth3]
      parameters:
        mode: active-backup
        primary: eth2
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
```

**Result:**
- Production traffic: eth0-eth1 (with failover)
- Management traffic: eth2-eth3 (separate, with failover)
- Can manage server even if production network down

---

# CONFIGURATION STEPS

## 1. Create/Edit Netplan File

```bash
# Backup existing
sudo cp /etc/netplan/01-netcfg.yaml /etc/netplan/01-netcfg.yaml.backup

# Edit
sudo nano /etc/netplan/01-netcfg.yaml
```

## 2. Validate YAML

```bash
sudo netplan validate
```

## 3. Test Configuration

```bash
# Test without applying (safest)
sudo netplan try
```

## 4. Apply Configuration

```bash
sudo netplan apply

# Verify
ip addr show
cat /proc/net/bonding/bond0
brctl show
```

---

---

# VERIFICATION & TROUBLESHOOTING

## Verify Bond Status

```bash
# Show bond info
cat /proc/net/bonding/bond0

# Example output:
# Bonding Mode: 802.3ad
# MII Status: up
# Slave Interface: eth0
#   MII Status: up
# Slave Interface: eth1
#   MII Status: up
```

## Verify Bridge Status

```bash
# Show bridges
brctl show

# Show bridge details
ip addr show br0

# Show MAC table
brctl showmacs br0
```

## Test Failover

```bash
# Check current active
cat /proc/net/bonding/bond0 | grep "Currently Active"

# Simulate failure
sudo ip link set eth0 down

# Check - should switch to eth1
cat /proc/net/bonding/bond0

# Bring back
sudo ip link set eth0 up
```

## Complete Diagnostic

```bash
# All network info at once
echo "=== Bonds ===" && cat /proc/net/bonding/bond0 && \
echo -e "\n=== Bridges ===" && brctl show && \
echo -e "\n=== IP Config ===" && ip addr show && \
echo -e "\n=== Routes ===" && ip route show
```

## Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Bond not created | Netplan not applied | `sudo netplan apply` |
| No IP on bond | Missing addresses in config | Add `addresses:` section |
| Can't ping | Interface down | Check `ip link show` |
| Slow failover | Interval too high | Lower `mii-monitor-interval` |

---

---

# QUICK REFERENCE

## Commands

```bash
# View bond status
cat /proc/net/bonding/bond0

# View bridges
brctl show

# Show all network interfaces
ip link show

# Show addresses
ip addr show

# Test connectivity
ping 192.168.1.1

# Safe test before applying
sudo netplan try

# Apply changes
sudo netplan apply

# Validate YAML
sudo netplan validate

# Check systemd-networkd
sudo systemctl status systemd-networkd
```

## Decision Matrix

```
Need failover only?
  → Mode 1 (Active-Backup)

Need maximum throughput?
  → Mode 4 (802.3ad) ⭐ BEST

Need old switch support?
  → Mode 5 (balance-tlb) or Mode 6 (balance-alb)

Need VM host?
  → Bond0 (any mode) → Bridge br0 → VMs

ALWAYS CHOOSE MODE 4 IF UNSURE
```

## Modes at a Glance

- **Mode 0**: Round-robin (rare)
- **Mode 1**: Active-backup (HA, simple) ✓
- **Mode 2**: XOR (load balance + switch)
- **Mode 3**: Broadcast (testing only)
- **Mode 4**: 802.3ad (load balance, auto-negotiation) ⭐⭐⭐
- **Mode 5**: Balance-TLB (no switch config)
- **Mode 6**: Balance-ALB (adaptive, no switch config)

---

## Checklist: Before Production

- [ ] Netplan syntax validated (`sudo netplan validate`)
- [ ] Configuration tested with `sudo netplan try`
- [ ] Bond/bridge status verified (`cat /proc/net/bonding/bond0`)
- [ ] Failover tested (bring down active NIC, verify failover)
- [ ] Connectivity tests pass (ping gateway, DNS)
- [ ] Original config backed up
- [ ] Failover behavior documented
- [ ] Team trained on recovery procedures

---

## Key Takeaways

**Bridges:**
- Connect network segments transparently
- Essential for VM hosts (KVM, Proxmox, Docker)
- No performance penalty
- Good for network isolation

**Bonds:**
- Combine NICs for redundancy and/or performance
- Automatic failover (no manual action, <1 second)
- Mode 4 (802.3ad) handles 99% of cases
- Modern switches auto-negotiate

**Modes Summary:**
- **High Availability:** Mode 1 (active-backup)
- **Maximum Performance:** Mode 4 (802.3ad) ⭐
- **Old Infrastructure:** Mode 5 or 6
- **Testing:** Mode 3 (broadcast)

**Best Practices:**
1. Always use Netplan (`/etc/netplan/01-netcfg.yaml`)
2. Always test with `sudo netplan try` before applying
3. Always backup original config
4. Always verify after applying
5. Mode 4 (802.3ad) is recommended for modern networks
