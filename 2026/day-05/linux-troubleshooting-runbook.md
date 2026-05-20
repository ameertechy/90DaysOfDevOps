# Linux Troubleshooting Runbook
*Day 05 | Wed 21 May 2026 | #90DaysOfDevOps 2026*

---

**Target Services:** Nginx (web server) | Docker (container engine)
**Kernel:** `6.8.0-111-generic` x86_64
**OS:** Ubuntu 24.04.4 LTS (Noble Numbat)

---

## Step 1 — Environment Baseline

```bash
uname -a
```

**Observed output:**
```
Linux devopsmachine 6.8.0-111-generic #111-Ubuntu SMP PREEMPT_DYNAMIC
Sat Apr 11 23:16:02 UTC 2026 x86_64 x86_64 x86_64 GNU/Linux
```

**What this tells you:**
- Kernel `6.8.0` — current LTS kernel for Ubuntu 24.04
- `x86_64` — 64-bit architecture
- `PREEMPT_DYNAMIC` — kernel supports dynamic preemption, better for low-latency workloads
- `SMP` — Symmetric Multi-Processing enabled — multiple CPU cores active

```bash
cat /etc/os-release
```

**Observed:** Ubuntu 24.04.4 LTS, codename Noble Numbat. Confirmed.

---

## Step 2 — CPU and Memory Snapshot

```bash
uptime
```

**Observed output:**
```
19:17:39 up 1 day, 20:28,  2 users,  load average: 0.00, 0.00, 0.00
```

**How to read load average:**
Three numbers represent CPU queue depth over the last 1 minute, 5 minutes, and 15 minutes.
This VM has **4 CPU cores**. Load average below 4.0 = healthy. All three values at `0.00` = completely idle — no process is competing for CPU.

```bash
free -h
```

**Observed output:**
```
              total        used        free      shared  buff/cache   available
Mem:           3.9Gi       583Mi       2.5Gi       3.5Mi       1.1Gi       3.3Gi
Swap:          3.8Gi        35Mi       3.8Gi
```

**Analysis:**

| Metric | Value | Assessment |
|--------|-------|------------|
| Available RAM | 3.3Gi | Healthy — 85% of total free |
| Swap used | 35Mi | Minimal — no memory pressure |
| buff/cache | 1.1Gi | Kernel using RAM for disk caching — normal and beneficial |

**Critical rule:** Never alarm on `free` being low. Always read `available`. The kernel intentionally uses free RAM as disk cache — it releases it instantly when a process needs it.

```bash
ps aux --sort=-%cpu | head -8
```

**Observed top CPU consumers:**
```
containerd   0.1% CPU
dockerd      0.0% CPU
sshd         0.0% CPU
```

System is idle. No process above 0.1% CPU. Baseline confirmed.

```bash
ps aux --sort=-%mem | head -8
```

**Observed top memory consumers:**
```
dockerd      2.0% MEM (84MB VSZ)
containerd   1.1% MEM
multipathd   0.6% MEM
```

Docker daemon is the largest memory consumer at 2%. Expected and normal for a running container engine.

---

## Step 3 — Disk and I/O Snapshot

```bash
df -h
```

**Observed output:**
```
Filesystem                         Size  Used Avail Use% Mounted on
/dev/mapper/ubuntu--vg-ubuntu--lv   23G  7.4G   15G  34% /
/dev/sda2                          2.0G  201M  1.6G  11% /boot
/dev/sda1                          1.1G  6.2M  1.1G   1% /boot/efi
```

**Assessment:** Root at 34% — healthy. No action required until above 85%.

```bash
du -sh /var/log
```

**Observed:** `139M` — normal for a system running 1+ days with Nginx and Docker.

```bash
du -sh /var/log/* | sort -rh | head -10
```

**Observed top log consumers:**
```
134M    /var/log/journal
1.3M    /var/log/installer
1.2M    /var/log/sysstat
772K    /var/log/syslog.1
304K    /var/log/syslog.3.gz
152K    /var/log/syslog
```

