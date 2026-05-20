# Day 05 – Linux Troubleshooting Drill: CPU, Memory, and Logs

## Overview

Day 5 shifts from learning commands to applying them under a structured framework.

The task: run a disciplined health check against live services, document actual observed output, and define the escalation path if conditions worsen. This is the foundation of every incident response runbook used in production.

Target services: **Nginx** and **Docker** — both running live on the lab VM.

---

## What I Produced

- [`linux-troubleshooting-runbook.md`](./linux-troubleshooting-runbook.md)

---

## Observed System State

| Check | Result | Status |
|-------|--------|--------|
| Kernel | `6.8.0-111-generic` x86_64 | ✅ |
| OS | Ubuntu 24.04.4 LTS (Noble Numbat) | ✅ |
| Uptime | 1 day, 20h — load average: 0.00, 0.00, 0.00 | ✅ Idle |
| Available memory | 3.3Gi of 3.9Gi | ✅ Healthy |
| Swap usage | 35Mi — minimal | ✅ No pressure |
| Root disk | 34% used (7.4G / 23G) | ✅ Healthy |
| `/var/log` size | 139M | ✅ Normal |
| I/O wait (`vmstat wa`) | 0 across all readings | ✅ No bottleneck |
| Nginx | active (running), PID 29450, 2 workers, 2.4M RAM | ✅ |
| Docker | active (running), PID 26788, 29.3M RAM, 0 containers | ✅ |
| Port `:80` | nginx confirmed | ✅ |
| Port `:22` | sshd confirmed | ✅ |
| HTTP response | `HTTP/1.1 200 OK` from curl | ✅ |
| Ping 8.8.8.8 | 0% packet loss, avg 19ms RTT | ✅ |
| DNS | `dig google.com` resolved correctly | ✅ |
| System errors (last 1h) | No entries | ✅ Clean |
| Auth failures | 3 failed attempts from `192.168.100.1` (Hyper-V host — own testing) | ℹ️ Expected |
| Failed systemd units | 0 | ✅ Clean |

---

## Key Observations

**`sudo` is required for full `ss -tulpn` output.**
Running without `sudo` hides process ownership — ports show but the process column is blank. In production, always run `ss -tulpn` as root or with sudo for complete visibility.

**Auth failures are not always attacks.**
Three SSH failed attempts appeared in `auth.log` — all from `192.168.100.1`, the Hyper-V host IP. Own testing during setup. This is why source IP context matters: same log entry, external IP = security event; internal host IP = operator activity.

**`vmstat wa = 0` confirms disk is not the bottleneck.**
All three vmstat readings showed `wa` of 0. During any performance investigation on this VM, disk I/O can be eliminated as a cause immediately.

**Docker logs show nftables errors on startup — not a problem.**
The `Error: Could not process rule` entries in Docker logs are a known behaviour on Ubuntu 24.04 with kernel 6.8 — Docker attempts to clean up nftables rules that do not exist yet on first start. Service initializes correctly regardless. Confirmed by `Active: active (running)` and `API listen on /run/docker.sock` at the end of the log.

**A runbook is not documentation — it is a decision tree under pressure.**
The difference between a checklist and a runbook is the "if this worsens" section. Anyone can list commands. A runbook defines what output means and what action to take next.

---

## Real-World Tie-in

- This exact structure maps to how I document pre/post change state in the data centre — baseline before change, verify after, delta noted
- `journalctl` time-scoped queries are the same principle as Veeam job log review scoped to a backup window
- The "if this worsens" escalation paths map directly to ITIL L1 → L2 → L3 trigger definitions

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#Linux` `#DevOps`
