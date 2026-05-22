# Linux File System Hierarchy and Scenario-Based Practice
*Day 07 | Fri 23 May 2026 | #90DaysOfDevOps 2026*

---

## Part 1 – Linux File System Hierarchy

Linux follows the **Filesystem Hierarchy Standard (FHS)** — a contract that defines exactly where every type of file belongs. Unlike Windows where apps install anywhere, on Linux every directory has a defined purpose. Knowing this means navigating to any file instantly, without searching.

---

### `/` — Root

The absolute starting point of the entire filesystem. Every path on a Linux system begins here. There is only one root — even mounted external drives and network shares appear as subdirectories under `/`.

```bash
ls /
# bin  boot  dev  etc  home  lib  lib64  lost+found
# media  mnt  opt  proc  root  run  sbin  snap  srv  sys  tmp  usr  var
```

**I use this when:** Checking what top-level directories exist on a new or unfamiliar server — orientation before navigating deeper.

---

### `/home` — User Home Directories

Contains one subdirectory per non-root user on the system. This is where user files, shell configs (`.bashrc`, `.profile`), and personal scripts live.

```bash
ls /home
# ameerul
```

**I use this when:** Locating user-specific scripts, checking dot files (`.bashrc`, `.bash_history`), or verifying a user's working directory exists before running automation against it.

---

### `/root` — Root User's Home

The home directory of the `root` account. Separate from `/home` intentionally — root's files are isolated from regular users.

```bash
ls /root
# snap  (minimal — root should not accumulate personal files)
```

**I use this when:** Running administrative one-off scripts as root, checking root's `.bash_history` during a security audit, or placing emergency recovery scripts.

---

### `/etc` — Configuration Files

The most critical directory in production. Every service on the system has its configuration here. Nothing is installed here — only configuration files that control how things behave.

```bash
ls /etc
# nginx/  ssh/  docker/  cron.d/  environment  hostname
# fstab  passwd  sudoers  hosts  resolv.conf  ...
```

**Key files I reference regularly:**

| File / Dir | Purpose |
|-----------|---------|
| `/etc/nginx/` | Nginx virtual host and server configs |
| `/etc/ssh/sshd_config` | SSH daemon settings — port, auth method, allowed users |
| `/etc/environment` | System-wide environment variables |
| `/etc/hosts` | Local DNS overrides |
| `/etc/fstab` | Filesystem mount definitions — survives reboots |
| `/etc/cron.d/` | System cron job definitions |
| `/etc/sudoers` | Who can run sudo and what they can run |
| `/etc/passwd` | User account information |

```bash
cat /etc/hostname
# devopsmachine

cat /etc/hosts
# Shows local hostname-to-IP mappings

cat /etc/environment
# PATH and system-wide environment variables
```

**I use this when:** Every time before editing any service — read the current config first. Every deployment verification — confirm the config file reflects the intended state.

---

### `/var/log` — Log Files

Where every service writes its operational logs. This is the primary evidence trail for every incident. Real-time service health, historical error patterns, security events — all here.

```bash
ls /var/log
# syslog  auth.log  kern.log  dpkg.log  journal/
# nginx/  docker/  apt/  installer/
```

**Key log files:**

| Log File | What It Contains |
|----------|-----------------|
| `/var/log/syslog` | General system events — the main system log |
| `/var/log/auth.log` | SSH logins, sudo usage, authentication events |
| `/var/log/kern.log` | Kernel messages — hardware errors, OOM events |
| `/var/log/dpkg.log` | Package install/remove history |
| `/var/log/nginx/access.log` | Every HTTP request to Nginx |
| `/var/log/nginx/error.log` | Nginx errors — 502s, config errors, upstream failures |
| `/var/log/journal/` | systemd journal — logs for all systemd-managed services |

```bash
# Find the largest log files — first check during a disk-full alert
du -sh /var/log/* 2>/dev/null | sort -h | tail -5
```

**Observed output on devopsmachine:**
```
304K    /var/log/syslog.3.gz
772K    /var/log/syslog.1
1.2M    /var/log/sysstat
1.3M    /var/log/installer
134M    /var/log/journal
```

`/var/log/journal` at 134M is the systemd journal — expected on a running system.

**I use this when:** Every incident starts here. Alert fires → check the relevant log → scope the time window → identify the error → take action.

---

### `/tmp` — Temporary Files

Temporary storage that is cleared on every reboot. Any process can write here without special permissions. Used for staging files, temporary downloads, inter-process communication.

```bash
ls /tmp
# Various runtime temp files, snap directories, systemd sockets
```

**Critical rule:** Never store anything important in `/tmp`. It will disappear on reboot. Use `/var/tmp` if you need temporary files to survive a reboot.

**I use this when:** Staging large file transfers before moving to the final destination, temporary script output during debugging, quick test file creation.

---

### `/bin` and `/usr/bin` — Command Binaries

