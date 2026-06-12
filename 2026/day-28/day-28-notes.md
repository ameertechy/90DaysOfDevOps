# Day 28 – Revision Day: Everything From Day 1 to Day 27
*#90DaysOfDevOps 2026*

---

## Task 1 — Self-Assessment Checklist (marked honestly)

Legend: ✅ Can do confidently · 🔁 Need to revisit · ❌ Haven't done yet

### Linux

| Item | Mark | Honest note |
|------|------|-------------|
| Navigate filesystem, create/move/delete | ✅ | Comfortable — only ~3 years around Linux, but this challenge made it daily habit |
| Manage processes — list, kill, bg/fg | ✅ | The troubleshooting instinct is from support; the Linux commands stuck in Days 2–7 |
| systemd — start/stop/enable/status | ✅ | Touched it occasionally in recent years; Days 2–7 made it reliable |
| Edit files with vi/vim or nano | ✅ | vim survival skills are solid, not fancy |
| Troubleshoot CPU/mem/disk — top, free, df, du | ✅ | The *method* was my job for 7 years (mostly on Windows) — these Linux tools came from the challenge |
| Explain filesystem hierarchy (/etc, /var…) | ✅ | Comfortable |
| Create users/groups, manage passwords | ✅ | Did this for years on Windows/AD — the Linux way came from Days 9–11 |
| chmod — numeric and symbolic | ✅ | Numeric instantly; symbolic needed a quick re-check |
| chown / chgrp | ✅ | Comfortable |
| Create and manage LVM volumes | 🔁 | Did it on Day 13 — couldn't redo it from memory today |
| Network checks — ping, curl, ss, dig | ✅ | ping/curl were daily support tools; `ss` and `dig` came from Days 14–15 |
| Explain DNS, IP, subnets, ports | ✅ | Concepts solid from support; sharpened on Days 14–15 |

### Shell Scripting

| Item | Mark | Honest note |
|------|------|-------------|
| Variables, arguments, user input | ✅ | Comfortable after Days 16–18 |
| if/elif/else and case | ✅ | Fine |
| for, while, until loops | ✅ | Fine — `until` needed a second look |
| Functions with args and return values | 🔁 | Can write them; return-value handling still trips me |
| grep, awk, sed, sort, uniq | 🔁 | grep solid; **awk and sed are my weakest area** |
| set -e, set -u, pipefail, trap | 🔁 | Knew roughly; couldn't explain precisely — see quick-fire |
| Schedule with crontab | ✅ | Comfortable from Day 19–20 + support cron jobs |

### Git & GitHub

| Item | Mark | Honest note |
|------|------|-------------|
| init, stage, commit, history | ✅ | Daily habit now |
| Create and switch branches | ✅ | Fine |
| Push/pull GitHub | ✅ | Daily habit |
| Clone vs fork | ✅ | Clear |
| Merge — fast-forward vs merge commit | ✅ | Clear since Day 24 |
| Rebase — when vs merge | 🔁 | Did it once; explanation wasn't crisp — redone today |
| stash / stash pop | ✅ | Used it for real this week |
| Cherry-pick | ✅ | Clear concept, done hands-on |
| Squash vs regular merge | ✅ | Clear |
| reset (soft/mixed/hard) and revert | ✅ | Day 25 drilled this properly |
| GitFlow / GitHub Flow / Trunk-Based | ✅ | Can explain all three + when to use |
| GitHub CLI — repos, PRs, issues | ✅ | Day 26 — used it for real since |

**Score summary: 24 ✅ · 5 🔁 · 0 ❌.** Worth being honest about where the ✅ column really comes from: not my 7 years — most of that was Windows. It comes from the last 28 days of daily reps. The gaps cluster where the reps haven't piled up yet: text-processing power tools, script hardening, and Git history rewriting.

---

## Task 2 — The 3 Weak Spots, Redone

### 🔁 1. LVM (from Day 13)

Redid the full chain from memory after one re-read:

```bash
# The layer cake: disk → PV → VG → LV → filesystem
sudo pvcreate /dev/xvdf              # mark the disk as a Physical Volume
sudo vgcreate data_vg /dev/xvdf      # pool PVs into a Volume Group
sudo lvcreate -n app_lv -L 2G data_vg  # carve a 2GB Logical Volume out of the pool
sudo mkfs.ext4 /dev/data_vg/app_lv   # put a filesystem on it
sudo mount /dev/data_vg/app_lv /mnt/app

# The actual point of LVM — grow it live:
sudo lvextend -L +1G /dev/data_vg/app_lv
sudo resize2fs /dev/data_vg/app_lv   # grow the filesystem into the new space
```

**What stuck this time:** the mental model — *PV = raw material, VG = warehouse, LV = the shelf you actually use.* And the reason it beats plain partitions: you can extend a live volume without unmounting anything.

### 🔁 2. awk & sed (from Days 16–21)

Drilled the patterns I keep reaching for and forgetting:

```bash
# awk = column tool. Print user + PID from ps:
ps aux | awk '{print $1, $2}'

# Sum a column (memory % total):
ps aux | awk '{sum += $4} END {print sum "%"}'

# Filter rows by condition:
df -h | awk '$5+0 > 80 {print $6, $5}'   # mounts over 80% full

# sed = line editor. Replace, in-place, with backup:
sed -i.bak 's/staging/production/g' config.txt

# Delete blank lines / comment lines:
sed '/^$/d; /^#/d' config.txt
```

