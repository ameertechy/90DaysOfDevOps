# File Ownership Challenge: chown and chgrp
*#90DaysOfDevOps 2026*

---

## The Ownership Model — Understanding Before Applying

Every file on Linux has exactly two owners:

```
-rw-r----- 1 tokyo heist-team 512 devops-file.txt
              │      │
              │      └── Group owner — which group's permissions apply
              └───────── User owner — which user's permissions apply
```

When the kernel checks if a user can access a file, it asks three questions in order:

1. Is this user the **file owner**? → Apply the owner permission bits (first `rwx`)
2. Is this user in the **file's group**? → Apply the group permission bits (middle `rwx`)
3. Neither? → Apply the others permission bits (last `rwx`)

**Only one set of permissions applies per access.** If `tokyo` owns the file and is also in `heist-team`, the kernel uses the owner bits — not the group bits. Owner check always comes first.

---

## Task 1 — Understanding Ownership

```bash
# Navigate to working directory
mkdir -p ~/devops/day11 && cd ~/devops/day11

# Check who owns files in home directory
ls -l ~/
```

**Reading the ownership columns:**
```
-rw-r--r-- 1 ubuntu ubuntu 95 notes.txt
             │      │
             │      └── group: ubuntu (default group matching username)
             └───────── owner: ubuntu
```

On a fresh EC2 Ubuntu instance, the default user is `ubuntu`. New files created by `ubuntu` are owned by `ubuntu:ubuntu` — the username and its matching primary group share the same name.

```bash
# Check your own identity
id
# uid=1000(ubuntu) gid=1000(ubuntu) groups=1000(ubuntu),4(adm),27(sudo)

# Every user has a primary group (gid) — new files belong to this group by default
# Supplementary groups are additional groups the user belongs to
```

---

## Task 2 — Basic `chown` Operations

```bash
# Create the file
touch devops-file.txt

# Check current ownership
ls -l devops-file.txt
# -rw-rw-r-- 1 ubuntu ubuntu 0 devops-file.txt

# Create user tokyo if not already present
sudo useradd -m -s /bin/bash tokyo 2>/dev/null || true

# Change owner to tokyo
sudo chown tokyo devops-file.txt

# Verify
ls -l devops-file.txt
# -rw-rw-r-- 1 tokyo ubuntu 0 devops-file.txt
# Owner changed to tokyo — group still ubuntu
```

**What `chown` stands for:** Change Owner.

**Flag breakdown:**
- `sudo chown tokyo devops-file.txt` — changes user owner only
- `sudo` is required — only root can give away file ownership to another user

```bash
# Change owner again to berlin
sudo useradd -m -s /bin/bash berlin 2>/dev/null || true
sudo chown berlin devops-file.txt

# Verify
ls -l devops-file.txt
# -rw-rw-r-- 1 berlin ubuntu 0 devops-file.txt
```

**Why a regular user cannot run `chown` without sudo:**
If regular users could reassign ownership, `ameerul` could `chown root important-system-file` and lock everyone out of it. Only root controls ownership transfers.

---

## Task 3 — Basic `chgrp` Operations

```bash
# Create file
touch team-notes.txt

# Create group
sudo groupadd heist-team

# Check current group
ls -l team-notes.txt
# -rw-rw-r-- 1 ubuntu ubuntu 0 team-notes.txt

# Change group to heist-team
sudo chgrp heist-team team-notes.txt

# Verify
ls -l team-notes.txt
# -rw-rw-r-- 1 ubuntu heist-team 0 team-notes.txt
```

**What `chgrp` stands for:** Change Group.

**`chgrp` vs `chown :group`** — both do the same thing:
```bash
sudo chgrp heist-team team-notes.txt
# is identical to:
sudo chown :heist-team team-notes.txt
```

The colon before the group name in `chown` tells it: "leave the user owner alone, only change the group." In practice, `chown :group` is more versatile since `chown` handles both — fewer commands to memorize.

---

## Task 4 — Combined Owner and Group Change

```bash
# Create files
touch project-config.yaml
mkdir app-logs

# Create professor user if not present
sudo useradd -m -s /bin/bash professor 2>/dev/null || true

# Change BOTH owner and group in one command
sudo chown professor:heist-team project-config.yaml

# Verify
ls -l project-config.yaml
# -rw-rw-r-- 1 professor heist-team 0 project-config.yaml
```