`/bin` contains essential system binaries needed during boot and in single-user mode — `ls`, `cat`, `cp`, `mv`, `bash`, `sh`. These must be available even before `/usr` is mounted.

`/usr/bin` contains user-facing command binaries installed by the package manager — `docker`, `nginx`, `git`, `python3`, `curl`. The majority of commands you run daily are here.

```bash
which docker
# /usr/bin/docker

which ls
# /usr/bin/ls  (on Ubuntu 24.04 — /bin is a symlink to /usr/bin)
```

On modern Ubuntu, `/bin` is a symlink to `/usr/bin` — they are merged. This is the `usr-merge` that happened in Ubuntu 23.04+.

**I use this when:** Verifying a binary exists before scripting against it (`which nginx`), checking binary version (`/usr/bin/docker --version`), troubleshooting PATH issues.

---

### `/opt` — Optional / Third-Party Applications

Where third-party software that does not follow standard Linux package conventions installs. Each application gets its own subdirectory: `/opt/appname/`.

```bash
ls /opt
# containerd  (Docker's container runtime)
```

**I use this when:** This is where I deploy platforms like JumpServer PAM, Moodle, Snipe-IT — anything that ships as a self-contained package with its own directory structure, not managed by `apt`.

---

### `/proc` — Process and Kernel Information (Virtual)

Not a real filesystem on disk — it is a virtual filesystem the kernel generates in memory. Contains real-time information about every running process and kernel state.

```bash
cat /proc/meminfo    # live memory stats
cat /proc/cpuinfo    # CPU details
cat /proc/loadavg    # load average (same source as uptime)
ls /proc/1/          # directory for PID 1 (systemd)
```

**I use this when:** Reading raw kernel metrics that monitoring tools like Zabbix and Prometheus pull from — understanding the source of those metrics.

---

### `/dev` — Device Files

Every hardware device on the system is represented as a file here. Disks (`/dev/sda`), partitions (`/dev/sda1`), LVM volumes (`/dev/mapper/`), terminals (`/dev/pts/`), and the null device (`/dev/null`).

```bash
ls /dev/mapper/
# control  ubuntu--vg-ubuntu--lv   (LVM volume on devopsmachine)
```

**I use this when:** LVM management, disk operations (`dd`, `fdisk`), checking device existence before mounting, and the classic `/dev/null` to discard unwanted output.

---

## Part 2 – Scenario-Based Troubleshooting Practice

---

### Scenario 1: Service Not Starting After Reboot

**Situation:** A web application service `myapp` failed to start after a server reboot. Diagnose the issue.

**Troubleshooting flow:**

```bash
# Step 1 — What is the current state of the service?
systemctl status myapp
```
**Why first:** Status gives the most immediate information — is it failed, inactive, or not found. The last few log lines are also shown inline. This tells me which direction to investigate.

```bash
# Step 2 — Read the full recent logs for this service
journalctl -u myapp -n 50
```
**Why:** Status only shows a few lines. `journalctl` gives the full picture — startup errors, missing files, port conflicts, permission errors. The actual failure reason is almost always here.

```bash
# Step 3 — Is it configured to start on boot?
systemctl is-enabled myapp
```
**Why:** If output is `disabled`, the service was never enabled for boot. It ran before only because someone started it manually. This is a common gap after migrations or new deployments.

```bash
# Step 4 — Were there any system-level errors at boot time?
journalctl -p err --since "1 hour ago"
```
**Why:** Sometimes the service failure is caused by a dependency — a database not ready, a network interface not up. This catches system-wide errors that may have blocked the service.

```bash
# Step 5 — Check if the config file is valid (service-specific)
nginx -t          # for nginx
# or
systemctl cat myapp    # shows the unit file — check ExecStart path and dependencies
```
**Why:** A misconfiguration in `/etc/myapp/` or a wrong path in the unit file prevents startup silently. Validate the config before attempting restart.

```bash
# Step 6 — If the issue is resolved, enable and start
sudo systemctl enable myapp
sudo systemctl start myapp
systemctl status myapp
```

---

### Scenario 2: High CPU Usage — Server Is Slow

**Situation:** Manager reports the application server is slow. You SSH in. Identify the cause.

**Troubleshooting flow:**

```bash
# Step 1 — What is the system-wide load?
uptime
```
**Why first:** Load average gives an immediate signal. If it is above the CPU count (4 on devopsmachine), the system is overloaded. If it is normal, the slowness may be network or disk, not CPU.

```bash
# Step 2 — What is consuming CPU right now?
ps aux --sort=-%cpu | head -10
```
**Why:** Sorted by CPU descending. The top offender is the first row. Note the PID, USER, and COMMAND.

```bash
# Step 3 — Real-time view with context
top
# Press P to sort by CPU
# Press M to sort by memory
# Press q to quit
```
**Why:** `ps aux` is a snapshot. `top` is live — I can watch if the CPU usage is a spike or sustained. Sustained high CPU from a single process = investigate that process. Short spikes = likely a cron job or batch task.

