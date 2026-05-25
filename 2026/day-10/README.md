# Day 10 – File Permissions and File Operations Challenge

## Overview

Day 10 takes file permissions from theory into deliberate practice.

After 7+ years in infrastructure, I apply `chmod` and `ls -l` daily — but often without thinking about the underlying model. Today I ran through every permission scenario systematically: creating files, reading the permission string precisely, modifying permissions using both symbolic and octal notation, and deliberately testing what happens when permissions are violated.

This is the foundation for everything that follows — Docker volume mounts, CI/CD pipeline scripts, Ansible file modules, and Kubernetes security contexts all map back to exactly this permission model.

---

## What I Produced

- [`day-10-file-permissions.md`](./day-10-file-permissions.md)

---

## Files Created and Permission States

| File | Initial Permissions | Final Permissions | Purpose |
|------|-------------------|-------------------|---------|
| `devops.txt` | `644` (rw-r--r--) | `444` (r--r--r--) | Read-only for all |
| `notes.txt` | `644` (rw-r--r--) | `640` (rw-r-----) | Owner rw, group r, others none |
| `script.sh` | `644` (rw-r--r--) | `755` (rwxr-xr-x) | Executable script |
| `project/` | `755` (rwxr-xr-x) | `755` (rwxr-xr-x) | Standard directory |

---

## Key Observations

**Default permissions are set by `umask` — not by the command.**
When I create a file with `touch`, it gets `644` by default. When I create a directory with `mkdir`, it gets `755`. These are not hardcoded — they are calculated from `umask`. The system default `umask 022` subtracts write permission from group and others. Understanding `umask` is what lets me change the default for all files a service creates.

**Symbolic vs octal — both are production tools.**
`chmod +x script.sh` is faster for single changes. `chmod 755 script.sh` is what goes into scripts, Dockerfiles, and Ansible playbooks because it sets the absolute state — not relative. If a file is currently `777` and I run `chmod +x`, nothing changes. If I run `chmod 755`, it is corrected to exactly what I intend.

**Permission denied errors are diagnostic data — not just failures.**
When `echo "test" >> devops.txt` fails with `Permission denied`, that is the access control model working correctly. In production, unexpected permission denied errors on service files tell me exactly which user is trying to write and what ownership needs to be fixed.

**`vim` is unavoidable in production Linux.**
Every cloud server has `vim` or `vi`. Knowing how to open, edit, save, and quit — and how to open in read-only mode — is mandatory. `nano` may not be installed. `vim` always is.

---

## Real-World Tie-in

- `chmod 600` on SSH private key files — the exact permission level that SSH enforces. Too open = rejected connection
- `chmod 755` on deployment scripts — owner can execute and modify, everyone else can only read and execute
- `chmod 640` on config files with secrets — owner reads/writes, service group reads, world sees nothing
- `umask 027` on application servers — default file creation masks out all world permissions for security hardening

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#Linux` `#DevOps`
