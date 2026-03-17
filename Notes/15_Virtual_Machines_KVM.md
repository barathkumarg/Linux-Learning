# Virtual Machines (KVM/QEMU)

## Overview

Linux uses the **QEMU-KVM combination** for virtualization:
- **KVM (Kernel Virtual Machine)**: Hypervisor module in the Linux kernel
- **QEMU**: Machine emulator and virtualizer
- **VIRSH**: Command-line interface for managing virtual machines

## Installation

```bash
sudo apt-get install virt-manager libvirt-daemon-system libvirt-clients qemu-system-x86
```

## Basic VIRSH Commands

### List and Information

```bash
# List all VMs (running and stopped)
virsh list --all

# View detailed VM information
virsh dominfo <vm-name>

# View VM configuration
virsh dumpxml <vm-name>
```

### VM Lifecycle Management

```bash
# Start/Stop/Restart VM
virsh start <vm-name>
virsh shutdown <vm-name>        # Graceful shutdown
virsh destroy <vm-name>         # Force stop
virsh reboot <vm-name>          # Restart
virsh reset <vm-name>           # Hard reset

# Remove VM and storage
virsh undefine --remove-all-storage <vm-name>
```

## VM Creation from XML

Create a domain XML file (`domain.xml`):

```xml
<domain type='kvm'>
  <name>my-vm</name>
  <memory unit='MiB'>2048</memory>
  <currentMemory unit='MiB'>2048</currentMemory>
  <vcpu>2</vcpu>
  <os>
    <type arch='x86_64'>hvm</type>
  </os>
  <devices>
    <emulator>/usr/bin/qemu-system-x86_64</emulator>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='/var/lib/libvirt/images/disk.qcow2'/>
      <target dev='vda' bus='virtio'/>
    </disk>
    <interface type='network'>
      <source network='default'/>
      <model type='virtio'/>
    </interface>
    <console type='pty'>
      <target type='serial' port='0'/>
    </console>
  </devices>
</domain>
```

Define and start:

```bash
virsh define domain.xml
virsh start <vm-name>
```

---

## Scenario 1: Updating VM Resources (RAM & CPU)

### Add/Update RAM and CPU

1. **Shutdown the VM first**:
   ```bash
   virsh shutdown web-server
   ```

2. **Update memory and CPU**:
   ```bash
   # Get current config
   virsh dumpxml web-server > vm-config.xml
   
   # Edit the XML file
   # Change <memory unit='MiB'>2048</memory> to desired size
   # Change <vcpu>2</vcpu> to desired CPU count
   
   # Undefine and redefine
   virsh undefine web-server
   virsh define vm-config.xml
   ```

3. **Restart the VM**:
   ```bash
   virsh start web-server
   ```

### Using virsh edit (Direct Edit)

```bash
virsh edit web-server  # Opens in default editor
# Modify memory and vcpu, save and exit
virsh shutdown web-server
virsh start web-server
```

---

## Real-World Scenario: Cloud Image Deployment

### Step 1: Download Cloud Image

```bash
# Example: Ubuntu cloud image
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img

# View image information
qemu-img info jammy-server-cloudimg-amd64.img
```

### Step 2: Setup Image Location

```bash
# Standard libvirt images directory
sudo cp jammy-server-cloudimg-amd64.img /var/lib/libvirt/images/ubuntu-prod.img

# Expand disk size (optional)
sudo qemu-img resize /var/lib/libvirt/images/ubuntu-prod.img +20G

# Set permissions
sudo chown libvirt-qemu:libvirt-qemu /var/lib/libvirt/images/ubuntu-prod.img
sudo chmod 600 /var/lib/libvirt/images/ubuntu-prod.img
```

### Step 3: Install OS Using virt-install

```bash
# Basic cloud image import
sudo virt-install \
  --os-info ubuntu22.04 \
  --name prod-server-01 \
  --memory 2048 \
  --vcpus 2 \
  --import \
  --disk /var/lib/libvirt/images/ubuntu-prod.img \
  --graphics none \
  --console pty,target_type=serial
```

**virt-install Options:**
- `--os-info`: Specifies OS type for optimal configuration
- `--name`: VM name
- `--memory`: RAM in MB
- `--vcpus`: CPU count
- `--import`: Import existing disk (cloud image)
- `--disk`: Disk image path
- `--graphics`: Display type (none for headless, vnc/spice for GUI)
- `--console`: Console connection type

