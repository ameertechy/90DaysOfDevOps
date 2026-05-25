# Linux User and Group Management
*Day 09 | Sun 25 May 2026 | #90DaysOfDevOps 2026*

---

## Core Concepts Before the Commands

### What is a Linux User?

Every process and every file on Linux is owned by a user. A user is not just a human — it is an identity the kernel uses to enforce access control. There are three types:

| Type | UID Range | Example | Purpose |
|------|-----------|---------|---------|
| Root | 0 | `root` | Superuser — unrestricted access to everything |
| System users | 1–999 | `www-data`, `docker`, `mysql` | Service accounts — run daemons, own service files |
| Regular users | 1000+ | `ameerul`, `tokyo` | Human operators |

```bash
# See your own UID, GID, and group memberships
id
# Output: uid=1000(ameerul) gid=1000(ameerul) groups=1000(ameerul),4(adm),27(sudo),docker
```

### What is a Linux Group?

A group is a collection of users that share the same access permissions on files and directories. Every file has one owner user and one owner group. Groups eliminate the need to set individual permissions for every team member.

### Where Users and Groups Are Stored

| File | Contents |
|------|----------|
| `/etc/passwd` | User accounts — username, UID, GID, home dir, shell |
| `/etc/shadow` | Encrypted passwords — root-readable only |
| `/etc/group` | Group definitions — group name, GID, members |

```bash
# Format of /etc/passwd
cat /etc/passwd | grep tokyo
# tokyo:x:1001:1001::/home/tokyo:/bin/bash
# Fields: username:password(x=in shadow):UID:GID:comment:home:shell

# Format of /etc/group
cat /etc/group | grep developers
# developers:x:1002:tokyo,berlin
# Fields: groupname:password:GID:members
```

---

## Task 1 — Create Users

### `useradd` vs `adduser` — Understanding the Difference

**`useradd`** is the low-level system binary. Available on every Linux distribution. Does only what you explicitly tell it — no home directory, no password, no shell unless flags are passed.

**`adduser`** is a high-level interactive wrapper — Debian/Ubuntu only. Prompts for password, creates home directory, sets up shell automatically. Better for interactive use.

```bash
# useradd alone — creates user with NO home directory, NO shell, NO password
sudo useradd tokyo
# Result: user exists but cannot log in — no home dir, no password

# useradd -m — creates user WITH home directory
sudo useradd -m tokyo
# -m flag: create home directory at /home/tokyo
```

**Flag breakdown for `useradd`:**

| Flag | Meaning | Example |
|------|---------|---------|
| `-m` | Create home directory | `useradd -m tokyo` |
| `-s` | Set login shell | `useradd -s /bin/bash tokyo` |
| `-G` | Add to supplementary groups | `useradd -G developers tokyo` |
| `-c` | Add a comment/description | `useradd -c "Tokyo User" tokyo` |
| `-u` | Set specific UID | `useradd -u 1005 tokyo` |

```bash
# Create all three users with home directories
sudo useradd -m tokyo
sudo useradd -m berlin
sudo useradd -m professor
```

```bash
# Set passwords for each user
sudo passwd tokyo
# Prompts: Enter new UNIX password → confirm

sudo passwd berlin
sudo passwd professor
```

```bash
# Verify users were created
cat /etc/passwd | grep -E "tokyo|berlin|professor"
ls -lh /home/
# Each user should have a home directory listed

# Check full identity of a user
id tokyo
# uid=1001(tokyo) gid=1001(tokyo) groups=1001(tokyo)
```

### `adduser` — The Interactive Alternative

```bash
# adduser prompts for everything interactively
sudo adduser nairobi
# Prompts: password, full name, room number, phone, etc.
# Automatically creates /home/nairobi and sets bash as shell
```

**When to use which:**
- Scripts and automation → `useradd` with explicit flags
- Interactive server setup → `adduser` (Ubuntu/Debian only)

---

## Task 2 — Create Groups

```bash
# Create groups
sudo groupadd developers
sudo groupadd admins
```

**What `groupadd` does:** Adds a new entry to `/etc/group` with a new GID auto-assigned.

```bash
# Verify groups were created
cat /etc/group | grep -E "developers|admins"
# developers:x:1005:
# admins:x:1006:
# GID auto-assigned, no members yet
```

---

## Task 3 — Assign Users to Groups

### `usermod -aG` — The Critical Flag Combination

```bash
# Add tokyo to developers group
sudo usermod -aG developers tokyo

# Add berlin to developers AND admins
sudo usermod -aG developers berlin
sudo usermod -aG admins berlin

# Add professor to admins
sudo usermod -aG admins professor
```

**`usermod` flag breakdown:**

| Flag | Meaning | Critical Note |
|------|---------|---------------|
| `-a` | Append — add to group without removing existing memberships | ALWAYS use with `-G` |
| `-G` | Supplementary groups to assign | Without `-a`, replaces ALL existing groups |
| `-aG` | Safe group addition — append to group list | The only safe way to add a user to a group |

**The danger of `-G` without `-a`:**
```bash
# DANGEROUS — removes tokyo from ALL current groups, adds only to developers
sudo usermod -G developers tokyo

# SAFE — adds tokyo to developers, keeps all existing groups
sudo usermod -aG developers tokyo
```

