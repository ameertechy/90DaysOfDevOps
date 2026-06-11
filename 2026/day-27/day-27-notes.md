# Day 27 – GitHub Profile Makeover: Build Your Developer Identity
*#90DaysOfDevOps 2026*

---

## Task 1 — Profile Audit (the uncomfortable part)

I opened [github.com/ameertechy](https://github.com/ameertechy) and forced myself to look at it like a recruiter who has 30 seconds and 40 other candidates.

**Honest answers, before any changes:**

| Audit question | Honest answer (before) |
|----------------|----------------------|
| Is the profile picture professional? | Usable, but needed a cleaner, well-lit one |
| Is the bio filled in? Does it say what I do? | Too thin — didn't say who I am, what I'm learning, or where I'm heading |
| Are pinned repos relevant, or random? | Not deliberately chosen — GitHub was deciding my first impression for me |
| Do repos have descriptions? | Mostly blank — a stranger couldn't tell what anything was for |
| Would a recruiter understand what I've been working on? | Only if they dug into the 90DaysOfDevOps folders themselves — nobody does that |

**The verdict:** 26 days of real, consistent work — and the profile told none of that story. The work existed; the presentation didn't.

---

## Task 2 — Profile README (the special repo)

GitHub has a hidden feature: a repo named **exactly your username** gets its README displayed on top of your profile page.

```bash
# Create the special repo — name must match the username exactly
gh repo create ameertechy/ameertechy --public --add-readme --description "My GitHub profile README"

# Clone it, edit the README, push
gh repo clone ameertechy/ameertechy
cd ameertechy
```

**What I put in it** (kept it ~20 lines, headers and bullets, no badge Christmas tree):

```markdown
# Hi, I'm Ameerul Mujahidin 👋

🔧 IT Support / Systems Engineer (7 years) → moving into **DevOps**, one day at a time
📚 Currently doing **#90DaysOfDevOps** — learning in public, every single day

## 🚀 What I'm working on
- [90DaysOfDevOps](https://github.com/ameertechy/90DaysOfDevOps) — daily notes, hands-on labs, and screenshots from the challenge

## 🧰 Tools I'm learning (and being honest about it)
- **Comfortable:** Linux basics, troubleshooting, ticketing/ITSM workflows
- **Learning now:** Git & GitHub, Shell scripting, Python, GitHub CLI
- **Coming up:** Docker, Kubernetes, CI/CD, AWS

## 📫 Reach me
- LinkedIn: linkedin.com/in/ameerul-mujahidin
```

```bash
git add README.md
git commit -m "Add profile README"
git push
```

Refreshed my profile — and the README is now the first thing anyone sees. Ten minutes of work, completely different first impression.

---

## Task 3 — Organizing the Repositories

The rule I applied to **every repo**: hyphenated lowercase name + one-line description + README + `.gitignore`.

```bash
# See everything I have, with descriptions, in one shot
gh repo list ameertechy --limit 50 --json name,description,visibility

# Add/fix a description without opening the browser
gh repo edit ameertechy/90DaysOfDevOps --description "My #90DaysOfDevOps journey — daily notes, labs and screenshots"
```

**The structure I'm building toward:**

| Repo | Purpose |
|------|---------|
| `90DaysOfDevOps` | The challenge itself — daily submissions organized by day |
| `shell-scripts` | Shell scripting work from Days 16–21, README lists each script |
| `python-scripts` | Python work from Days 7–15, README lists each script |
| `devops-notes` | Cheat sheets and references — `git-commands.md`, shell cheat sheet, organized by topic |

**Naming lesson:** `shell-scripts`, not `Shell Scripts`. Hyphens, lowercase, descriptive. A repo name is an interface — it should be predictable and clean.

---

## Task 4 — Pinning the Best 6

GitHub profile → **Customize your pins** → selected deliberately instead of letting GitHub choose.

My pinning logic: show the *journey*, not just code —
1. `ameertechy` (profile README repo — shows on profile anyway, pin optional)
2. `90DaysOfDevOps` — the main proof-of-work
3. `shell-scripts` — practical scripting evidence
4. `python-scripts` — programming foundation
5. `devops-notes` — shows I document what I learn
6. (Space reserved — future Docker/K8s project will earn this slot)

**Check before pinning:** every pinned repo must have a description + README. A pinned repo with neither is worse than not pinning at all.

---

## Task 5 — Cleanup

```bash
# Find the dead weight
gh repo list ameertechy --limit 50 --json name,description,pushedAt

# Archive (NOT delete) — repo becomes read-only but history is preserved
gh repo archive ameertechy/old-test-repo --yes

# Rename a repo with an unclear name
gh repo rename new-clear-name --repo ameertechy/unclear-name

# Delete only when truly worthless (needs delete_repo scope)
gh repo delete ameertechy/empty-junk --yes
```

**My rule:** archive > delete. Archiving keeps history but signals "no longer active". Delete only for empty/accidental repos.

### Secrets check (the part most people skip)

Deleting a secret from the latest commit does **nothing** — it lives in history forever.

```bash
# Search the FULL history for sensitive strings
git log -p | grep -iE "password|secret|api[_-]?key|token" 

# Search for when a specific string was added/removed
git log -S "PASSWORD" --oneline

# Check for risky files in history
git log --all --oneline --name-only | grep -iE "\.env|\.pem|id_rsa"
```

Result on my repos: clean — no `.env`, keys, or credentials in any history. The real lesson: **prevention** — `.gitignore` for `.env`/keys from day one, because cleaning history later (`git filter-repo`) means rewriting and force-pushing everything.

---

## Task 6 — Before & After

Screenshots in [`screenshots/`](./screenshots/):
- **Before** — blank profile README, no deliberate pins, bare bios and descriptions
- **After** — profile README live, 6 chosen pins, every repo described

### 3 things I improved and why

1. **Added the profile README** — it's the first thing a visitor sees; now it tells my story in 10 seconds: support engineer, 7 years, transitioning to DevOps in public, here's the proof.
2. **Wrote a one-line description on every repo** — a stranger (or recruiter) should never have to open a repo to know what it's for. 5 seconds of clarity per repo.
3. **Took control of the pins** — first impressions were being decided by GitHub's defaults. Now the 6 pins show a deliberate journey: challenge → scripts → notes.

---

## Key Takeaways

| Lesson | Why it matters |
|--------|---------------|
| `username/username` repo = profile front page | Highest-leverage 10 minutes on GitHub |
| Descriptions + READMEs everywhere | Undocumented work is invisible work |
| Pin deliberately | Don't let defaults make your first impression |
| Archive > delete | Preserve history, signal inactivity |
| Secrets live in history, not just files | `.gitignore` from day one; audit with `git log -p` / `git log -S` |
| The profile is the portfolio | For a career changer, it's evidence — certificates say "studied", commits say "does" |

---

*#90DaysOfDevOps 2026*
