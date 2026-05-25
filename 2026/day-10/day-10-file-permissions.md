# File Permissions and File Operations
#90DaysOfDevOps 2026

---

## The Permission Model — Understanding Before Applying

Every file and directory on Linux has three permission sets and three subjects:

```
- rw- r-- r--
│  │   │   └── others  (everyone else on the system)
│  │   └────── group   (the file's assigned group)
│  └────────── owner   (the user who owns the file)
└───────────── file type (- = file, d = directory, l = symlink)
```

**Permission bits:**

| Symbol | Octal | Meaning on a File | Meaning on a Directory |
|--------|-------|-------------------|----------------------|
| `r` | 4 | Read file content | List directory contents (`ls`) |
| `w` | 2 | Modify file content | Create/delete files inside |
| `x` | 1 | Execute as a program | Enter the directory (`cd`) |
| `-` | 0 | Permission not granted | Permission not granted |

**Why `x` on a directory matters:**
Without execute on a directory, `cd` into it is denied even if read is granted. `r` alone lets you list filenames with `ls` but you cannot access any file inside. Both `r` and `x` together give full directory navigation.

---

## Task 1 — Create Files

```bash
# Navigate to working directory
mkdir -p ~/devops/day10 && cd ~/devops/day10

# Create empty file
touch devops.txt

# Create file with content using echo
echo "This is my DevOps notes file" > notes.txt
echo "Day 10 - File Permissions Practice" >> notes.txt
echo "Learning chmod, umask, and permission testing" >> notes.txt

# Create script using vim
vim script.sh
```

**`vim` essential commands — the minimum needed:**

| Mode | Key | Action |
|------|-----|--------|
| Normal → Insert | `i` | Start typing/editing |
| Insert → Normal | `Esc` | Stop editing, return to normal |
| Normal | `:w` | Save (write) |
| Normal | `:q` | Quit |
| Normal | `:wq` | Save and quit |
| Normal | `:q!` | Quit without saving (force) |
| Normal | `:set nu` | Show line numbers |
| Normal | `dd` | Delete current line |

**Contents of `script.sh`:**
```bash
#!/bin/bash
echo "Hello DevOps"
```

```bash
# Verify all three files exist
ls -l
```

**Reading `ls -l` output precisely:**
```
-rw-rw-r-- 1 ubuntu ubuntu   0 May 26 devops.txt
-rw-rw-r-- 1 ubuntu ubuntu  95 May 26 notes.txt
-rw-rw-r-- 1 ubuntu ubuntu  32 May 26 script.sh
```

| Column | Meaning |
|--------|---------|
| `-rw-rw-r--` | File type + permissions |
| `1` | Hard link count |
| `ubuntu` | Owner user |
| `ubuntu` | Owner group |
| `0` / `95` / `32` | Size in bytes |
| `May 26` | Last modification date |
| `devops.txt` | Filename |

**Why default is `664` on EC2 and `644` on some systems:**
This is controlled by `umask`. Check it:
```bash
umask
# 0002 on EC2 Ubuntu = group write allowed by default
# 0022 on standard Ubuntu = group write blocked by default
```

`umask 0002` means: subtract `000 000 010` from maximum `666` (files) = `664`. That is why new files on EC2 show `rw-rw-r--`.

---

## Task 2 — Read Files

```bash
# Read full content
cat notes.txt

# View script.sh in vim read-only mode (cannot accidentally edit)
vim -R script.sh
# :q to exit

# First 5 lines of /etc/passwd
head -n 5 /etc/passwd

# Last 5 lines of /etc/passwd
tail -n 5 /etc/passwd
```

**Reading `/etc/passwd` output:**
```
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
ubuntu:x:1000:1000:Ubuntu:/home/ubuntu:/bin/bash
```
Fields: `username : password(x) : UID : GID : comment : home : shell`

The `x` in the password field means the actual password hash is stored in `/etc/shadow` (root-readable only). This separation is a security design — if `/etc/passwd` is world-readable (it must be for many commands to work), the password hashes are not exposed.

---

## Task 3 — Understand Current Permissions

```bash
ls -l devops.txt notes.txt script.sh
```

**Analysing each file's default state:**

`devops.txt` — `-rw-rw-r--`
- Owner: read + write ✅
- Group: read + write ✅
- Others: read only

`notes.txt` — `-rw-rw-r--`
- Owner: read + write ✅
- Group: read + write ✅
- Others: read only

`script.sh` — `-rw-rw-r--`
- Owner: read + write ✅ but **no execute** ❌
- Cannot run with `./script.sh` until execute is added

---

## Task 4 — Modify Permissions

### 4.1 Make `script.sh` Executable

