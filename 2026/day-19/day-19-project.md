# Shell Scripting Project: Log Rotation, Backup and Crontab
*#90DaysOfDevOps 2026*

---

## Task 1 — Log Rotation Script: `log_rotate.sh`

```bash
#!/bin/bash
set -euo pipefail

# ─────────────────────────────────────────
# log_rotate.sh
# Usage: ./log_rotate.sh /path/to/log/directory
# ─────────────────────────────────────────

LOG_DIR="${1:-}"
COMPRESS_DAYS=7
DELETE_DAYS=30

# Validate argument
if [ -z "$LOG_DIR" ]; then
  echo "Error: No log directory provided"
  echo "Usage: $0 /path/to/log/directory"
  exit 1
fi

# Validate directory exists
if [ ! -d "$LOG_DIR" ]; then
  echo "Error: Directory does not exist: $LOG_DIR"
  exit 1
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') Starting log rotation for: $LOG_DIR"

# Count and compress .log files older than 7 days
COMPRESSED=0
while IFS= read -r -d '' FILE; do
  gzip "$FILE"
  echo "  Compressed: $FILE"
  COMPRESSED=$((COMPRESSED + 1))
done < <(find "$LOG_DIR" -name "*.log" -mtime +${COMPRESS_DAYS} -type f -print0)

# Count and delete .gz files older than 30 days
DELETED=0
while IFS= read -r -d '' FILE; do
  rm "$FILE"
  echo "  Deleted: $FILE"
  DELETED=$((DELETED + 1))
done < <(find "$LOG_DIR" -name "*.gz" -mtime +${DELETE_DAYS} -type f -print0)

echo "$(date '+%Y-%m-%d %H:%M:%S') Rotation complete — Compressed: $COMPRESSED | Deleted: $DELETED"
```

**Every new concept explained:**

**`${1:-}`:**
- `$1` = first argument
- `:-` with no default = returns empty string if `$1` is unset
- Used with `-z "$LOG_DIR"` to check if it is empty
- If empty → show usage and exit 1

**`[ -z "$LOG_DIR" ]`:**
- `-z` = zero length — true if string is empty
- Used here to catch when no argument was passed

**`[ ! -d "$LOG_DIR" ]`:**
- `-d` = is a directory
- `!` = NOT — reverse the test
- So: "if NOT a directory" → error and exit

**`find "$LOG_DIR" -name "*.log" -mtime +${COMPRESS_DAYS} -type f -print0`:**
- `-mtime +7` = modified more than 7 days ago (the `+` means "more than")
- `-type f` = files only, not directories
- `-print0` = print results separated by null character instead of newline

**Why `-print0` and `read -d ''`:**
Filenames can contain spaces. If `find` outputs results separated by newlines and a filename has a space, it gets split into two separate names. `-print0` uses null (`\0`) as the separator — null cannot appear in a filename. `read -d ''` reads up to the null terminator. This pairing handles all filenames safely including those with spaces, tabs, and special characters.

**`while IFS= read -r -d '' FILE; do ... done < <(find ...)`:**
- `< <(find ...)` = process substitution — the output of `find` is fed as input to the `while` loop
- `IFS=` = empty IFS prevents `read` from stripping leading/trailing whitespace from filenames
- `-r` = raw mode — prevents backslash interpretation
- `-d ''` = read until null terminator

This is the safe pattern for processing `find` output in a loop. Every production script that processes filenames should use this approach.

**`date '+%Y-%m-%d %H:%M:%S'`:**
- `date` = print current date/time
- `+` = start of format string
- `%Y` = 4-digit year, `%m` = month, `%d` = day
- `%H` = 24-hour, `%M` = minutes, `%S` = seconds
- Output: `2026-06-03 14:22:05` — ISO format, sorts correctly alphabetically

**Test it:**
```bash
# Create test directory with fake old logs
mkdir -p /tmp/test-logs

# Create test log files with modified times 8 days ago
touch -d "8 days ago" /tmp/test-logs/app.log
touch -d "8 days ago" /tmp/test-logs/error.log
touch -d "2 days ago" /tmp/test-logs/recent.log   # should not compress

ls -la /tmp/test-logs/

chmod +x log_rotate.sh
./log_rotate.sh /tmp/test-logs

ls -la /tmp/test-logs/
# app.log and error.log compressed to .gz
# recent.log untouched

# Test error handling
./log_rotate.sh
# Error: No log directory provided

./log_rotate.sh /path/does/not/exist
# Error: Directory does not exist
```

---

## Task 2 — Server Backup Script: `backup.sh`

