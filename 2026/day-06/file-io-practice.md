# File I/O Practice Log
*Day 06 | Thu 22 May 2026 | #90DaysOfDevOps 2026*

---

## Command Reference: What Each Tool Does and Why

### `touch`

**What it stands for:** Originally "touch" — to update file timestamps.

**What it does:**
- If the file does not exist → creates an empty file
- If the file already exists → updates its `atime` (last accessed) and `mtime` (last modified) without changing content

**Without arguments:** `touch` with no filename gives an error — it needs a target.

```bash
touch notes.txt
```

This creates an empty `notes.txt`. Size is 0 bytes. No content yet.

```bash
# Verify it was created
ls -lh notes.txt
# Output: -rw-rw-r-- 1 ameerul ameerul 0 May 22 notes.txt
# The 0 confirms it is empty
```

**Production use:** Deployment scripts use `touch` to create lock files — a file whose existence signals "this process is running." If the lock file exists, the second instance of the script exits immediately.

---

### `echo` with `>` — Write (Overwrite)

**What `echo` does:** Prints text to standard output (your terminal screen by default).

**What `>` does:** Redirects that output away from the screen and into a file. If the file exists, it is completely overwritten. If it does not exist, it is created.

```bash
echo "Day 06 - File I/O Practice" > notes.txt
```

**What happened:** The string was redirected into `notes.txt`. Previous content (empty) replaced with this line.

```bash
echo "Learning: touch, cat, head, tail, tee" > notes.txt
# WARNING: This replaces the previous line entirely
```

**The danger of `>` in production:**
```bash
# This destroys your entire Nginx config in one command
echo "test" > /etc/nginx/nginx.conf   # DO NOT RUN — illustration only
```

This is why production runbooks say: always `cat` the file before editing, always use `>>` for appending to existing files, always take a backup before any redirection to a config file.

---

### `echo` with `>>` — Append

**What `>>` does:** Redirects output to a file but adds to the end — existing content is preserved.

```bash
echo "Day 06 - File I/O Practice" > notes.txt
echo "Command: touch — creates empty files or updates timestamps" >> notes.txt
echo "Command: cat — reads and displays full file content" >> notes.txt
echo "Command: head — reads first N lines of a file" >> notes.txt
echo "Command: tail — reads last N lines of a file" >> notes.txt
echo "Command: tee — writes to file AND displays on screen simultaneously" >> notes.txt
echo "Operator: > overwrites | >> appends" >> notes.txt
echo "Real use: tail -f for live log monitoring during deployments" >> notes.txt
```

After running all these, `notes.txt` has 8 lines. The first `>` created the file with line 1. Every `>>` after added to it.

---

### `cat` — Read Full File

**What it stands for:** Concatenate.

**What it does:** Reads one or more files and outputs their content to the terminal. The name comes from its original purpose — concatenating multiple files together.

```bash
# Read a single file
cat notes.txt
```

**Without arguments:** `cat` with no file reads from keyboard input until you press `Ctrl+D`. Not useful interactively but used in scripts with pipes.

```bash
# Concatenate two files and view together
cat notes.txt notes2.txt

# Concatenate and save into a third file
cat notes.txt notes2.txt > combined.txt

# Show line numbers
cat -n notes.txt
```

**Production use:** `cat /etc/nginx/nginx.conf` — read config before editing. `cat /proc/meminfo` — read kernel memory stats directly from the virtual filesystem.

---

### `head` — Read First N Lines

**What it does:** Outputs the first N lines of a file. Default is 10 lines if no `-n` flag given.

```bash
# Default — first 10 lines
head notes.txt

# First 2 lines only
head -n 2 notes.txt
```

**Flag breakdown:**
- `-n` stands for **number** — specifies how many lines to show
- Without `-n`: defaults to 10

**Without `head`:** You would have to use `cat` and read the entire file even if you only need the top.

