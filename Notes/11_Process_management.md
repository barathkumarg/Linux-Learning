# Process Management in Linux

## Table of Contents
1. [ps Command](#ps-command)
2. [pgrep and pkill](#pgrep-and-pkill)
3. [Process Priority (Nice & Renice)](#process-priority-nice--renice)
4. [Process Control Commands](#process-control-commands)
5. [lsof - List Open Files](#lsof---list-open-files)
6. [Process States](#process-states)
7. [Quick Reference](#quick-reference)

---

## ps Command

The `ps` command displays a snapshot of currently running processes.

### Basic Options

| Option | Description |
|--------|-------------|
| `ps` | Current user's processes |
| `ps au` | All users, user-oriented format |
| `ps aux` | All processes with detailed info (most common) |
| `ps fax` | All processes in tree format (parent-child) |
| `ps lax` | All processes in long format with priority |
| `-e` | All processes |
| `-f` | Full format listing |
| `-l` | Long format listing |

### ps aux Output Columns

| Column | Meaning |
|--------|---------|
| `USER` | Process owner |
| `PID` | Process ID |
| `%CPU` | CPU usage percentage |
| `%MEM` | Memory usage percentage |
| `VSZ` | Virtual memory (KB) |
| `RSS` | Physical memory (KB) |
| `TTY` | Terminal (? = none) |
| `STAT` | Process state (R, S, Z, etc.) |
| `START` | Start time |
| `COMMAND` | Command executed |

### Common Usage

```bash
ps aux                          # All processes
ps aux | grep firefox           # Find specific process
ps aux | sort -k3 -rn | head    # Top CPU processes
ps aux | sort -k4 -rn | head    # Top memory processes
ps fax                          # Process hierarchy
ps fax | grep bash              # Find process tree
```

---

## pgrep and pkill

**pgrep** searches for processes by name and returns PIDs. **pkill** kills processes matching a pattern.

### pgrep Syntax and Options

**Syntax:** `pgrep [options] <pattern>`

| Option | Description |
|--------|-------------|
| `-l` | Show process name with PID |
| `-a` | List all matching processes |
| `-u <user>` | Search by username |
| `-f` | Match full command line (not just name) |
| `-x` | Exact match only |
| `-n` | Show newest process only |
| `-o` | Show oldest process only |
| `-c` | Count matching processes |
| `-v` | Invert (show non-matching) |

### pgrep Examples

```bash
pgrep firefox              # Get PID
pgrep -l firefox           # Get PID and name
pgrep -a firefox           # List all matches
pgrep -u john              # Processes for user john
pgrep -f "python script"   # Full command line match
pgrep -c firefox           # Count processes
pgrep -n firefox           # Newest process
pgrep -o firefox           # Oldest process
```

### pkill - Kill by Pattern

**Syntax:** `pkill [options] <pattern>`

```bash
pkill firefox               # Kill by name
pkill -u john bash          # Kill for specific user
pkill -f "python script.py" # Full command match
pkill -TERM firefox         # Graceful kill (SIGTERM)
pkill -KILL firefox         # Force kill (SIGKILL)
pkill -9 firefox            # Force kill (same as -KILL)
```



## Process Priority (Nice & Renice)

Process priority determines CPU time allocation. Nice value range: **-20 (highest) to +19 (lowest)**. Only root can set negative values.

### nice Command

Start a process with specified priority.

**Syntax:** `nice -n <value> <command>`

```bash
nice firefox                    # Default priority (0)
nice -n -5 backup_script.sh     # Higher priority (root only)
nice -n 10 heavy_process        # Lower priority
nice -n 19 find /data -type f   # Lowest priority for batch jobs
```

### renice Command

Change priority of running process.

**Syntax:** `renice <value> -p <PID>` or `renice <value> -u <user>`

| Option | Description |
|--------|-------------|
| `-p <PID>` | Specific process |
| `-u <user>` | All processes of user |
| `-g <group>` | All processes of group |

```bash
renice +5 -p 1234               # Increase priority (lower it)
sudo renice -5 -p 1234          # Decrease priority (root only)
sudo renice +10 -u john         # Change for all of user's processes
renice +3 -p 1001 -p 1002       # Multiple processes
```

### Key Rules

- **Users**: Can only INCREASE nice value (make priority lower). Cannot set negative values.
- **Root**: Can set any priority value.
- **Formula**: `priority = 20 + nice_value`
- **Usage**: View with `ps aux` or `ps -l` (NI column = nice value)



## Process Control Commands

### kill and killall

Terminate processes by PID or signal.

```bash
kill <PID>                  # Graceful terminate (SIGTERM, default)
kill -9 <PID>               # Force kill (SIGKILL)
kill -1 <PID>               # Hangup signal (SIGHUP)
kill -l                     # List all signals

killall <process_name>      # Kill all by process name
killall -9 firefox          # Force kill all
killall -TERM apache2       # Send specific signal
```

### fg / bg / jobs

Job control for foreground/background processes.

```bash
jobs                        # List background jobs
jobs -l                     # Show with PIDs
fg %1                       # Bring job 1 to foreground
bg %1                       # Resume job 1 in background
wait                        # Wait for all background jobs
```

### top / htop

Real-time process monitoring.

```bash
top                         # Interactive process monitor
top -u username             # Monitor specific user
htop                        # Enhanced version (if installed)
```

---

## lsof - List Open Files

Shows files, sockets, and connections opened by processes.

### Common Options

| Option | Description |
|--------|-------------|
| `-p <PID>` | Files opened by process |
| `-c <process>` | Files opened by process name |
| `-u <user>` | Files opened by user |
| `-i` | Network connections (IPv4/IPv6) |
| `-i <protocol>` | Specific protocol (TCP/UDP) |
| `-i :<port>` | Specific port |
| `+D <dir>` | Files in directory tree |
| `-t` | Show only PID (for scripting) |

### Examples

```bash
lsof                                # All open files (verbose)
lsof -p 1234                        # Process with PID 1234
lsof -c firefox                     # By process name
lsof -u john                        # By user
lsof /path/to/file                  # Find who has file open
lsof +D /var/log                    # Files in directory
lsof -i                             # All network connections
lsof -i TCP                         # TCP connections only
lsof -i :8080                       # Specific port
lsof -i -sTCP:LISTEN                # Listening ports
lsof -i -sTCP:ESTABLISHED           # Established connections
```

### Real-World Use Cases

```bash
# Find process with file locked
lsof /path/to/file

# Check which process uses port
lsof -i :3000

# Find deleted files still open (disk full issue)
lsof | grep deleted

# Get PID using file
PID=$(lsof -t /path/to/file)

# Monitor process connections
lsof -i -p <PID>

# Find all files opened by user
lsof -u www-data | wc -l
```

---

## Process States

| Code | State | Description |
|------|-------|-------------|
| **R** | Running | Executing or in queue |
| **S** | Interruptible Sleep | Waiting for event/I/O |
| **D** | Disk Sleep | Uninterruptible (I/O operations) |
| **Z** | Zombie | Terminated, parent hasn't read exit |
| **T** | Stopped | Stopped by job control (SIGSTOP) |
| **W** | Paging | Swapping memory |
| **X** | Dead | Should not occur |
| **<** | High Priority | Negative nice value |
| **N** | Low Priority | Positive nice value |
| **+** | Foreground | Foreground process group |

**Examples:**
- `R` = Running
- `S+` = Sleeping in foreground
- `S<` = Sleeping with high priority
- `Z` = Zombie (needs cleanup)

---

## Quick Reference

| Task | Command |
|------|---------|
| List all processes | `ps aux` |
| Process tree | `ps fax` |
| Long format with priority | `ps lax` |
| Find by name | `pgrep firefox` |
| Find with details | `pgrep -l firefox` |
| Kill by pattern | `pkill firefox` |
| Start with low priority | `nice -n 19 command` |
| Change running process priority | `renice +5 -p <PID>` |
| Kill gracefully | `kill <PID>` |
| Force kill | `kill -9 <PID>` |
| Real-time monitor | `top` or `htop` |
| Find open files | `lsof -p <PID>` |
| Find process using file | `lsof /path/to/file` |
| Check listening ports | `lsof -i -sTCP:LISTEN` |
| Connection on port | `lsof -i :8080` |
| List background jobs | `jobs` |
| Bring to foreground | `fg %1` |
| Send to background | `bg %1` |

---

## Common Workflows

**Monitor and kill CPU hog:**
```bash
ps aux | sort -k3 -rn | head
renice +10 -p <PID>         # Lower priority
kill <PID>                  # Or terminate if needed
```

**Find what's using a file:**
```bash
lsof /path/to/file
kill -9 <PID>               # Terminate if needed
```

**Port in use investigation:**
```bash
lsof -i :8080
ps aux | grep <PID>
kill -9 <PID>
```

**Start long-running task safely:**
```bash
nice -n 19 long_task &
watch 'ps aux | grep long_task'
```

---