```bash
#!/bin/bash
set -euo pipefail

# ─────────────────────────────────────────
# backup.sh
# Usage: ./backup.sh /source/dir /backup/destination
# ─────────────────────────────────────────

SOURCE="${1:-}"
DEST="${2:-}"
RETENTION_DAYS=14
TIMESTAMP=$(date +%Y-%m-%d)
ARCHIVE_NAME="backup-${TIMESTAMP}.tar.gz"

# Validate arguments
if [ -z "$SOURCE" ] || [ -z "$DEST" ]; then
  echo "Error: Source or destination missing"
  echo "Usage: $0 /source/dir /backup/destination"
  exit 1
fi

# Validate source exists
if [ ! -d "$SOURCE" ]; then
  echo "Error: Source directory does not exist: $SOURCE"
  exit 1
fi

# Create destination if it does not exist
mkdir -p "$DEST"

ARCHIVE_PATH="${DEST}/${ARCHIVE_NAME}"

echo "$(date '+%Y-%m-%d %H:%M:%S') Starting backup"
echo "  Source      : $SOURCE"
echo "  Destination : $DEST"
echo "  Archive     : $ARCHIVE_NAME"

# Create the archive
tar -czf "$ARCHIVE_PATH" -C "$(dirname "$SOURCE")" "$(basename "$SOURCE")"

# Verify archive was created successfully
if [ -f "$ARCHIVE_PATH" ]; then
  ARCHIVE_SIZE=$(du -sh "$ARCHIVE_PATH" | cut -f1)
  echo "$(date '+%Y-%m-%d %H:%M:%S') Backup successful"
  echo "  Archive size: $ARCHIVE_SIZE"
else
  echo "$(date '+%Y-%m-%d %H:%M:%S') Error: Archive not created"
  exit 1
fi

# Delete archives older than retention period
DELETED=0
while IFS= read -r -d '' OLD_ARCHIVE; do
  rm "$OLD_ARCHIVE"
  echo "  Removed old backup: $(basename "$OLD_ARCHIVE")"
  DELETED=$((DELETED + 1))
done < <(find "$DEST" -name "backup-*.tar.gz" -mtime +${RETENTION_DAYS} -type f -print0)

echo "$(date '+%Y-%m-%d %H:%M:%S') Cleanup complete — removed $DELETED old backup(s)"
```

**New concepts explained:**

**`tar -czf "$ARCHIVE_PATH" -C "$(dirname "$SOURCE")" "$(basename "$SOURCE")"`:**
- `tar` = tape archive — creates/extracts archive files
- `-c` = **create** a new archive
- `-z` = **compress** with gzip
- `-f` = **file** — the archive filename follows
- `-C /parent/dir` = **change** to this directory before archiving
- `$(dirname "$SOURCE")` = parent directory of source (e.g. `/opt` if source is `/opt/myapp`)
- `$(basename "$SOURCE")` = just the last part of the path (e.g. `myapp`)

**Why `-C dirname + basename` instead of just the full path:**
Without `-C`, the archive stores the full absolute path — extracting it recreates `/opt/myapp/` exactly. With `-C`, the archive stores just `myapp/` — you can extract it anywhere. Much more portable.

**`du -sh "$ARCHIVE_PATH" | cut -f1`:**
- `du -sh` = disk usage, summary, human-readable
- Output: `24M    /backup/backup-2026-06-03.tar.gz`
- `cut -f1` = cut by tab, take first field = `24M`

**`[ -f "$ARCHIVE_PATH" ]`:**
- `-f` = file exists and is a regular file
- Used to verify the archive was actually created after `tar` ran
- Belt and braces — even with `set -e`, an explicit check adds clarity

**Test it:**
```bash
# Create test source
mkdir -p /tmp/test-source
echo "Important data" > /tmp/test-source/data.txt
echo "Config file" > /tmp/test-source/config.conf

chmod +x backup.sh
./backup.sh /tmp/test-source /tmp/test-backups

ls -lh /tmp/test-backups/
# backup-2026-06-03.tar.gz

# Verify archive contents
tar -tzf /tmp/test-backups/backup-2026-06-03.tar.gz
# test-source/
# test-source/data.txt
# test-source/config.conf

# Test error handling
./backup.sh
# Error: Source or destination missing
```

---

## Task 3 — Crontab Scheduling

### What is Cron?

Cron is the Linux task scheduler — it runs commands automatically at specified times. The `crond` daemon checks the crontab file every minute and runs any commands whose schedule matches the current time.

### Cron Syntax

```
*  *  *  *  *   command
│  │  │  │  │
│  │  │  │  └── Day of week (0-7, both 0 and 7 = Sunday)
│  │  │  └───── Month (1-12)
│  │  └──────── Day of month (1-31)
│  └──────────── Hour (0-23)
└─────────────── Minute (0-59)
```

**Special characters:**

| Symbol | Meaning | Example |
|--------|---------|---------|
| `*` | Every / any | `* * * * *` = every minute |
| `,` | List | `0 9,17 * * *` = 9 AM and 5 PM |
| `-` | Range | `0 9-17 * * *` = every hour 9 AM to 5 PM |
| `/` | Step | `*/5 * * * *` = every 5 minutes |

**Cron entries for this project:**