```bash
# Step 4 — What exactly is the high-CPU process doing?
ls -l /proc/<PID>/exe           # what binary is it?
cat /proc/<PID>/cmdline | tr '\0' ' '   # full command with arguments
```
**Why:** Sometimes `ps` shows only a short command name. The `/proc/<PID>/` directory shows the full picture — exactly what binary, what arguments, what files it has open.

```bash
# Step 5 — If it is a runaway background job, reduce its priority
sudo renice 15 -p <PID>
```
**Why:** `renice` to a high nice value gives CPU back to production services without killing the process. The job completes — just slower.

```bash
# Step 6 — If the process is genuinely stuck or malicious, kill it
kill <PID>           # graceful — SIGTERM
kill -9 <PID>        # force — SIGKILL, use only if kill fails
```

---

### Scenario 3: Finding Logs for a systemd Service

**Situation:** A developer asks where the logs for the `docker` service are.

**Answer and demonstration:**

For any service managed by systemd, logs are written to the **systemd journal** — not to a file in `/var/log` directly. The command to access them is `journalctl`.

```bash
# Step 1 — Check service status (includes last few log lines)
systemctl status docker
```

```bash
# Step 2 — Read last 50 lines of service logs
journalctl -u docker -n 50
```
**Flag breakdown:**
- `-u docker` — filter by unit name `docker`
- `-n 50` — show last 50 lines only

```bash
# Step 3 — Scope to a time window (incident investigation)
journalctl -u docker --since "2 hours ago"
journalctl -u docker --since "2026-05-23 10:00" --until "2026-05-23 11:00"
```
**Why time scoping:** In a production incident, I need logs from a specific window — not the entire history. Time-scoped queries reduce noise immediately.

```bash
# Step 4 — Follow logs in real time (during a change or deployment)
journalctl -u docker -f
# Ctrl+C to stop
```
**Why `-f`:** Same as `tail -f` but for systemd services. Run this in one terminal while making a change in another — watch the service react in real time.

```bash
# Step 5 — Show only error-level entries for the service
journalctl -u docker -p err -n 30
```

```bash
# Step 6 — Where does journald store its data?
ls /var/log/journal/
# Binary files — not human readable directly. Always access via journalctl.
```

---

### Scenario 4: Script Not Executing — Permission Denied

**Situation:** `/home/ameerul/backup.sh` throws `Permission denied` when executed.

**Troubleshooting flow:**

```bash
# Step 1 — Check current permissions
ls -l /home/ameerul/backup.sh
```
**Expected output showing the problem:**
```
-rw-r--r-- 1 ameerul ameerul 512 May 23 backup.sh
```
The permission string `-rw-r--r--` has no `x` (execute) bit anywhere. That is why it cannot run.

**Understanding permission notation:**

```
-  rw-  r--  r--
|   |    |    |
|   |    |    └── other: read only
|   |    └─────── group: read only
|   └──────────── owner: read + write
└──────────────── file type (- = regular file)
```

To run a script, the executing user needs `x` on their permission column.

```bash
# Step 2 — Add execute permission
chmod +x /home/ameerul/backup.sh
```

**`chmod` breakdown:**
- `chmod` = change file mode bits
- `+x` = add execute permission for owner, group, and others
- More precise: `chmod u+x` = only owner, `chmod 755` = owner rwx, group and others rx

```bash
# Step 3 — Verify the fix
ls -l /home/ameerul/backup.sh
```
**Expected output after fix:**
```
-rwxr-xr-x 1 ameerul ameerul 512 May 23 backup.sh
```
Now `x` appears in all three columns — owner, group, other can all execute.

```bash
# Step 4 — Run the script
./backup.sh
# or
bash /home/ameerul/backup.sh
```

**Why `./` is required:** Without `./`, the shell looks for `backup.sh` in directories listed in `$PATH`. Your home directory is not in `$PATH` by design — a security measure. `./` explicitly tells the shell "run this file from the current directory."

```bash
# Step 5 — If still permission denied after chmod — check ownership
ls -l /home/ameerul/backup.sh
# If owned by root and you are ameerul, you need sudo or chown

# Fix ownership
sudo chown ameerul:ameerul /home/ameerul/backup.sh
```

---

## Filesystem Quick Reference

```bash
# Where is a specific binary?
which nginx
which docker

# What directory does a process use as working dir?
ls -l /proc/<PID>/cwd

# Find a config file by name
find /etc -name "nginx.conf"

# Find all log files over 100MB
find /var/log -name "*.log" -size +100M

# Check what is in a directory without entering it
ls -lh /etc/nginx/

# Read a config file safely (no accidental edits)
cat /etc/ssh/sshd_config
```

---

*Day 07 | Fri 23 May 2026 | #90DaysOfDevOps 2026*
