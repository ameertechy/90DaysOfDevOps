# Linux Commands Cheat Sheet
*Structured for production triage speed — not classroom reference.*

---

## 1. Process Management

| Command | Usage | What to Look For |
|---------|-------|-----------------|
| `ps aux` | All running processes with CPU/MEM % | Zombie (Z) states, unexpected high-CPU PIDs |
| `ps aux --sort=-%cpu \| head -10` | Top 10 CPU consumers | Any process above 80% unexpectedly |
| `ps aux --sort=-%mem \| head -10` | Top 10 memory consumers | Memory leak candidates |
| `top` | Real-time process monitor | Load average > CPU count = overloaded |
| `htop` | Interactive top (`apt install htop`) | Easier multi-core CPU view |
| `pgrep -a <name>` | Find PID of named process | Verify process is running before log checks |
| `kill -9 <PID>` | Force kill a stuck process | Use only after `kill <PID>` fails |
| `renice -n 5 -p <PID>` | Adjust priority of running process | De-prioritize runaway background tasks |

```bash
# What is consuming the most CPU right now?
ps aux --sort=-%cpu | head -5

# Is Docker running?
pgrep -a dockerd
```

---

## 2. Filesystem and Disk Operations

| Command | Usage | What to Look For |
|---------|-------|-----------------|
| `df -h` | Disk usage per mounted filesystem | Any partition above 85% — act before 95% |
| `du -sh /var/log` | Size of a specific directory | Log directories growing unexpectedly |
| `du -sh /* 2>/dev/null \| sort -rh \| head -10` | Top 10 largest directories from root | Identify what is filling disk fast |
| `ls -lh` | List files with human-readable sizes | Spot unexpectedly large files |
| `ls -lt \| head -10` | Files sorted by modification time | Most recently changed files first |
| `find /var/log -name "*.log" -size +100M` | Find large log files | Candidates for rotation |
| `find / -mmin -60 2>/dev/null` | Files modified in last 60 minutes | Post-change audit or incident forensics |
| `lsof \| grep deleted` | Open file handles marked deleted | Disk space not released despite deletion |
| `stat <file>` | File metadata — owner, permissions, modified | Detect unauthorized changes |

```bash
# Disk full alert — where is the space?
df -h
du -sh /* 2>/dev/null | sort -rh | head -10

# LVM-specific: check logical volume usage
sudo lvdisplay
sudo vgdisplay
```

---

## 3. System Resource Monitoring

| Command | Usage | What to Look For |
|---------|-------|-----------------|
| `free -h` | RAM and swap usage | Swap usage above 0 = memory pressure |
| `vmstat 2 5` | CPU, memory, I/O every 2s (5 iterations) | `wa` above 20% = disk bottleneck |
| `iostat -xz 2 3` | Per-disk I/O stats | `%util` near 100% = disk saturation |
| `uptime` | Load averages: 1, 5, 15 min | Load > CPU count = system under pressure |
| `lscpu` | CPU core count and architecture | Baseline for load average interpretation |
| `uname -r` | Kernel version | Required for kernel-specific troubleshooting |
| `cat /proc/meminfo` | Detailed memory breakdown | `MemAvailable` is the real usable number |

```bash
# Fast system health snapshot
uptime && free -h && df -h

# CPU and I/O health
vmstat 2 5
```

---

## 4. Service and systemd Management

| Command | Usage | What to Look For |
|---------|-------|-----------------|
| `systemctl status <service>` | Service health + last log lines | Active/inactive, failed states |
| `systemctl list-units --state=failed` | All failed units | Run this first during any incident |
| `systemctl restart <service>` | Restart a service | Check status before and after |
| `systemctl enable <service>` | Enable on boot | Post-deployment checklist item |
| `systemctl disable <service>` | Disable on boot | Decommission or security hardening |
| `systemctl daemon-reload` | Reload systemd config | Required after editing any `.service` file |
| `journalctl -u <service> -n 100` | Last 100 log lines for a service | Errors, port conflicts, crash loops |
| `journalctl -u <service> --since "1 hour ago"` | Logs scoped to time window | Incident time-window investigation |
| `journalctl -p err -n 50` | Last 50 error-level entries system-wide | Fast error sweep across all services |

```bash
# First commands at start of any service incident
systemctl list-units --state=failed
journalctl -p err -n 50

# Docker service check
systemctl status docker
journalctl -u docker --since "1 hour ago"
```

---

## 5. Network Troubleshooting

| Command | Usage | What to Look For |
|---------|-------|-----------------|
| `ip a` | All interfaces and IP assignments | Correct IP on correct interface |
| `ip r` | Routing table | Default route present and correct gateway |
| `ss -tulpn` | Active listening ports with process names | Unexpected open ports; verify app binding |
| `ping -c 4 8.8.8.8` | External connectivity test | Packet loss, RTT spikes |
| `traceroute 8.8.8.8` | Trace path to destination | Where latency or drops occur |
| `dig google.com` | DNS resolution test | Confirms DNS is functional |
| `dig @8.8.8.8 google.com` | DNS query against specific resolver | Bypass local cache for comparison |
| `curl -I https://example.com` | HTTP header check | Status code, redirect chains |
| `curl -v -o /dev/null https://example.com` | Verbose HTTP — TLS and timing | TLS handshake issues, slow TTFB |
| `nslookup <hostname>` | Quick DNS lookup | Verify internal hostname resolves |

```bash
# Is Docker listening on expected port?
ss -tulpn | grep :2376

# DNS and connectivity check
dig google.com && ping -c 4 8.8.8.8

# Service reachable?
curl -I http://localhost
```

---

## 6. Log Analysis

| Command | Usage | What to Look For |
|---------|-------|-----------------|
| `tail -f /var/log/syslog` | Live log stream | Real-time incident monitoring |
| `tail -n 100 /var/log/auth.log` | Last 100 auth entries | SSH brute-force attempts |
| `grep -i "error" /var/log/syslog \| tail -20` | Recent errors in syslog | Service failures, kernel errors |
| `grep -i "failed" /var/log/auth.log` | Failed login attempts | Security audit |
| `zcat /var/log/syslog.1.gz \| grep "error"` | Search compressed rotated logs | Historical incident investigation |
| `awk '/May 19/{print}' /var/log/syslog` | Filter logs by date string | Time-scoped incident review |

```bash
# Live monitoring during a change
tail -f /var/log/syslog

# SSH brute-force check
grep -i "failed" /var/log/auth.log | tail -20
```

---

## Production Triage Sequence

```bash
# Step 1 — System pulse
uptime && free -h && df -h

# Step 2 — Any failed services?
systemctl list-units --state=failed

# Step 3 — Recent system errors
journalctl -p err -n 50

# Step 4 — Resource consumers
ps aux --sort=-%cpu | head -5
ps aux --sort=-%mem | head -5

# Step 5 — Network sanity
ip a && ss -tulpn

# Step 6 — Service-specific logs
journalctl -u <service> --since "30 min ago"
```

---

*Day 03 | #90DaysOfDevOps 2026*