```bash
# Run log_rotate.sh every day at 2 AM
0 2 * * * /home/ubuntu/devops/day19/log_rotate.sh /var/log/myapp >> /var/log/maintenance.log 2>&1

# Run backup.sh every Sunday at 3 AM
0 3 * * 0 /home/ubuntu/devops/day19/backup.sh /opt/myapp /backup/archives >> /var/log/maintenance.log 2>&1

# Run health check every 5 minutes
*/5 * * * * /home/ubuntu/devops/day19/health_check.sh >> /var/log/health.log 2>&1
```

**`>> /var/log/maintenance.log 2>&1` in cron entries:**
- `>>` = append stdout to the log file
- `2>&1` = redirect stderr to the same place as stdout
- Without this, cron sends output as email to the system user — which is not useful. Always redirect to a log file.

**Common cron examples:**

```bash
# Every minute (testing)
* * * * * /path/to/script.sh

# Every day at midnight
0 0 * * * /path/to/script.sh

# Every Monday at 8 AM
0 8 * * 1 /path/to/script.sh

# Every 15 minutes
*/15 * * * * /path/to/script.sh

# First day of every month at 6 AM
0 6 1 * * /path/to/script.sh
```

**Crontab commands:**
```bash
crontab -l    # list current cron jobs
crontab -e    # edit cron jobs (opens in default editor)
crontab -r    # remove ALL cron jobs — careful, no confirmation
```

---

## Task 4 — Maintenance Script: `maintenance.sh`

```bash
#!/bin/bash
set -euo pipefail

# ─────────────────────────────────────────
# maintenance.sh
# Runs log rotation and backup, logs all output
# Cron: 0 1 * * * /path/to/maintenance.sh
# ─────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/var/log/maintenance.log"
LOG_DIR="/tmp/test-logs"
BACKUP_SOURCE="/tmp/test-source"
BACKUP_DEST="/tmp/test-backups"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOG_FILE"
}

run_log_rotation() {
  log "=== Starting log rotation ==="
  if bash "$SCRIPT_DIR/log_rotate.sh" "$LOG_DIR" >> "$LOG_FILE" 2>&1; then
    log "Log rotation completed successfully"
  else
    log "ERROR: Log rotation failed (exit code: $?)"
  fi
}

run_backup() {
  log "=== Starting backup ==="
  if bash "$SCRIPT_DIR/backup.sh" "$BACKUP_SOURCE" "$BACKUP_DEST" >> "$LOG_FILE" 2>&1; then
    log "Backup completed successfully"
  else
    log "ERROR: Backup failed (exit code: $?)"
  fi
}

main() {
  log "==============================="
  log "Maintenance started"
  log "==============================="

  run_log_rotation
  run_backup

  log "==============================="
  log "Maintenance finished"
  log "==============================="
}

main
```

**New concepts explained:**

**`SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`:**
- `${BASH_SOURCE[0]}` = the path of the current script file itself
- `dirname` = extract the directory portion
- `cd ... && pwd` = change to that directory and print the absolute path
- This makes the script find its sibling scripts (`log_rotate.sh`, `backup.sh`) correctly regardless of where it is called from
- **Why not just use `$0`:** When a script is sourced (`. script.sh`) rather than executed, `$0` is the shell name not the script name. `${BASH_SOURCE[0]}` is always the script file.

**`log()` function with `tee -a`:**
- `tee -a "$LOG_FILE"` = append to log file AND display on terminal
- So when cron runs it, output goes to `$LOG_FILE`
- When run manually, output also shows on screen
- Every maintenance script should have a `log()` function like this

**`if bash "$SCRIPT_DIR/log_rotate.sh" ...; then`:**
- `bash script.sh` runs the script explicitly with bash
- Wrapping in `if` captures the exit code
- Even with `set -e`, wrapping in `if` prevents the failure from killing the entire maintenance script — it logs the error and continues to the next task

**Test it:**
```bash
chmod +x maintenance.sh

# Create test directory and files
mkdir -p /tmp/test-logs /tmp/test-source
touch -d "8 days ago" /tmp/test-logs/old.log
echo "test data" > /tmp/test-source/data.txt

sudo ./maintenance.sh

# Check the log
cat /var/log/maintenance.log
```

---

## 3 Key Learnings

**1. `-print0` and `read -d ''` is the only safe way to process filenames in a loop.**
Filenames with spaces break standard `for file in $(find ...)` loops. The null-separated approach handles every filename correctly — including those with spaces, tabs, and special characters. Use it always in production scripts.

**2. Cron needs full paths — relative paths do not work.**
Cron runs with a minimal environment — `$PATH` does not include the directories you have in your interactive shell. Always use absolute paths for scripts and binaries in cron entries: `/usr/bin/gzip` not `gzip`, `/home/ubuntu/scripts/backup.sh` not `./backup.sh`.

**3. Log every maintenance action with a timestamp prefix.**
A maintenance script that runs silently is dangerous. When something breaks at 2 AM, the log file is the only source of truth. `$(date '+%Y-%m-%d %H:%M:%S') message` in every log line makes it trivial to find exactly when something went wrong.

---

*#90DaysOfDevOps 2026*
