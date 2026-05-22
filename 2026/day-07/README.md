# Day 07 – Linux File System Hierarchy and Scenario-Based Practice

## Overview

Day 7 consolidates the Linux fundamentals week with two focused areas: understanding exactly where things live in the filesystem, and applying that knowledge to real troubleshooting scenarios.

After 7+ years managing production infrastructure, I navigate the Linux filesystem daily — but mostly on autopilot. Today I formalized that knowledge into a structured reference and tested it against four real-world incident scenarios.

---

## What I Produced

- [`day-07-linux-fs-and-scenarios.md`](./day-07-linux-fs-and-scenarios.md)

---

## Key Observations

**The Linux filesystem is a contract — every directory has a defined purpose.**
On Windows, software installs wherever it wants. On Linux, there is a standard: the Filesystem Hierarchy Standard (FHS). A config file belongs in `/etc`. A log file belongs in `/var/log`. An optional app belongs in `/opt`. Knowing this means I never search for files — I go directly to the right location.

**`/etc` is the most critical directory in any production system.**
Every service config lives here. Nginx, SSH, Docker, cron, environment variables — all of it. Before touching any service, I read its config in `/etc` first. A misconfiguration here causes production outages.

**`/var/log` is where incidents begin and end.**
Every investigation starts here. When Zabbix fires an alert, the first question is always "what does the log say?" The log files in `/var/log` — syslog, auth.log, nginx/, journal — are the primary evidence trail for every incident I have worked.

**Scenario practice reveals gaps that command memorization hides.**
I can list commands all day. The scenarios forced me to think about sequence and reasoning — which command first, what does the output tell me, what is the next step if it does not look right. That decision flow is what production operations actually demands.

---

## Real-World Tie-in

- In the data centre, my first action on any new server is `ls /etc` and `ls /var/log` — that tells me what services are configured and what is being logged
- `/opt` is where I deployed JumpServer PAM, Moodle LMS, and Snipe-IT — all third-party platforms that do not belong in system directories
- `/tmp` awareness is critical for Veeam staging and large file operations — it clears on reboot, so anything important must be moved before restart
- The permission scenario (`chmod +x`) is something I run routinely on new automation scripts before scheduling them in cron

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#Linux` `#DevOps`
