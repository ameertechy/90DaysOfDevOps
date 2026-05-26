# Day 11 – File Ownership Challenge: chown and chgrp

## Overview

Day 11 completes the Linux access control triangle.

Day 9 was about users and groups — who exists on the system.
Day 10 was about permissions — what actions are allowed on a file.
Day 11 is about ownership — which user and group those permissions apply to.

Without ownership, permissions mean nothing. A file set to `640` protects nothing if the wrong user owns it. Today I worked through every ownership scenario: single file, combined owner and group, and recursive directory trees — the same operations I run after every service deployment in production.

---

## What I Produced

- [`day-11-file-ownership.md`](./day-11-file-ownership.md)

---

## Files and Directories Created

| Path | Owner | Group |
|------|-------|-------|
| `devops-file.txt` | tokyo | ubuntu |
| `team-notes.txt` | ubuntu | heist-team |
| `project-config.yaml` | professor | heist-team |
| `app-logs/` | berlin | heist-team |
| `heist-project/` (recursive) | professor | planners |
| `bank-heist/access-codes.txt` | tokyo | vault-team |
| `bank-heist/blueprints.pdf` | berlin | tech-team |
| `bank-heist/escape-plan.txt` | nairobi | vault-team |

---

## Key Observations

**Ownership and permissions work together — neither alone is enough.**
A file owned by `tokyo` with permissions `640` gives `tokyo` read+write access. But if `berlin` is not in the file's group, `berlin` gets no access at all regardless of what permissions are set. Ownership determines which permission row applies to which user.

**`chown owner:group` is one command doing two jobs.**
In production I always use the combined form — fewer commands, fewer chances for an intermediate state where the owner changed but the group did not. Atomic ownership changes matter during deployments.

**`-R` on a directory tree is powerful and irreversible without effort.**
`sudo chown -R professor:planners heist-project/` changes every file and subdirectory in one command. There is no undo. Always `ls -lR` the directory first to confirm what will be affected before running recursive chown.

**`chown :groupname` changes only the group — same as `chgrp`.**
The colon with no user before it tells `chown` to leave the owner unchanged and only update the group. In practice I prefer `chown :group` over `chgrp` because it is one less command to remember.

---

## Real-World Tie-in

- After deploying Nginx configs: `sudo chown root:www-data /etc/nginx/sites-available/myapp.conf` — root owns it, Nginx can read it
- After deploying app files: `sudo chown -R appuser:appgroup /opt/myapp/` — service account owns its own files
- After a file upload via CI/CD pipeline: ownership may default to the pipeline agent user — must be corrected to the service user before the app can read its own config
- Docker bind mounts: container processes run as specific UIDs — host file ownership must match that UID or the container gets permission denied

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#Linux` `#DevOps`