**Syntax breakdown — `chown owner:group filename`:**

| Syntax | Effect |
|--------|--------|
| `chown tokyo file` | Change user owner only |
| `chown :heist-team file` | Change group only |
| `chown tokyo:heist-team file` | Change both user and group |
| `chown tokyo: file` | Change user owner, reset group to tokyo's primary group |

```bash
# Change directory ownership
sudo chown berlin:heist-team app-logs/

# Verify
ls -ld app-logs/
# drwxrwxr-x 2 berlin heist-team 4096 app-logs/
```

**Why `ls -ld` instead of `ls -l` for directories:**
`ls -l app-logs/` lists the contents inside the directory. `ls -ld app-logs/` lists the directory itself as an entry — showing its own ownership and permissions. The `d` flag means "directory itself."

---

## Task 5 — Recursive Ownership

```bash
# Create directory structure
mkdir -p heist-project/vault
mkdir -p heist-project/plans
touch heist-project/vault/gold.txt
touch heist-project/plans/strategy.conf

# Verify structure and current ownership
ls -lR heist-project/
# All files owned by ubuntu:ubuntu currently

# Create planners group
sudo groupadd planners 2>/dev/null || true

# Change ownership of entire tree recursively
sudo chown -R professor:planners heist-project/
```

**`-R` flag breakdown:**
- `-R` stands for **Recursive**
- Without `-R`: only the top-level directory itself changes — files inside are untouched
- With `-R`: the directory AND every file and subdirectory inside changes

```bash
# Verify every level changed
ls -lR heist-project/
```

**Expected output:**
```
heist-project/:
drwxrwxr-x 2 professor planners 4096 vault/
drwxrwxr-x 2 professor planners 4096 plans/

heist-project/vault/:
-rw-rw-r-- 1 professor planners 0 gold.txt

heist-project/plans/:
-rw-rw-r-- 1 professor planners 0 strategy.conf
```

All levels — directory, subdirectories, and files — now owned by `professor:planners`.

**Production rule before running recursive chown:**
```bash
# Always preview what will be affected first
find heist-project/ -ls | awk '{print $5, $6, $11}'
# Shows current owner, group, path for every item
# Confirm this is what you intend before running chown -R
```

---

## Task 6 — Practice Challenge

```bash
# Create users
sudo useradd -m -s /bin/bash nairobi 2>/dev/null || true

# Create groups
sudo groupadd vault-team 2>/dev/null || true
sudo groupadd tech-team 2>/dev/null || true

# Create directory and files
mkdir -p bank-heist
touch bank-heist/access-codes.txt
touch bank-heist/blueprints.pdf
touch bank-heist/escape-plan.txt

# Set individual ownership per file
sudo chown tokyo:vault-team bank-heist/access-codes.txt
sudo chown berlin:tech-team bank-heist/blueprints.pdf
sudo chown nairobi:vault-team bank-heist/escape-plan.txt

# Verify all ownership
ls -l bank-heist/
```

**Expected output:**
```
-rw-rw-r-- 1 tokyo   vault-team 0 access-codes.txt
-rw-rw-r-- 1 berlin  tech-team  0 blueprints.pdf
-rw-rw-r-- 1 nairobi vault-team 0 escape-plan.txt
```

Each file now has a different owner and group — demonstrating per-file access control. `tokyo` and `nairobi` share `vault-team` so both can access each other's files per the group permission bits.

---

## Ownership Verification Commands

```bash
# View ownership of a single file
ls -l filename

# View ownership of a directory itself (not contents)
ls -ld directory/

# View ownership of all files recursively
ls -lR directory/

# View detailed metadata including ownership
stat filename

# Find all files owned by a specific user
find /home -user tokyo

# Find all files belonging to a specific group
find /opt -group developers
```

---

## Command Reference

| Command | Effect |
|---------|--------|
| `sudo chown user file` | Change user owner only |
| `sudo chown :group file` | Change group only |
| `sudo chown user:group file` | Change both owner and group |
| `sudo chown -R user:group dir/` | Recursive — change entire directory tree |
| `sudo chgrp group file` | Change group only (same as `chown :group`) |
| `ls -l file` | View file ownership |
| `ls -ld dir/` | View directory's own ownership |
| `stat file` | Full metadata including ownership |
| `find / -user username` | Find all files owned by a user |
| `find / -group groupname` | Find all files owned by a group |

---

*#90DaysOfDevOps 2026*