`/var/log/journal` at 134M is the systemd journal — expected. It stores all service logs including Docker and Nginx.

```bash
vmstat 2 3
```

**Observed output:**
```
r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy  id  wa
0  0  36020 2614588 35880 1110032   0    0    30    48   73    0  1 98   0   0
0  0  36020 2614588 35880 1110072   0    0     0   158  145   1  0 100   0   0
0  0  36020 2614588 35880 1110072   0    0     0     8  158   99  0 100   0   0
```

**Key readings:**

| Column | Value | Assessment |
|--------|-------|------------|
| `r` | 0 | No processes waiting for CPU |
| `b` | 0 | No processes blocked on I/O |
| `wa` | 0 | Zero I/O wait — disk is not a bottleneck |
| `si` / `so` | 0 / 0 | No swap activity — memory is sufficient |
| `id` | 98–100 | CPU idle 98–100% — system completely idle |

**Conclusion:** Disk I/O can be eliminated as a performance factor on this system.

---

## Step 4 — Network Snapshot

```bash
sudo ss -tulpn
```

**Observed output (key entries):**
```
tcp  LISTEN  0:80    nginx pid=29454, pid=29453, pid=29450
tcp  LISTEN  0:22    sshd  pid=10315
udp  UNCONN  127.0.0.53:53   systemd-resolve pid=4697
tcp  LISTEN  127.0.0.53:53   systemd-resolve pid=4697
tcp  LISTEN  0:123           (NTP service)
```

**Important:** Running without `sudo` hides the Process column entirely. Always use `sudo ss -tulpn` for complete output.

**Port `:123`** is NTP (Network Time Protocol) — chrony or systemd-timesyncd keeping system clock synchronized. Expected on Ubuntu 24.04.

```bash
curl -I http://localhost
```

**Observed output:**
```
HTTP/1.1 200 OK
Server: nginx/1.24.0 (Ubuntu)
Date: Wed, 20 May 2026 19:59:49 GMT
Content-Type: text/html
Content-Length: 615
```

Nginx serving correctly. Status `200 OK`. Running version `1.24.0`.

```bash
ping -c 5 8.8.8.8
```

**Observed:** 5 packets transmitted, 5 received, **0% packet loss**, avg RTT `19.6ms`. External connectivity confirmed.

```bash
dig google.com +short
```

**Observed:** `142.250.187.78` — DNS resolving correctly via systemd-resolved.

---

## Step 5 — Service Health: Nginx

```bash
systemctl status nginx
```

**Observed:**
```
Active: active (running) since Tue 2026-05-19 22:07:52 UTC; 22h ago
Main PID: 29450 (nginx)
Tasks: 3 (master + 2 workers)
Memory: 2.4M (peak: 5.3M)
CPU: 18ms
```

**Process model explained:**
Nginx runs as one **master process** (PID 29450) and two **worker processes** (PIDs 29453, 29454). The master manages configuration and restarts workers. Workers handle actual HTTP connections. This is Nginx's multi-process architecture for handling concurrent requests.

```bash
journalctl -u nginx -n 50
```

**Observed:** Clean startup logs. No errors.

```bash
sudo tail -n 30 /var/log/nginx/access.log
```

**Observed:**
```
192.168.100.1 - - [20/May/2026:19:59:49 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/8.5.0"
```

Only one entry — the `curl -I` test from Step 4. Clean log.

```bash
sudo tail -n 30 /var/log/nginx/error.log
```

**Observed:**
```
2026/05/19 22:07:52 [notice] 29450#29450: using inherited sockets from "5;6;"
```

`[notice]` level — informational only, not an error. This message means Nginx inherited socket file descriptors from systemd during startup (socket activation). Expected and normal.

---

## Step 6 — Service Health: Docker

```bash
systemctl status docker
```

**Observed:**
```
Active: active (running) since Mon 2026-05-18 22:21:00 UTC; 1 day 22h ago
Main PID: 26788 (dockerd)
Memory: 29.3M (peak: 29.8M)
CPU: 4.826s
```

Running for nearly 2 days. Memory stable. No restarts.

