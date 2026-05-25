# Day 09 – Linux User and Group Management Challenge

## Overview

Day 9 is a hands-on challenge built around one of the most fundamental Linux administration tasks: managing who has access to what.

In any production environment — whether a university data centre, a cloud server, or a Kubernetes node — user and group management is the foundation of access control. Every file has an owner. Every process runs as a user. Every service account is a system user. Getting this wrong causes security gaps and operational failures.

Today I worked through five challenge tasks on an AWS EC2 instance: creating users, creating groups, assigning memberships, building shared directories with group permissions, and testing access as different users.

---

## What I Produced

- [`day-09-user-management.md`](./day-09-user-management.md)

---

## Users and Groups Created

**Users:** `tokyo`, `berlin`, `professor`, `nairobi`

**Groups:** `developers`, `admins`, `project-team`

**Group assignments:**

| User | Groups |
|------|--------|
| tokyo | developers, project-team |
| berlin | developers, admins |
| professor | admins |
| nairobi | project-team |

**Shared directories:**

| Directory | Group | Permissions |
|-----------|-------|-------------|
| `/opt/dev-project` | developers | 775 |
| `/opt/team-workspace` | project-team | 775 |

---

## Key Observations

**`useradd` and `adduser` are not the same command.**
`useradd` is the low-level system utility — it creates the user but does not set up a home directory, password prompt, or default shell unless flags are explicitly passed. `adduser` is a higher-level wrapper (Debian/Ubuntu specific) that is interactive, sets up the home directory, and prompts for a password automatically. In scripts, `useradd` with flags is standard. Interactively on Ubuntu, `adduser` is cleaner.

**`-aG` in `usermod` — both flags are mandatory together.**
`usermod -G developers tokyo` without `-a` removes tokyo from all other groups and puts them only in developers. `-a` means append — add to the group without touching existing memberships. Forgetting `-a` in production silently removes a user's sudo access or service access. Always use `-aG` together.

**`775` on a shared directory is the correct production pattern.**
Owner: full control. Group: full control. Others: read and execute only. This means any user in the `developers` group can create, edit, and delete files in `/opt/dev-project`, but users outside the group can only read. The `setgid` bit (`chmod g+s`) extends this further — new files inherit the group automatically.

**`/etc/passwd` and `/etc/group` are the source of truth.**
Every user and group operation writes to these files. `cat /etc/passwd | grep tokyo` is the definitive check — not just `id tokyo`. Understanding these files is what separates operators who understand the system from those who just run commands.

---

## Real-World Tie-in

- Every service I deploy runs as a dedicated system user — Nginx as `www-data`, Docker as `docker` group, MySQL as `mysql`. This is the same `useradd` / `usermod` pattern applied to service accounts
- The `developers` group with `775` on a shared directory is exactly how I manage shared infrastructure scripts in the data centre — team members in the group, scripts in a shared directory, no one using root for routine operations
- `sudo chown` and `chgrp` are commands I run after every deployment to ensure service files are owned by the right process user — a misconfigured ownership causes a permission denied on service start

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#Linux` `#DevOps`
