# Day 16 – Shell Scripting Basics

## Overview

Day 16 starts the scripting chapter — the area Shubham introduced conceptually in the Day 9 live session.

I am new to shell scripting as a formal practice. I use bash commands daily but I have never written structured scripts with variables, conditionals, and user input. Today I built the foundation: shebang, variables, `read`, and `if-else` — the building blocks every shell script uses.

---

## What I Produced

- [`day-16-shell-scripting.md`](./day-16-shell-scripting.md)
- Scripts: `hello.sh`, `variables.sh`, `greet.sh`, `check_number.sh`, `file_check.sh`, `server_check.sh`

---

## Key Observations

**The shebang is not optional.**
Without `#!/bin/bash`, the OS does not know which interpreter to use. It may default to `sh` which behaves differently from `bash` — some bash features simply do not work. Always include the shebang as the first line.

**No spaces around `=` in variable assignment.**
`NAME="Ameerul"` works. `NAME = "Ameerul"` fails — bash sees `NAME` as a command, not an assignment. This is the most common beginner error in shell scripting and also one I made during today's practice.

**Single quotes vs double quotes are different.**
Double quotes `"$NAME"` expand variables — the value is substituted. Single quotes `'$NAME'` treat everything literally — `$NAME` prints as-is. This matters when building strings that include variable values.

**`if` blocks in bash have strict syntax.**
Spaces inside `[ ]` are mandatory. `[$NAME]` fails. `[ $NAME ]` works. The `fi` at the end is required. Coming from other languages this feels unusual but it becomes automatic quickly.

---

## Real-World Tie-in

- `server_check.sh` is the pattern behind every monitoring script and health check in production
- The `if [ -f filename ]` check is used in deployment scripts to verify config files exist before a service restarts
- `read -p` for user input is how interactive setup scripts work — the same pattern in MySQL secure install, Certbot, and many other tools

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#ShellScripting` `#Linux` `#DevOps`
