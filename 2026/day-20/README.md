# Day 20 – Shell Scripting Cheat Sheet

## Overview

Day 21 closes the shell scripting chapter with a consolidation task — building a personal reference guide from everything covered in Days 16–20.

The best way to confirm understanding is to write it in your own words. This cheat sheet is not a copy of documentation — it is a distillation of what I actually used, what tripped me up, and what I will reach for in production.

---

## What I Produced

- [`shell_scripting_cheatsheet.md`](./shell_scripting_cheatsheet.md)

---

## What This Cheat Sheet Covers

| Section | Key Items |
|---------|-----------|
| Quick reference table | All major syntax at a glance |
| Basics | Shebang, variables, input, arguments |
| Operators and conditionals | Comparisons, if-elif-else, case |
| Loops | for, while, until, break, continue |
| Functions | Definition, arguments, local, return |
| Text processing | grep, awk, sed, sort, uniq, cut |
| Real-world patterns | Service checks, disk alerts, log tailing |
| Error handling | set flags, exit codes, trap |

---

## Why This Matters Going Forward

Shell scripting is not just a Linux topic — it underpins every DevOps tool:

- **Docker** — `CMD`, `ENTRYPOINT`, and `RUN` instructions in Dockerfiles are shell commands
- **CI/CD** — GitHub Actions `run:` steps execute bash scripts
- **Ansible** — `shell` and `command` modules run bash
- **Kubernetes** — liveness and readiness probes use shell scripts
- **Terraform** — `local-exec` provisioners run bash

Every day from Day 22 onwards, this cheat sheet is the reference.

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#ShellScripting` `#Linux` `#DevOps`