**Production use:**
```bash
# Read only the first line of a CSV to get column headers
head -n 1 /var/log/report.csv

# Check the top of a config file to see version or timestamp comment
head -n 5 /etc/nginx/nginx.conf
```

---

### `tail` — Read Last N Lines

**What it does:** Outputs the last N lines of a file. Default is 10 lines.

```bash
# Default — last 10 lines
tail notes.txt

# Last 3 lines only
tail -n 3 notes.txt

# Live streaming — follow file as it grows (most important use)
tail -f notes.txt
```

**Flag breakdown:**
- `-n` — number of lines to show
- `-f` — **follow** — keeps the file open and streams new lines as they are written. `Ctrl+C` to stop.

**`tail -f` is one of the most used commands in production:**
```bash
# Watch Nginx access log live during a deployment
tail -f /var/log/nginx/access.log

# Watch Docker logs live
docker logs -f <container_name>

# Watch system log live
tail -f /var/log/syslog
```

---

### `tee` — Write and Display Simultaneously

**What it stands for:** Named after a T-shaped pipe fitting — it splits output in two directions at once.

**What it does:** Reads from standard input and writes to both the terminal screen AND a file at the same time.

```bash
# Write line 3 using tee — displays on screen AND saves to file
echo "Command: tee — splits output to screen and file simultaneously" | tee -a notes.txt
```

**Flag breakdown:**
- Without `-a`: `tee` overwrites the file (same behaviour as `>`)
- `-a` — **append** — adds to the file without overwriting (same behaviour as `>>`)

**Without `tee`:** You can either display output OR redirect to a file — not both at once.

```bash
# Overwrite file and display
echo "new content" | tee notes.txt

# Append to file and display
echo "additional line" | tee -a notes.txt

# Write to multiple files simultaneously
echo "broadcast" | tee file1.txt file2.txt file3.txt
```

**Production use:**
```bash
# Deployment script — log output AND see it on screen
./deploy.sh | tee -a /var/log/deploy.log

# Write a config line with sudo permissions (echo alone cannot sudo into a file)
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
# This is the correct way — sudo applies to tee, not echo
```

---

## Full Practice Session: Command Sequence

```bash
# 1. Create the file
touch notes.txt
ls -lh notes.txt            # confirm 0 bytes

# 2. Write first line (overwrite/create)
echo "Day 06 - File I/O Practice" > notes.txt

# 3. Append remaining lines
echo "Command: touch — creates empty files or updates timestamps" >> notes.txt
echo "Command: cat — reads and displays full file content" >> notes.txt
echo "Command: head — reads first N lines of a file" >> notes.txt
echo "Command: tail — reads last N lines of a file" >> notes.txt
echo "Command: tee — writes to file AND displays on screen simultaneously" >> notes.txt
echo "Operator: > overwrites | >> appends" >> notes.txt
echo "Real use: tail -f for live log monitoring during deployments" >> notes.txt

# 4. Read the full file
cat notes.txt

# 5. Read first 2 lines
head -n 2 notes.txt

# 6. Read last 2 lines
tail -n 2 notes.txt

# 7. Append using tee (displays on screen AND writes)
echo "Completed: Day 06 hands-on | 22 May 2026" | tee -a notes.txt

# 8. Verify final file — show with line numbers
cat -n notes.txt
```

---

## Bonus: Why `echo "text" | sudo tee file` Instead of `sudo echo "text" > file`

This is a common mistake that confuses many engineers:

```bash
# This FAILS even with sudo
sudo echo "vm.swappiness=10" > /etc/sysctl.conf
# The shell opens /etc/sysctl.conf with YOUR permissions before sudo runs echo
# Result: Permission denied

# This WORKS correctly
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
# echo runs as you (just printing text — no permission needed)
# sudo applies to tee, which opens and writes to the file as root
```

This pattern is used constantly in production Linux administration and automation scripts.

---

*Day 06 | Thu 22 May 2026 | #90DaysOfDevOps 2026*