```bash
journalctl -u docker -n 50
```

**Observed — nftables errors on startup:**
```
Error: Could not process rule: No such file or directory\ndelete table ip do...
```

**What this means:** Docker attempts to clean up nftables firewall rules from a previous run on startup. On a fresh install with kernel 6.8 + Ubuntu 24.04, these rules do not exist yet — so the delete command fails harmlessly. The service initializes correctly regardless. Confirmed by the final log line: `API listen on /run/docker.sock`.

**This is a known behaviour — not an actionable error.**

```bash
docker ps
```

**Observed:** No running containers. Headers only. Expected — no containers deployed yet.

```bash
docker system df
```

**Observed:**
```
TYPE            TOTAL   ACTIVE   SIZE      RECLAIMABLE
Images              0        0      0B              0B
Containers          0        0      0B              0B
Local Volumes       0        0      0B              0B
Build Cache         0        0      0B              0B
```

Clean slate. Nothing to reclaim.

---

## Step 7 — Log Review: System-Wide

```bash
journalctl -p err --since "1 hour ago"
```

**Observed:** `-- No entries --`

Zero system errors in the last hour. System is clean.

```bash
sudo grep -i "failed\|invalid" /var/log/auth.log | tail -20
```

**Observed:**
```
2026-05-17T09:36:21 sshd[24111]: Failed password for ameerul from 192.168.100.1 port 64866 ssh2
2026-05-17T09:36:33 sshd[24111]: Failed password for ameerul from 192.168.100.1 port 64866 ssh2
2026-05-18T23:43:11 sshd[25249]: Failed password for root from 192.168.100.1 port 57393 ssh2
```

**Analysis:** Three failed SSH attempts, all from `192.168.100.1` — the Hyper-V host IP (My Windows machine). These are own failed login attempts during initial setup — not external threats. Source IP context is what separates operator activity from a real security event.

---

## Quick Findings Summary

| Check | Status | Notes |
|-------|--------|-------|
| System load | ✅ Healthy | Load avg 0.00 — completely idle |
| Available memory | ✅ Healthy | 3.3Gi available of 3.9Gi total |
| Root disk usage | ✅ Healthy | 34% used |
| Nginx service | ✅ Running | PID 29450, 2 workers, HTTP 200 OK |
| Docker service | ✅ Running | PID 26788, 0 containers, clean |
| Open ports | ✅ Expected | :80 nginx, :22 sshd, :53 DNS |
| System errors (last 1h) | ✅ Clean | No entries |
| Auth failures | ℹ️ Own activity | 3 failures from Hyper-V host IP |

---

## If This Worsens — Escalation Paths

### Scenario A: Nginx returns 502 Bad Gateway

```bash
# 1. Check for failed units
systemctl list-units --state=failed

# 2. Check Nginx error log for upstream connection details
sudo tail -n 50 /var/log/nginx/error.log | grep "upstream"

# 3. Check if app port is actually bound
sudo ss -tulpn | grep :<app_port>

# 4. Restart only after confirming upstream is healthy
sudo systemctl restart nginx && systemctl status nginx
```

### Scenario B: Memory pressure (available < 200Mi)

```bash
# 1. Find the memory consumer
ps aux --sort=-%mem | head -10

# 2. Confirm swap pressure
free -h && vmstat 1 5

# 3. Check for OOM events
journalctl -p err --since "1 hour ago" | grep -i "oom\|killed"

# 4. Docker container memory check
docker stats --no-stream
```

### Scenario C: Disk above 90% on root partition

```bash
# 1. Find top space consumers
du -sh /* 2>/dev/null | sort -rh | head -10

# 2. Break down log directory
du -sh /var/log/* | sort -rh | head -10

# 3. Find files over 500MB
find / -size +500M -type f 2>/dev/null

# 4. Clean Docker (images + stopped containers)
docker system prune -f

# 5. Force log rotation
sudo logrotate -f /etc/logrotate.conf
```

---

*Day 05 | Wed 21 May 2026 | #90DaysOfDevOps 2026*
