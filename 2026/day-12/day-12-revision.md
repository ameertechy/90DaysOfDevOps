# Breather and Revision: Days 01–11
*#90DaysOfDevOps 2026*

---

## Day 01 Mindset Check — Goals Still Valid?

Original goals from Day 01:
- Deploy a production-grade application on Kubernetes
- Build complete CI/CD pipelines
- Become job-ready for DevOps and SRE roles in UAE and international markets

**Assessment:** Goals unchanged. The Linux fundamentals covered in Days 01–11 are exactly the foundation these goals require. Every Kubernetes node runs Linux. Every CI/CD pipeline executes shell commands. Every cloud server requires the exact permission and ownership knowledge I built this week.

One addition: I now understand that my 7+ years of infrastructure experience is not starting from zero — it is a translation exercise. The concepts are the same. The tooling is different.

---

## Self-Check Answers

### 1. Which 3 commands save me the most time right now, and why?

**`journalctl -u <service> --since "1 hour ago"`**
Scopes log investigation to a time window immediately. Without this I would be scrolling through thousands of lines manually. This single command replaced what used to take me 10 minutes in Zabbix.

**`ps aux --sort=-%cpu | head -10`**
Instant CPU triage. When a server alert fires, this tells me the offender within 5 seconds. No GUI, no dashboard — just the terminal answer.

**`sudo ss -tulpn`**
Port ownership verification. After any service deployment I run this to confirm the service bound to the expected port and no unexpected port is open. Catches misconfigurations before they become incidents.

---

### 2. How do I check if a service is healthy? Exact commands:

```bash
# Step 1 — What is the current state?
systemctl status <service>
# Active/inactive, last start time, main PID, recent log tail

# Step 2 — Full recent logs scoped to time
journalctl -u <service> --since "30 min ago"

# Step 3 — Is it listening on the expected port?
sudo ss -tulpn | grep :<port>
```

Three commands. Under 60 seconds. This sequence handles 80% of service health questions.

---

### 3. How do I safely change ownership and permissions without breaking access?

**Rule:** Always check before changing. Never assume.

```bash
# Step 1 — Read current state
ls -ld /opt/myapp/
ls -lR /opt/myapp/ | head -20

# Step 2 — Change ownership correctly
sudo chown -R appuser:appgroup /opt/myapp/

# Step 3 — Set permissions — directories and files separately
sudo find /opt/myapp -type d -exec chmod 755 {} \;
sudo find /opt/myapp -type f -exec chmod 644 {} \;

# Step 4 — If scripts need execute
sudo chmod 755 /opt/myapp/scripts/*.sh

# Step 5 — Verify
ls -lR /opt/myapp/
```

The critical rule: **never use `chmod -R 755` on a mixed directory**. It sets execute on files which is wrong and a security risk. Use `find` with `-type d` and `-type f` separately.

---

### 4. What will I focus on improving in the next 3 days?

**`find` command fluency** — Days 13 onwards involve more complex file operations. `find` with `-exec`, `-type`, `-mtime`, `-perm` combinations needs to be automatic.

**`vim` navigation speed** — Every production server has `vim`. I can use it but I am still slow. Will practice navigation: `gg` (top of file), `G` (bottom), `/search` (find text), `:%s/old/new/g` (find and replace).

**Connecting the permission model to Docker** — Day 29 is Docker. Container processes run as specific UIDs. Understanding how host file ownership maps to container access is the bridge I need to build now before Docker week.

---

## Quick Hands-On Re-Runs

### Process Check

```bash
# Current system state
uptime && free -h

# Top consumers
ps aux --sort=-%cpu | head -5
ps aux --sort=-%mem | head -5

# Any failed services?
systemctl list-units --state=failed
```

### Service Health Check (Nginx on EC2)

```bash
systemctl status nginx
sudo ss -tulpn | grep :80
curl -I http://localhost
journalctl -u nginx --since "1 hour ago" | tail -10
```

### File Operations Quick Drill

```bash
# Create, write, append, read
mkdir -p ~/devops/day12 && cd ~/devops/day12
echo "Day 12 revision" > revision.txt
echo "Commands reviewed: ps, ss, journalctl, chmod, chown" >> revision.txt
cat -n revision.txt

# Permissions
chmod 640 revision.txt
ls -l revision.txt
stat revision.txt | grep Access

# Ownership
sudo chown ubuntu:ubuntu revision.txt
ls -l revision.txt
```

### User and Group Sanity Check

```bash
# Who am I and what groups do I belong to?
id

# Does the ubuntu user have sudo?
sudo -l | grep -i "all\|NOPASSWD"

# Quick user creation and verify
sudo useradd -m testrevision 2>/dev/null || true
id testrevision
grep testrevision /etc/passwd
sudo userdel -r testrevision
```

---

## Commands I Would Reach For First in Any Incident

These 5 from the Day 03 cheat sheet are my immediate reflex:

| Command | Why First |
|---------|-----------|
| `uptime` | Load average in 2 seconds — is the system overloaded? |
| `systemctl list-units --state=failed` | Are any services down? |
| `journalctl -p err --since "1 hour ago"` | Any system errors in the incident window? |
| `df -h` | Is disk full? Most common silent killer |
| `sudo ss -tulpn` | What is listening and what process owns it? |

These five answer the most common production questions before any deeper investigation begins.

---

## Key Takeaways From Days 01–11

**Linux is consistent.** The same commands that check Nginx also check Docker, SSH, any systemd service. Learn the pattern once — apply it everywhere.

**Ownership + permissions = access control.** They are not the same thing and both must be correct. A file with perfect permissions but wrong ownership is still broken.

**`-a` in `usermod -aG` is not optional.** Without append, you silently remove existing group memberships. Muscle memory must include the `-a`.

**`sudo tee` not `sudo echo >`**. The shell opens the file redirect before sudo runs. `tee` is where the elevated privilege must sit.

**`find -type d` and `find -type f` separately.** Never `chmod -R` a mixed directory. Directories need execute to be traversable. Files should not have execute unless they are scripts.

---

*#90DaysOfDevOps 2026*