In production, running `usermod -G` without `-a` on a user who has sudo access will silently remove their sudo — they lose admin access until corrected.

```bash
# Verify group memberships
groups tokyo
# tokyo : tokyo developers

groups berlin
# berlin : berlin developers admins

groups professor
# professor : professor admins

# Alternative — more detailed
id berlin
# uid=1002(berlin) gid=1002(berlin) groups=1002(berlin),1005(developers),1006(admins)
```

---

## Task 4 — Shared Directory for Developers

```bash
# Create the shared directory
sudo mkdir -p /opt/dev-project

# Change group ownership to developers
sudo chgrp developers /opt/dev-project
```

**`chgrp` breakdown:**
- `chgrp` = change group
- Changes only the group owner of a file or directory
- Does not affect the user owner

```bash
# Set permissions to 775
sudo chmod 775 /opt/dev-project
```

**Why 775:**

```
7  7  5
│  │  └── others: r-x (read + execute — can enter dir and read files, cannot write)
│  └───── group: rwx  (read + write + execute — full access)
└──────── owner: rwx  (read + write + execute — full access)
```

```bash
# Verify ownership and permissions
ls -ld /opt/dev-project
# drwxrwxr-x 2 root developers 4096 May 25 /opt/dev-project
```

```bash
# Test: create a file as tokyo
sudo -u tokyo touch /opt/dev-project/tokyo-file.txt
ls -lh /opt/dev-project/

# Test: create a file as berlin
sudo -u berlin touch /opt/dev-project/berlin-file.txt
ls -lh /opt/dev-project/
```

**`sudo -u username command`:** Runs a command as a different user without switching session. The safest way to test user permissions without logging out.

### Bonus: `setgid` bit for automatic group inheritance

```bash
# Without setgid — new files are owned by the creator's primary group
# With setgid — new files automatically inherit the directory's group

sudo chmod g+s /opt/dev-project
ls -ld /opt/dev-project
# drwxrwsr-x  ← the 's' in group execute position = setgid active

# Now any file created here automatically belongs to 'developers' group
sudo -u tokyo touch /opt/dev-project/test-setgid.txt
ls -lh /opt/dev-project/test-setgid.txt
# -rw-rw-r-- 1 tokyo developers ← group is 'developers' automatically
```

---

## Task 5 — Team Workspace

```bash
# Create group
sudo groupadd project-team

# Add nairobi and tokyo to project-team
sudo usermod -aG project-team nairobi
sudo usermod -aG project-team tokyo

# Verify
groups nairobi
groups tokyo

# Create workspace directory
sudo mkdir -p /opt/team-workspace

# Set ownership and permissions
sudo chgrp project-team /opt/team-workspace
sudo chmod 775 /opt/team-workspace
sudo chmod g+s /opt/team-workspace   # setgid — new files inherit group

# Verify
ls -ld /opt/team-workspace
# drwxrwsr-x 2 root project-team 4096 May 25 /opt/team-workspace

# Test: nairobi creates a file
sudo -u nairobi touch /opt/team-workspace/nairobi-work.txt
ls -lh /opt/team-workspace/
```

---

## `chown` — Change Owner and Group Together

```bash
# chown changes user owner
sudo chown tokyo /opt/dev-project/tokyo-file.txt

# chown changes both user and group at once
sudo chown tokyo:developers /opt/dev-project/tokyo-file.txt
# Format: chown user:group file

# chown recursively — change ownership of entire directory tree
sudo chown -R nairobi:project-team /opt/team-workspace
# -R = recursive — applies to all files and subdirectories
```

**`chown` vs `chgrp`:**

| Command | Changes | Example |
|---------|---------|---------|
| `chown user file` | User owner only | `chown tokyo file.txt` |
| `chown user:group file` | Both user and group | `chown tokyo:dev file.txt` |
| `chgrp group file` | Group only | `chgrp developers file.txt` |

---

## Final Verification — Complete State

```bash
# All users
cat /etc/passwd | grep -E "tokyo|berlin|professor|nairobi" | cut -d: -f1,3,4,6,7

# All groups
cat /etc/group | grep -E "developers|admins|project-team"

# Group memberships
for user in tokyo berlin professor nairobi; do
  echo "$user: $(groups $user)"
done

# Directory permissions
ls -ld /opt/dev-project /opt/team-workspace
```

---

## Command Reference

| Command | Purpose |
|---------|---------|
| `useradd -m <user>` | Create user with home directory |
| `adduser <user>` | Interactive user creation (Ubuntu) |
| `passwd <user>` | Set or change user password |
| `usermod -aG <group> <user>` | Add user to group (safe append) |
| `groupadd <group>` | Create a new group |
| `groups <user>` | Show group memberships |
| `id <user>` | Show UID, GID, all groups |
| `chgrp <group> <path>` | Change group owner |
| `chown <user>:<group> <path>` | Change user and group owner |
| `chmod 775 <path>` | Set rwxrwxr-x permissions |
| `chmod g+s <path>` | Set setgid bit |
| `sudo -u <user> <cmd>` | Run command as another user |
| `cat /etc/passwd` | View user account database |
| `cat /etc/group` | View group database |

---

*Day 09 | Sun 25 May 2026 | #90DaysOfDevOps 2026*
