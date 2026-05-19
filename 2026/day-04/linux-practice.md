# Linux Practice Log – Processes, Services, and Shell Operators
*Day 04 | #90DaysOfDevOps 2026*

---

## Section 1 – Process Inspection

### 1.1 What `ps` does alone vs with `aux`

```bash
# ps alone — shows only processes in current terminal session
ps
```

Output shows: PID, TTY, TIME, CMD — only bash and ps itself. Useless for production triage.

```bash
# ps aux — shows ALL processes on the system
ps aux | head
```

**Flag breakdown:**
- `a` — show processes from all users, not just current user
- `u` — user-oriented output format (shows USER, %CPU, %MEM, VSZ, RSS, STAT)
- `x` — include processes not attached to any terminal (background daemons — SSH, Docker, cron)

Key observation: PID 1 is `/usr/lib/systemd/systemd` — the init system. Every other process on the system is a child of PID 1.

---

### 1.2 Sort by CPU and Memory

```bash
# Top 10 CPU consumers
ps aux --sort=-%cpu | head

# Top 10 memory consumers
ps aux --sort=-%mem | head
```

**Why `--sort=-%cpu` and not `--sort=%cpu`:**
The `-` prefix sorts in descending order. Without `-`, lowest CPU appears first — not useful during a spike investigation.

---

### 1.3 Nice Value — Process Priority Management

Every process has a **nice value** — a priority score that tells the kernel how much CPU time to give it.

| Nice Value | Priority | Use Case |
|------------|----------|----------|
| -20 | Highest | Critical real-time processes |
| 0 | Default | Normal processes |
| +19 | Lowest | Background batch jobs |

**Lower number = higher priority. Higher number = lower priority.**

```bash
# Step 1 — Start a CPU-intensive background process
yes > /dev/null &
# Output: [1] 28863
# yes generates infinite "y" output. /dev/null discards it. & runs it in background.

# Step 2 — Find the PID
pgrep -a yes
# Output: 28863 yes

# Step 3 — Check current nice value
ps -o pid,user,ni,comm -p 28863
# Output: PID USER NI COMMAND / 28863 ameerul 0 yes

# Step 4 — Raise nice value to 18 (lower priority — give CPU back to system)
sudo renice 18 -p 28863
# Output: 28863 (process ID) old priority 0, new priority 18

# Step 5 — Confirm the change
ps -o pid,user,ni,comm -p 28863
# Output: PID USER NI COMMAND / 28863 ameerul 18 yes

# Step 6 — Kill the process
kill 28863
```

**Real-world use:** When a cron backup job or log rotation task spikes CPU during business hours, `renice` it to +15 or +19 rather than killing it. The job completes — just slower, without impacting production services.

---

## Section 2 – Service Inspection

### 2.1 Docker Service

```bash
systemctl status docker
```

Key fields to read in systemctl output:

| Field | What It Tells You |
|-------|------------------|
| `Active: active (running)` | Service is healthy |
| `since Mon 2026-05-18 22:21:00 UTC` | Last start time — how long it has been running |
| `Main PID: 26788 (dockerd)` | The actual process PID |
| `Memory: 29.3M` | Current memory consumption |
| `CGroup` | Which processes belong to this service unit |

```bash
# Inspect Docker logs
journalctl -u docker -n 50

# Docker logs scoped to last 1 hour
journalctl -u docker --since "1 hour ago"
```

---

### 2.2 SSH Service

```bash
systemctl status ssh

# Check for failed login attempts
journalctl -u ssh --since "today" | grep -i "failed\|invalid"

# Live log stream
tail -f /var/log/auth.log
```

---

### 2.3 List All Running Services

```bash
systemctl list-units --type=service --state=active
```

---

## Section 3 – Shell Operators Reference

Operators control how commands interact with each other and with the filesystem.

| # | Operator | Name | Behaviour |
|---|----------|------|-----------|
| 1 | `>` | Redirect / Overwrite | Sends output to file, replaces existing content |
| 2 | `>>` | Append | Adds output to file, preserves existing content |
| 3 | `\|` | Pipe | Passes output of first command as input to second |
| 4 | `&&` | AND | Runs second command only if first succeeds (exit code 0) |
| 5 | `&` | Background | Runs command in background, returns terminal immediately |
| 6 | `/` | Path Separator / Root | Separates directories in paths; alone means root `/` |
| 7 | `\` | Escape Character | Treats next character as literal text |
| 8 | `-` | Flag / Option | Adds options to commands: `df -h`, `ls -la` |
| 9 | `*` | Wildcard | Matches any characters: `ls *.txt` |
| 10 | `.` | Current Directory | Refers to current location: `./script.sh` |
| 11 | `..` | Parent Directory | Move one level up: `cd ..` |
| 12 | `~` | Home Directory | Shortcut to home: `cd ~` = `cd /home/ameerul` |
| 13 | `$` | Variable | Accesses stored value: `echo $HOME` |
| 14 | `#` | Comment | Linux ignores everything after `#` in scripts |
| 15 | `;` | Command Separator | Runs commands sequentially regardless of success or failure |

### Practical Examples

```bash
# > overwrite vs >> append
echo "Devops Journey begins" > muja.txt      # creates/overwrites file
echo "Devops Journey begins123" >> muja.txt  # appends new line
cat muja.txt

# | pipe — chain commands
ps aux | grep docker       # filter process list for docker
ps aux | grep ssh | head   # find SSH processes, show first few

# && AND — safe chaining
sudo apt update && sudo apt install -y nginx
# nginx install only runs if apt update succeeds

# & background
yes > /dev/null &   # runs in background, terminal available immediately

# \ escape — spaces in names
mkdir Ameerul\ Mujahidin   # creates ONE directory named "Ameerul Mujahidin"
# Without \: mkdir Ameerul Mujahidin creates TWO directories

# ; separator — run regardless
mkdir devops; cd devops    # cd runs even if mkdir fails (dir already exists)

# $ variable
echo $HOME     # outputs /home/ameerul
echo $USER     # outputs ameerul
```

---

## Section 4 – Mini Triage Flow

```bash
# Scenario: system feels slow, check what is happening

# Step 1 — How long has system been up, what is load?
uptime

# Step 2 — Any failed services?
systemctl list-units --state=failed

# Step 3 — What is consuming CPU?
ps aux --sort=-%cpu | head -5

# Step 4 — What is consuming memory?
ps aux --sort=-%mem | head -5

# Step 5 — Disk space okay?
df -h

# Step 6 — Recent system errors
journalctl -p err --since "1 hour ago"
```

---

*Day 04 | Tue 20 May 2026 | #90DaysOfDevOps 2026*
