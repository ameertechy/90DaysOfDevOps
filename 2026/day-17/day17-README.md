# Day 17 – Shell Scripting: Loops, Arguments and Error Handling

## Overview

Day 17 takes shell scripting from single-purpose scripts to reusable, robust automation.

Loops eliminate repetition — the same logic runs for every item in a list without copying code. Arguments make scripts flexible — the same script works for any input without editing the file. Error handling makes scripts safe — a failed step is caught and reported instead of silently continuing and causing bigger problems downstream.

These three concepts together are what separates a one-time script from a production automation tool.

---

## What I Produced

- [`day-17-scripting.md`](./day-17-scripting.md)
- Scripts: `for_loop.sh`, `count.sh`, `countdown.sh`, `greet.sh`, `args_demo.sh`, `install_packages.sh`, `safe_script.sh`

---

## Key Observations

**`for` and `while` loops serve different purposes.**
`for` loops iterate over a known list — "do this for each item." `while` loops continue as long as a condition is true — "keep doing this until something changes." In production scripts, `for` handles batch operations (install these packages, process these files). `while` handles monitoring and retry logic (keep checking until the service is up).

**`$1`, `$2`, `$#`, `$@` — arguments turn scripts into tools.**
Without arguments, a script is hardcoded. With arguments, one script handles any input. `$1` is the first argument. `$#` is the count — used to validate that the right number of arguments was provided. `$@` is all arguments — used when passing them to another command.

**`set -e` is a safety net, not a substitute for proper error handling.**
`set -e` exits the script immediately when any command fails. Without it, a failed `mkdir` followed by a `cd` into the non-existent directory causes unpredictable behaviour. In production scripts, always start with `set -e` — and use `||` for steps where failure should be handled specifically rather than just exiting.

**Root check is mandatory in system scripts.**
Any script that installs packages, modifies system files, or manages services must verify it is running as root before doing anything. Failing silently with partial execution is worse than failing immediately with a clear message.

---

## Real-World Tie-in

- `install_packages.sh` pattern is exactly how Ansible's `apt` module works internally — check if installed, skip if present, install if missing
- `safe_script.sh` with `set -e` is the standard pattern for CI/CD deployment scripts — stop on first failure, never continue with a broken state
- `args_demo.sh` argument pattern is what every CLI tool follows — `./deploy.sh staging nginx 3` passes environment, service, replica count as positional arguments
- The countdown `while` loop is the retry pattern used in health check scripts — keep trying until the service responds or the timeout is reached

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#ShellScripting` `#Linux` `#DevOps`
