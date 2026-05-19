# Day 04 – Linux Practice: Processes and Services

## Overview

Day 4 is pure hands-on execution — no theory, no reading. The goal is to run real commands against a live system, observe actual output, and document what you see as an operator would.

Covered today:

- Process inspection and manipulation (ps, pgrep, renice, kill)
- Special shell operators and symbols (15 operators documented)
- Service inspection against Docker and SSH
- Log analysis using journalctl and tail

---

## What I Produced

- [`linux-practice.md`](./linux-practice.md)

---

## Key Observations

**`ps` alone is almost useless in production.**
It shows only processes attached to the current terminal session. The moment you add `aux`, you get the full system picture — all users, all background daemons, resource usage. That is the production-relevant command.

**Nice values are a real operations tool — not just theory.**
Simulated a CPU-intensive background process using `yes > /dev/null &`, verified its PID with `pgrep`, checked its default nice value (0), elevated it to 18 with `renice`, confirmed the change, then killed the process. This is the exact sequence for managing runaway background jobs without taking down a service.

**Shell operators are the backbone of command chaining.**
Documented all 15 operators from hands-on practice: `>`, `>>`, `|`, `&&`, `&`, `/`, `\`, `-`, `*`, `.`, `..`, `~`, `$`, `#`, `;`. Each one controls how commands interact — understanding them is what separates scripting from typing.

**Spaces in directory names require escape characters.**
Attempted `mkdir Ameerul Mujahidin` — Linux created two separate directories. Used `mkdir Ameerul\ Mujahidin` to create a single directory with a space. Important operational knowledge for handling file paths in scripts and automation.

---

## Real-World Tie-in

- `renice` on a background process → directly applicable when a backup job or cron task spikes CPU during business hours
- `&&` operator → used in every deployment script: `apt update && apt install -y nginx` — second command only runs if first succeeds
- `ps aux --sort=-%cpu` → first command when a CPU alert fires before digging into service logs
- `journalctl -u docker` → standard first step before any Docker service escalation

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#Linux` `#DevOps`
