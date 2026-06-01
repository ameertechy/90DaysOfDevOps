# Shell Scripting: Loops, Arguments and Error Handling
*#90DaysOfDevOps 2026*

---

## Task 1 — For Loop

### `for_loop.sh` — Iterate Over a List

```bash
#!/bin/bash

FRUITS="apple banana mango orange grape"

for FRUIT in $FRUITS; do
  echo "Fruit: $FRUIT"
done
```

**`for` loop structure:**
```bash
for VARIABLE in list_of_items; do
  # commands using $VARIABLE
done
```

**How it works step by step:**
1. `for FRUIT in $FRUITS` — bash splits `$FRUITS` on whitespace into individual words
2. First iteration: `FRUIT="apple"` — everything between `do` and `done` runs
3. Second iteration: `FRUIT="banana"` — runs again
4. Continues until all items are processed
5. `done` signals the end of the loop body

**`do` and `done`:**
- `do` = start of the loop body
- `done` = end of the loop body
- Everything between these two runs for each iteration

**Run it:**
```bash
chmod +x for_loop.sh && ./for_loop.sh
# Fruit: apple
# Fruit: banana
# Fruit: mango
# Fruit: orange
# Fruit: grape
```

---

### `count.sh` — Loop With a Range

```bash
#!/bin/bash

for i in $(seq 1 10); do
  echo "Number: $i"
done
```

**`$(seq 1 10)` explained:**
- `seq 1 10` = generates a sequence of numbers from 1 to 10, one per line
- `$(...)` = command substitution — the output of `seq` is used as the list for `for`
- Result: `for i in 1 2 3 4 5 6 7 8 9 10`

**Alternative using C-style syntax:**
```bash
for ((i=1; i<=10; i++)); do
  echo "Number: $i"
done
```
- `i=1` — start value
- `i<=10` — continue while this is true
- `i++` — increment by 1 each iteration

---

## Task 2 — While Loop

### `countdown.sh` — Loop Until Condition Is False

```bash
#!/bin/bash

read -p "Enter a number to count down from: " NUM

while [ $NUM -ge 0 ]; do
  echo "$NUM"
  NUM=$((NUM - 1))
done

echo "Done!"
```

**`while` loop structure:**
```bash
while [ condition ]; do
  # commands
done
```

The loop runs as long as the condition is true. When the condition becomes false, the loop exits and execution continues after `done`.

**`$((NUM - 1))` — arithmetic in bash:**
- `$(( ))` = arithmetic expansion — evaluates the expression inside as a number
- `NUM=$((NUM - 1))` = subtract 1 from NUM and store the result back in NUM
- Without `$(( ))`: `NUM=$NUM - 1` would produce the string `"5 - 1"` not the number 4

**Common arithmetic operators:**

| Operator | Meaning | Example |
|----------|---------|---------|
| `+` | Add | `$((5 + 3))` = 8 |
| `-` | Subtract | `$((5 - 3))` = 2 |
| `*` | Multiply | `$((5 * 3))` = 15 |
| `/` | Divide (integer) | `$((10 / 3))` = 3 |
| `%` | Modulo (remainder) | `$((10 % 3))` = 1 |

**Infinite loop and break:**
```bash
while true; do
  echo "Running..."
  sleep 1
  break    # exit the loop
done
```
`while true` runs forever. `break` exits immediately. Used in retry loops and monitoring scripts.

---

## Task 3 — Command-Line Arguments

### `greet.sh` — Accept Arguments

```bash
#!/bin/bash

if [ $# -eq 0 ]; then
  echo "Usage: ./greet.sh <name>"
  exit 1
fi

echo "Hello, $1!"
```

**Special argument variables:**

| Variable | Meaning | Example (./script.sh Ameer DevOps) |
|----------|---------|-------------------------------------|
| `$0` | Script name | `./greet.sh` |
| `$1` | First argument | `Ameer` |
| `$2` | Second argument | `DevOps` |
| `$#` | Total argument count | `2` |
| `$@` | All arguments as separate words | `Ameer DevOps` |
| `$*` | All arguments as one string | `"Ameer DevOps"` |

**`exit 1` explained:**
- `exit` = terminate the script immediately
- `exit 0` = success (convention: 0 = no error)
- `exit 1` = failure (convention: any non-zero = error)
- The exit code is stored in `$?` — the last command's exit status
- CI/CD systems check exit codes — `exit 1` marks the pipeline step as failed

**Run it:**
```bash
chmod +x greet.sh

./greet.sh
# Usage: ./greet.sh <name>

./greet.sh Ameerul
# Hello, Ameerul!
```

---

### `args_demo.sh` — Inspect All Arguments

```bash
#!/bin/bash

echo "Script name: $0"
echo "Total arguments: $#"
echo "All arguments: $@"
echo ""

echo "Individual arguments:"
for ARG in "$@"; do
  echo "  - $ARG"
done
```