### Step 4: Connect to VM

```bash
# Connect via console
virsh console prod-server-01

# Or SSH if cloud-init is configured
ssh ubuntu@<vm-ip>

# Exit console (Ctrl+])
```

### Step 5: Verify OS Info

```bash
# Install libosinfo tools
sudo apt install libosinfo-bin

# Query available OS info
osinfo-query os

# Check current OS detection
osinfo-detect --require filename jammy-server-cloudimg-amd64.img
```

---

## Real-World Scenario: Fresh OS Installation from ISO

### Download and Prepare ISO

```bash
# Download ISO (example: Debian 12)
wget https://cdimage.debian.org/debian-cd/12.5.0/amd64/iso-dvd/debian-12.5.0-amd64-dvd-1.iso

# Store in standard location
sudo cp debian-12.5.0-amd64-dvd-1.iso /var/lib/libvirt/boot/
```

### Install from Local ISO

```bash
# Using local ISO path
sudo virt-install \
  --osinfo debian12 \
  --name debian-prod \
  --memory 2048 \
  --vcpu 2 \
  --disk size=20 \
  --location /var/lib/libvirt/boot/debian-12.5.0-amd64-dvd-1.iso \
  --graphics none \
  --extra-args "console=ttyS0"
```

### Install from Internet (URL)

```bash
# Using remote ISO URL (faster for CI/CD pipelines)
sudo virt-install \
  --osinfo debian12 \
  --name debian-remote \
  --memory 2048 \
  --vcpu 2 \
  --disk size=20 \
  --location https://cdimage.debian.org/debian-cd/12.5.0/amd64/iso-dvd/debian-12.5.0-amd64-dvd-1.iso \
  --graphics none \
  --extra-args "console=ttyS0"
```

**virt-install Installation Options:**
- `--location`: ISO path (local or URL)
- `--disk size=XX`: Create new disk with size in GB
- `--extra-args`: Kernel arguments for automated installation
- `--console`: Console access during installation

---

## Production Example: Multi-Server Deployment Script

```bash
#!/bin/bash

# Production VM deployment script

VM_NAME="app-server-prod-01"
OS_TYPE="ubuntu22.04"
MEMORY=4096
VCPUS=4
DISK_SIZE=30
DISK_PATH="/var/lib/libvirt/images/${VM_NAME}.qcow2"
IMAGE_URL="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"

echo "Deploying production VM: ${VM_NAME}"

# Download cloud image
cd /tmp
wget -q ${IMAGE_URL} -O cloud-image.img

# Copy to libvirt
sudo cp cloud-image.img ${DISK_PATH}
sudo qemu-img resize ${DISK_PATH} +${DISK_SIZE}G
sudo chown libvirt-qemu:libvirt-qemu ${DISK_PATH}
sudo chmod 600 ${DISK_PATH}

# Create VM
sudo virt-install \
  --os-info ${OS_TYPE} \
  --name ${VM_NAME} \
  --memory ${MEMORY} \
  --vcpus ${VCPUS} \
  --import \
  --disk ${DISK_PATH} \
  --graphics none \
  --console pty,target_type=serial \
  --wait -1

echo "VM ${VM_NAME} deployed successfully"
virsh dominfo ${VM_NAME}
```

---

## Common Operations Checklist

| Task | Command |
|------|---------|
| List all VMs | `virsh list --all` |
| Start VM | `virsh start <name>` |
| Stop VM | `virsh shutdown <name>` |
| Force stop | `virsh destroy <name>` |
| View console | `virsh console <name>` |
| Edit config | `virsh edit <name>` |
| Increase RAM | Edit XML: `<memory>` tag, restart VM |
| Add CPU core | Edit XML: `<vcpu>` tag, restart VM |
| Delete VM | `virsh undefine --remove-all-storage <name>` |
| Clone VM | `virt-clone --original <src> --name <dst> --auto-clone` |

---

## Troubleshooting

```bash
# Check service status
systemctl status libvirtd

# View libvirt logs
journalctl -u libvirtd -f

# Verify KVM support
grep -o vmx /proc/cpuinfo  # Intel
grep -o svm /proc/cpuinfo  # AMD

# List networks
virsh net-list --all

# List storage pools
virsh pool-list --all
```

