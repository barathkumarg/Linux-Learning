# Logging and Journaling in Linux

## Table of Contents
1. [Logging Daemons Overview](#logging-daemons-overview)
2. [Log Files and Locations](#log-files-and-locations)
3. [journalctl Command](#journalctl-command)
4. [Log Levels](#log-levels)
5. [Filtering by Time](#filtering-by-time)
6. [Boot-Related Logs](#boot-related-logs)
7. [Preserving Logs](#preserving-logs)
8. [last Command](#last-command)

---

## Logging Daemons Overview

**rsyslog** - Rocket-fast system for log processing. It's the primary logging daemon in most Linux distributions, responsible for collecting, routing, and storing system log messages.

**Directory:** All system logs are stored in `/var/log/`

---

## Log Files and Locations

### Common Log Files in /var/log

| File | Purpose |
|------|---------|
| `/var/log/auth.log` | Authentication logs (login, sudo, ssh attempts) |
| `/var/log/syslog` | General system logs and kernel messages |
| `/var/log/kern.log` | Kernel-specific messages |
| `/var/log/boot.log` | System boot messages |
| `/var/log/dmesg` | Kernel ring buffer messages |
| `/var/log/messages` | System messages (RHEL/CentOS) |

**Example:**
```bash
# View authentication logs
cat /var/log/auth.log

# View system logs
cat /var/log/syslog

# Monitor logs in real-time
tail -f /var/log/syslog
```

---

## journalctl Command

**journalctl** collects and displays logs from rsyslog and systemd journals. It provides a unified way to query and analyze system logs.

**Note:** journalctl is shorthand alternative to `/var/log/syslog`

### Basic journalctl Usage

**Syntax:** `journalctl [OPTIONS]`

**Basic Commands:**
```bash
journalctl              # Display all logs (oldest first)
journalctl -r           # Reverse order (newest first)
journalctl -n 50        # Show last 50 log entries
journalctl -f           # Follow logs in real-time (tail mode)
journalctl --no-pager   # Display without pager
```

### Filter by Unit/Service

**Syntax:** `journalctl -u UNIT_NAME`

**Usage:** View logs for a specific systemd unit or service.

**Examples:**
```bash
# Logs for sudo command
journalctl /usr/bin/sudo

# Logs for specific service
journalctl -u ssh.service
journalctl -u nginx.service

# Logs for multiple services
journalctl -u ssh.service -u nginx.service
```

### Filter by Executable

**Syntax:** `journalctl /path/to/executable`

**Examples:**
```bash
journalctl /usr/bin/sudo
journalctl /usr/sbin/sshd
```

---

## Log Levels

Log levels indicate the severity of messages. Lower numbers are more severe.

| Level | Number | Meaning |
|-------|--------|---------|
| emerg | 0 | System is unusable |
| alert | 1 | Action must be taken immediately |
| crit | 2 | Critical condition |
| err | 3 | Error condition |
| warning | 4 | Warning condition |
| notice | 5 | Normal but significant condition |
| info | 6 | Informational message |
| debug | 7 | Debug-level message |

### Filter by Log Level

**Syntax:** `journalctl -p LEVEL`

**Examples:**
```bash
# Show only errors
journalctl -p err

# Show errors and critical
journalctl -p crit

# Show info and above (notice, warning, err, crit, alert, emerg)
journalctl -p info

# Show debug messages
journalctl -p debug

# Show warning and above
journalctl -p warning
```

**Common Usage:**
```bash
# Find all authentication failures
journalctl -u ssh.service -p err

# Show all system errors
journalctl -p err -r

# Show critical issues only
journalctl -p crit --no-pager
```

---

## Filtering by Time

### Time-based Filtering

**Syntax:** `journalctl -S START_TIME -U END_TIME`

**Options:**
- `-S` / `--since` - Start time
- `-U` / `--until` - End time

**Time Formats:**
```bash
# 24-hour format (HH:MM)
journalctl -S 01:00 -U 02:00

# Date and time
journalctl -S "2024-03-01 10:00:00" -U "2024-03-01 11:00:00"

# Relative time
journalctl -S "1 hour ago"
journalctl -S "30 minutes ago"
journalctl -S "yesterday"
journalctl -S "today"
```

**Examples:**
```bash
# Logs from the last hour
journalctl -S "1 hour ago"

# Logs from yesterday
journalctl -S yesterday

# Logs from specific date range
journalctl -S "2024-02-28" -U "2024-03-01"

# Logs in the last 30 minutes
journalctl -S "30 minutes ago"
```

---

## Boot-Related Logs

### View Boot Sessions

**Syntax:** `journalctl -b OPTIONS`

**Options:**
- `-b 0` - Current boot (default)
- `-b -1` - Previous boot
- `-b -2` - Boot before the previous one
- `--list-boots` - List all available boots

**Examples:**
```bash
# Logs from current boot
journalctl -b 0
journalctl -b

# Logs from previous boot
journalctl -b -1

# Logs from two boots ago
journalctl -b -2

# List all available boots with timestamps
journalctl --list-boots

# Kernel messages from current boot
journalctl -b 0 -k

# Boot logs for specific service across all boots
journalctl -u ssh.service -b
```

**Common Usage:**
```bash
# Troubleshoot boot issues
journalctl -b 0 | grep -i error

# Compare current and previous boot
journalctl -b -1 > /tmp/prev_boot.log
journalctl -b 0 > /tmp/current_boot.log

# Show boot time duration
journalctl -b 0 -q
```

---

## Preserving Logs

By default, **journalctl** stores logs in temporary storage (`/run/log/journal/`). To persist logs across reboots, modify the configuration.

### Enable Persistent Storage

**File:** `/etc/systemd/journald.conf`

**Configuration:**
```bash
# Edit the journald configuration
sudo nano /etc/systemd/journald.conf

# Change this line:
# Storage=auto
# To:
Storage=persistent

# Restart journald service
sudo systemctl restart systemd-journald

# Create log directory if needed
sudo mkdir -p /var/log/journal
sudo chown root:systemd-journal /var/log/journal
sudo chmod 2755 /var/log/journal
```

**Verify Persistent Storage:**
```bash
journalctl --list-boots
```

---

## last Command

**last** displays login records, showing who logged in, from where, and when. It reads from `/var/log/wtmp` and `/var/log/btmp`.

**Syntax:** `last [OPTIONS] [username]`

### Basic Usage

**Examples:**
```bash
last                    # Show all login records
last -n 10              # Show last 10 logins
last username           # Show logins for specific user
last -f /var/log/wtmp   # Specify wtmp file
last reboot             # Show system reboots
last -x shutdown        # Show shutdowns
```

### Filter Failed Logins

**Syntax:** `lastb [OPTIONS]`

**Examples:**
```bash
lastb                   # Show failed login attempts
lastb -n 5              # Show last 5 failed attempts
lastb username          # Failed attempts for specific user
```

### Time-based Filtering

**Examples:**
```bash
# Show logins from today
last -d

# Show logins from specific date
last -t "20240301.000000" username

# Show logins for the last 7 days
last -d | head -20
```

**Common Usage:**
```bash
# Monitor user access
last | head -20

# Find suspicious login attempts
lastb | head -10

# Check who logged in and when
last barath

# System reboot history
last reboot

# User activity audit
last -f /var/log/wtmp | grep username
```

---

## Quick Reference

| Task | Command |
|------|---------|
| View recent logs | `journalctl -n 20 -r` |
| Real-time log monitoring | `journalctl -f` |
| Errors only | `journalctl -p err` |
| Last hour logs | `journalctl -S "1 hour ago"` |
| Current boot logs | `journalctl -b 0` |
| Service logs | `journalctl -u service-name` |
| Login records | `last` |
| Failed logins | `lastb` |
| Authentication logs | `cat /var/log/auth.log` |
| System logs | `cat /var/log/syslog` |