**`"$@"` vs `$@`:**
- `$@` without quotes: if an argument contains spaces, it splits into multiple words
- `"$@"` with quotes: each argument is kept as one unit, even with spaces
- Always use `"$@"` when looping over arguments

**Run it:**
```bash
chmod +x args_demo.sh
./args_demo.sh nginx docker kubernetes
# Script name: ./args_demo.sh
# Total arguments: 3
# All arguments: nginx docker kubernetes
# Individual arguments:
#   - nginx
#   - docker
#   - kubernetes
```

---

## Task 4 — Install Packages Via Script

### `install_packages.sh`

```bash
#!/bin/bash

# Root check — must run as root
if [ "$EUID" -ne 0 ]; then
  echo "Error: This script must be run as root."
  echo "Usage: sudo ./install_packages.sh"
  exit 1
fi

PACKAGES="nginx curl wget"

for PACKAGE in $PACKAGES; do
  if dpkg -s "$PACKAGE" > /dev/null 2>&1; then
    echo "$PACKAGE: already installed — skipping"
  else
    echo "$PACKAGE: not found — installing..."
    apt-get install -y "$PACKAGE"
    echo "$PACKAGE: installed successfully"
  fi
done
```

**`$EUID` explained:**
- `EUID` = Effective User ID — a special bash variable that holds the current user's UID
- Root always has UID 0
- `[ "$EUID" -ne 0 ]` = "if effective UID is not equal to 0" = not running as root

**`dpkg -s "$PACKAGE" > /dev/null 2>&1` explained:**
- `dpkg -s package` = query the package status — exits 0 if installed, non-zero if not
- `> /dev/null` = discard stdout (the package info output)
- `2>&1` = redirect stderr to the same place — discard error messages too
- The `if` only cares about the exit code — installed (0) = true, not installed = false

**Run it:**
```bash
chmod +x install_packages.sh
sudo ./install_packages.sh
# nginx: already installed — skipping
# curl: already installed — skipping
# wget: not found — installing...
# wget: installed successfully
```

---

## Task 5 — Error Handling

### `safe_script.sh`

```bash
#!/bin/bash
set -e    # exit immediately if any command fails
set -u    # treat unset variables as errors
set -o pipefail   # catch errors in pipelines

echo "Starting safe script..."

# Create directory — handle failure gracefully with ||
mkdir /tmp/devops-test || echo "Directory already exists — continuing"

# Navigate into it
cd /tmp/devops-test

# Create a file
touch devops-file.txt
echo "Created: /tmp/devops-test/devops-file.txt"

echo "Script completed successfully"
```

**`set` flags explained:**

| Flag | Meaning | Why Use It |
|------|---------|-----------|
| `set -e` | Exit on error | Stops script at first failure — prevents cascading errors |
| `set -u` | Error on unset variable | Catches typos — `$NAEM` instead of `$NAME` fails immediately |
| `set -o pipefail` | Catch pipe failures | Without this, `failing_cmd \| grep x` returns 0 (success) because grep succeeded |

**`||` operator in error handling:**
```bash
mkdir /tmp/devops-test || echo "Directory already exists"
```
- `||` = OR — runs the right side only if the left side FAILS
- If `mkdir` succeeds: "Directory already exists" is NOT printed
- If `mkdir` fails (dir exists): "Directory already exists" IS printed
- Execution continues either way — the error is handled, not fatal

**`&&` vs `||` — complete picture:**

| Operator | Runs right side when | Use case |
|----------|---------------------|---------|
| `&&` | Left side SUCCEEDS | Chain dependent commands |
| `\|\|` | Left side FAILS | Handle errors, provide fallback |

```bash
# Real example combining both
mkdir /tmp/mydir && cd /tmp/mydir && echo "Ready" || echo "Setup failed"
```

**Run it:**
```bash
chmod +x safe_script.sh
./safe_script.sh
# Starting safe script...
# Created: /tmp/devops-test/devops-file.txt
# Script completed successfully

# Run again
./safe_script.sh
# Starting safe script...
# Directory already exists — continuing
# Created: /tmp/devops-test/devops-file.txt
# Script completed successfully
```

---

## 3 Key Learnings

**1. `$#` validates arguments — always check before using `$1`.**
If a script uses `$1` without checking `$#`, passing no argument causes unexpected behaviour. Check `$#` first and show usage if wrong — this is the standard pattern in every production CLI tool.

**2. `set -e` + `set -u` + `set -o pipefail` together.**
These three lines at the top of every production script prevent the most common silent failures. A single `set -euo pipefail` covers all three.

**3. `||` for fallback, `&&` for dependency.**
`cmd1 && cmd2` = cmd2 only if cmd1 succeeds. `cmd1 || cmd2` = cmd2 only if cmd1 fails. Together they replace most simple try-catch patterns.

---

*#90DaysOfDevOps 2026*