**What stuck this time:** awk thinks in **columns** (`$1`, `$2`…), sed thinks in **lines**. Pick the tool by the shape of the problem.

### 🔁 3. git rebase (from Day 24)

Redid the experiment in a scratch repo:

```bash
git checkout -b feature main
# ...commits on feature...
git checkout main
# ...main moves ahead...
git checkout feature
git rebase main        # replays my feature commits ON TOP of main's latest
```

**The crisp version I couldn't say last week:** merge ties two histories together with a knot (merge commit); rebase rewrites my branch as if I had started it from today's main — straight line, no knot. Rebase = my local, unshared branches only. Anything pushed and shared gets merge or revert, never rebase.

---

## Task 3 — Quick-Fire Questions (from memory first, then verified)

Cold score: **7/10** — missed the precise `pipefail` explanation, the `lsof` form, and a clean LVM definition. All three written out properly below.

1. **What does `chmod 755 script.sh` do?**
   Owner: read+write+execute (7). Group: read+execute (5). Others: read+execute (5). Standard for scripts the owner maintains and everyone else can run.

2. **Process vs service?**
   A process is any running program instance. A service is a long-running background process (daemon) under a manager like systemd — it gets start/stop/restart/enable behaviour and survives logouts.

3. **Which process is using port 8080?**
   `ss -tulnp | grep 8080` — or `lsof -i :8080`. *(This one I fumbled — kept reaching for plain netstat.)*

4. **What does `set -euo pipefail` do?**
   `-e`: exit on any command failure. `-u`: using an unset variable is an error. `-o pipefail`: a pipeline fails if **any** command in it fails, not just the last one. Together: the script stops at the first real problem instead of barreling on with bad data. *(Fumbled the pipefail half.)*

5. **`git reset --hard` vs `git revert`?**
   `reset --hard` moves HEAD back and **deletes** the commits and changes — history rewritten, local-only tool. `revert` adds a **new** commit that undoes an old one — history preserved, safe on shared branches.

6. **Branching strategy for 5 devs shipping weekly?**
   GitHub Flow — one always-deployable `main`, short feature branches, PR review, merge, ship. GitFlow ceremony would slow a team that size down for no benefit.

7. **What does `git stash` do, when use it?**
   Shelves uncommitted changes so the working tree is clean, and lets you re-apply them later (`pop`/`apply`). Use it when you must switch context mid-work — urgent fix on another branch — without committing half-done work.

8. **Schedule a script daily at 3 AM?**
   `crontab -e` → `0 3 * * * /path/to/script.sh` (minute hour day month weekday).

9. **`git fetch` vs `git pull`?**
   `fetch` downloads remote changes but touches nothing local — you look first. `pull` = fetch + merge into your branch immediately. Fetch is the cautious one.

10. **What is LVM and why use it over regular partitions?**
    A flexible layer between disks and filesystems: disks → Physical Volumes → pooled into Volume Groups → carved into Logical Volumes. Why: resize volumes live, span multiple disks, snapshot before risky changes — none of which fixed partitions can do. *(Could do the commands on Day 13; couldn't define it cleanly today. Now I can.)*

---

## Task 4 — Organize Your Work (verified)

- ✅ Days 1–27 all committed and pushed to [ameertechy/90DaysOfDevOps](https://github.com/ameertechy/90DaysOfDevOps)
- ✅ `git-commands.md` current through Day 26 (gh commands included)
- ✅ Shell scripting cheat sheet complete (Day 21)
- ✅ Profile clean from Day 27 — profile README live, pins deliberate, descriptions filled

---

## Task 5 — Teach It Back: File Permissions (for a brand-new Linux user)

*The way I'd explain it to a new hire on the support desk:*

Every file in Linux has three questions attached: **who owns it, which team it belongs to, and what everyone else may do with it.** Those are the three groups: owner, group, others.

Each group gets three switches: **r**ead (look at it), **w**rite (change it), e**x**ecute (run it). That's it — nine switches total per file.

`ls -l` shows them: `-rwxr-xr--` reads as: owner can do everything, the group can read and run it, everyone else can only read it.

Numbers are just shorthand: r=4, w=2, x=1, add them up per group. So `chmod 755` = 7 (4+2+1, everything) for owner, 5 (4+1, read+run) for group and others.

When a user calls saying "permission denied", you're really asking three things: who are you (`whoami`), who owns the file (`ls -l`), and do your switches allow what you're trying to do. Ninety percent of permission tickets end at one of those three.

And the fix is one of two commands: `chmod` changes *what's allowed*, `chown` changes *who owns it*. That's the whole system.

---

## Where I Stand After 28 Days

| Area | Status |
|------|--------|
| Linux & troubleshooting | Strong now — ~3 years of light exposure, made solid by 28 days of daily reps |
| Networking basics | Strong |
| Shell scripting | Functional, needs reps on awk/sed and hardening |
| Git & GitHub | Confident — biggest growth area of the month |
| Next gap to close | Text processing fluency before scripting-heavy CI/CD days |

---

*#90DaysOfDevOps 2026*
