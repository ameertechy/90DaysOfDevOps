# Day 18 – Shell Scripting: Functions and Intermediate Concepts

## Overview

Day 18 takes shell scripting to the next level — functions, local variables, strict mode, and building a clean system info reporter.

Functions are what turn a collection of commands into reusable, maintainable automation. Without functions, scripts grow into long linear files where the same logic is repeated in multiple places. One change needs updating in every location. With functions, logic is defined once and called wherever needed.

---

## What I Produced

- [`day-18-scripting.md`](./day-18-scripting.md)

---

## Key Observations

**Functions eliminate repetition and make scripts readable.**
The `system_info.sh` script calls 5 functions from a `main` function. Each function does one job. Adding a new section means adding one function and one `main` call — nothing else changes.

**`local` variables are not optional — they are safety.**
Without `local`, a variable defined inside a function exists in the global scope. A later function or line of code can accidentally overwrite it. With `local`, the variable is destroyed when the function exits. In long scripts with many functions, this prevents silent bugs that are extremely hard to trace.

**`set -euo pipefail` turns bash from permissive to strict.**
By default bash ignores errors and continues. `set -e` stops on any error. `set -u` stops on any undefined variable. `set -o pipefail` stops when any part of a pipe fails. Together they make scripts behave like a real programming language with error propagation — not a sequence of commands that silently continues after failures.

**Functions in bash pass arguments the same way scripts do.**
`$1`, `$2`, `$@`, `$#` work identically inside a function — they refer to the function's arguments, not the script's. This is intuitive once you understand it but confusing at first because the same variable names serve double duty depending on context.

---

## Real-World Tie-in

- `system_info.sh` is the foundation of every monitoring and health check script — same structure used in production runbooks and on-call automation
- Function-based scripts are what Ansible roles look like internally — tasks grouped by function, called in sequence
- `set -euo pipefail` is mandatory in CI/CD pipeline scripts — a failed step must stop the pipeline, not silently continue to the next stage
- `local` variables matter especially in recursive functions and complex scripts where variable name collisions cause unpredictable behaviour

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#ShellScripting` `#Linux` `#DevOps`
