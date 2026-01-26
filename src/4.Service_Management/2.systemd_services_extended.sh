#!/bin/bash

# Systemd Service Management - Extended Commands
# Reference: 9_Service_Management.md

# ============ Register Service File ============
# Service files are located in: /etc/systemd/system/ or /usr/lib/systemd/system/
# Example service file location: /etc/systemd/system/myservice.service

# ============ Reload Daemon ============
# Apply new changes to service files
sudo systemctl daemon-reload

# ============ Service Management Commands ============

# Start a service
sudo systemctl start service_name

# Stop a service
sudo systemctl stop service_name

# Restart a service
sudo systemctl restart service_name

# Reload configuration (without stopping)
sudo systemctl reload service_name

# Enable service to start on boot
sudo systemctl enable service_name

# Disable service from starting on boot
sudo systemctl disable service_name

# Check status of a service
sudo systemctl status service_name

# ============ Edit Service File ============

# Edit service file (cannot start the process while editing)
sudo systemctl edit service_name --full

# Create a new service file
# sudo nano /etc/systemd/system/myservice.service

# ============ Service File Template ============
cat > /tmp/sample_service_template.txt << 'EOF'
[Unit]
Description=My Custom Service
After=network.target

[Service]
Type=simple
User=myuser
WorkingDirectory=/path/to/working/dir
ExecStart=/path/to/executable
Restart=on-failure
RestartSec=10s

[Install]
WantedBy=multi-user.target
EOF

# ============ Journalctl Commands ============

# View logs for a specific service
sudo journalctl -u service_name

# Follow logs in real-time
sudo journalctl -u service_name -f

# View last 100 lines
sudo journalctl -u service_name -n 100

# View logs since last boot
sudo journalctl -u service_name -b

# View logs for specific time range
sudo journalctl -u service_name --since "2024-01-20" --until "2024-01-25"

# View logs with full details
sudo journalctl -u service_name -o verbose

# ============ Service Status Checks ============

# List all active services
sudo systemctl list-units --type=service --state=running

# List all enabled services
sudo systemctl list-unit-files --type=service --state=enabled

# Check if service is enabled
sudo systemctl is-enabled service_name

# Check if service is active
sudo systemctl is-active service_name

# ============ Service Dependency Check ============

# List dependencies of a service
sudo systemctl list-dependencies service_name

# List what depends on a service
sudo systemctl list-dependencies service_name --reverse

echo "Systemd service management examples completed!"
