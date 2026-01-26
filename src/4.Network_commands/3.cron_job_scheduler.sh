#!/bin/bash

# CRON Job Scheduler
# Reference: 4_Network_config_&_troubleshooting.md

# CRON helps schedule specific tasks/commands to execute at defined times

# ============ Basic Cron Management ============

# View current user's cron jobs
crontab -l

# Edit cron jobs
crontab -e

# Edit cron jobs using specific editor
EDITOR=nano crontab -e

# Remove all cron jobs for current user
crontab -r

# Remove cron job for specific user (as root)
sudo crontab -r -u username

# Install cron job from file
crontab /path/to/cronfile

# ============ Cron Job Format ============
# Minute Hour Day Month DayOfWeek Command
# 0-59   0-23  1-31  1-12  0-6(Sun-Sat) /path/to/command

# ============ Common Cron Examples ============

# Run daily at 2:30 AM
# 30 2 * * * /path/to/script.sh

# Run every Monday at 9:00 AM
# 0 9 * * 1 /path/to/script.sh

# Run every 15 minutes
# */15 * * * * /path/to/script.sh

# Run at 3:15 AM on the 15th of each month
# 15 3 15 * * /path/to/script.sh

# Run every hour
# 0 * * * * /path/to/script.sh

# Run every Sunday at midnight
# 0 0 * * 0 /path/to/script.sh

# Run at 1:00 AM and 1:00 PM daily
# 0 1,13 * * * /path/to/script.sh

# Run on weekdays (Mon-Fri) at 5:00 PM
# 0 17 * * 1-5 /path/to/script.sh

# Run 4 times a day at 12:00, 6:00, 12:00, 18:00
# 0 0,6,12,18 * * * /path/to/script.sh

# ============ Step Values ============
# Use / to specify intervals
# */5 = every 5 units

# Every 5 minutes
# */5 * * * * /path/to/script.sh

# Every 2 hours
# 0 */2 * * * /path/to/script.sh

# Every 3 days
# 0 0 */3 * * /path/to/script.sh

# ============ Environment Variables in Cron ============

# Set PATH for cron job
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
SHELL=/bin/bash

# Set email for cron output
MAILTO=user@example.com

# Cron job with output redirection
0 2 * * * /path/to/script.sh >> /var/log/cron.log 2>&1

# ============ System-wide Cron Jobs ============

# System cron files are located in /etc/cron*
# /etc/cron.daily - runs daily
# /etc/cron.hourly - runs hourly
# /etc/cron.weekly - runs weekly
# /etc/cron.monthly - runs monthly

# Create a system-wide cron job
# sudo nano /etc/cron.d/mycron

# ============ Cron Job Monitoring ============

# Check if crond service is running
systemctl status cron

# Start/Stop cron service
sudo systemctl start cron
sudo systemctl stop cron

# Check cron logs (requires sudo)
sudo tail -f /var/log/syslog | grep CRON

# Or check journalctl
sudo journalctl -u cron

# Check cron execution
grep CRON /var/log/syslog

# ============ Important Notes ============

# - No sudo recommended for cron jobs
# - Use absolute paths for commands in cron
# - Output is emailed unless redirected
# - Cron runs as specified user in crontab
# - Environment variables must be explicitly set
# - Time is in 24-hour format

# ============ Disable Cron Job Temporarily ============

# Comment out the line in crontab to disable temporarily
# # 0 2 * * * /path/to/script.sh

# ============ Special Strings ============
# @reboot     - Run at startup
# @yearly     - Run annually (0 0 1 1 *)
# @annually   - Same as @yearly
# @monthly    - Run monthly (0 0 1 * *)
# @weekly     - Run weekly (0 0 * * 0)
# @daily      - Run daily (0 0 * * *)
# @midnight   - Run daily at midnight
# @hourly     - Run hourly (0 * * * *)

# Example using special strings:
# @reboot /path/to/startup_script.sh
# @daily /path/to/backup_script.sh

echo "CRON job scheduler examples completed!"