```bash
# Add execute permission
chmod +x script.sh

# Verify
ls -l script.sh
# -rwxrwxr-x  ← x added to all three

# Run it
./script.sh
# Output: Hello DevOps
```

**Why `./` is required:**
The shell searches for commands in `$PATH` directories. The current directory is not in `$PATH` by design — a security measure to prevent accidentally running malicious files. `./` explicitly says "run this file from the current location."

**Symbolic vs octal for the same result:**
```bash
chmod +x script.sh        # adds x to owner, group, others
chmod a+x script.sh       # same — 'a' = all
chmod 755 script.sh       # sets absolute: rwxr-xr-x
```

Difference: `chmod +x` on a file that is `600` produces `700`. `chmod 755` always produces exactly `755` regardless of starting state. **Use octal in scripts.**

### 4.2 Set `devops.txt` to Read-Only

```bash
# Remove write for all — owner, group, others
chmod -w devops.txt

# Verify
ls -l devops.txt
# -r--r--r-- (444)

# Or set explicitly with octal
chmod 444 devops.txt
```

### 4.3 Set `notes.txt` to `640`

```bash
chmod 640 notes.txt

# Verify
ls -l notes.txt
# -rw-r-----
```

**`640` breakdown:**
- `6` = `rw-` → owner can read and write
- `4` = `r--` → group can read only
- `0` = `---` → others: no access at all

**When to use `640`:** Config files that contain credentials or sensitive settings. The service user (owner) needs read/write. The service group needs read. No one else should see the file at all.

### 4.4 Create Directory with `755`

```bash
mkdir project
chmod 755 project

# Verify
ls -ld project
# drwxr-xr-x
```

**`755` on a directory:**
- Owner: `rwx` — full control, can create/delete files inside
- Group: `r-x` — can list and enter, cannot create or delete
- Others: `r-x` — same as group

This is the standard permission for web server document roots, shared read directories, and application directories where only the owner writes.

---

## Task 5 — Test Permission Violations

### Test 1: Write to Read-Only File

```bash
echo "trying to write" >> devops.txt
# -bash: devops.txt: Permission denied
```

**What happened:** The shell attempted to open `devops.txt` for writing. The kernel checked the permission bits — `r--r--r--` has no write bit for the owner. Access denied. The error message is the kernel's access control system working correctly.

```bash
# Even root can override this — but good operators do not
sudo bash -c 'echo "root can write" >> devops.txt'
cat devops.txt
# root can write — root bypasses DAC (Discretionary Access Control)
```

### Test 2: Execute File Without Execute Permission

```bash
# Remove execute from script.sh first
chmod 644 script.sh

# Try to run it
./script.sh
# -bash: ./script.sh: Permission denied
```

**Alternative that still works even without execute bit:**
```bash
bash script.sh
# Output: Hello DevOps — works because bash is the executor, not the file itself
```

**Why `bash script.sh` works but `./script.sh` does not:**
`./script.sh` asks the kernel to execute the file directly — the kernel checks the execute bit. `bash script.sh` runs bash (which is executable) and passes the script as an argument — bash reads it as a text file. The execute bit check only happens on direct execution.

### Test 3: Access a Directory Without Execute Permission

```bash
# Remove execute from project directory
chmod 644 project

# Try to enter
cd project
# -bash: cd: project: Permission denied

# Try to list contents
ls project
# ls: cannot access 'project/': Permission denied

# Restore
chmod 755 project
```

**The lesson:** On a directory, `x` is the "traverse" permission — without it, even `r` is useless. You can see the directory name in the parent listing but cannot interact with anything inside.

---

## Permission Reference Table

| Octal | Symbolic | Use Case |
|-------|----------|----------|
| `400` | `r--------` | SSH private keys — owner read-only, nothing else |
| `600` | `rw-------` | Private config files, credentials |
| `640` | `rw-r-----` | Config files with secrets — group can read |
| `644` | `rw-r--r--` | Standard files — owner writes, world reads |
| `700` | `rwx------` | Private scripts — owner only |
| `755` | `rwxr-xr-x` | Scripts, directories — owner writes, world executes |
| `775` | `rwxrwxr-x` | Shared team directories — group full access |
| `777` | `rwxrwxrwx` | Never in production — world writable is a security risk |

---

## Command Reference

```bash
# View permissions
ls -l <file>
ls -ld <directory>
stat <file>              # detailed metadata including octal permissions

# Modify permissions — symbolic
chmod +x file            # add execute
chmod -w file            # remove write
chmod u+x,g-w file       # owner add execute, group remove write

# Modify permissions — octal (preferred in scripts)
chmod 755 file
chmod 644 file
chmod 640 file

# Check umask
umask                    # view current
umask 022               # set temporarily
```

---

#90DaysOfDevOps 2026
