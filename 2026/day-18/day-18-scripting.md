# Shell Scripting: Functions and Intermediate Concepts
*#90DaysOfDevOps 2026*

---

## What is a Function in Bash?

A function is a named block of commands that can be called by name, given arguments, and reused as many times as needed without rewriting the logic.

**Why functions matter:**
Without functions, a 200-line script is one long sequence. If you need to check disk usage in three places, you write those 3 lines three times. Change the format — update three locations. One missed location = inconsistent output.

With functions, disk check logic lives in one place. Called three times — updated once.

---

## Task 1 — Basic Functions: `functions.sh`

```bash
#!/bin/bash
set -euo pipefail

# Function definition
# greet takes one argument — the name to greet
greet() {
  echo "Hello, $1!"
}

# Function that adds two numbers
add() {
  local RESULT=$(( $1 + $2 ))
  echo "Sum of $1 + $2 = $RESULT"
}

# Call the functions
greet "Ameerul"
greet "DevOps"
add 10 25
add 100 200
```

**Function syntax — every part:**
```bash
function_name() {
  # commands
}
```

- `function_name` = the name you choose — no spaces, no special characters
- `()` = tells bash this is a function definition — empty, arguments come through `$1`, `$2` etc.
- `{` = start of function body
- `}` = end of function body

**How to call a function:**
```bash
greet "Ameerul"
```
This passes `"Ameerul"` as `$1` inside the function. Exactly like calling a script with an argument.

**`$(( $1 + $2 ))` reminder:**
`$(( ))` = arithmetic expansion — evaluates the expression as a number. Without it, `$1 + $2` is treated as a string — `"10 + 25"`, not `35`.

**Run it:**
```bash
chmod +x functions.sh && ./functions.sh
# Hello, Ameerul!
# Hello, DevOps!
# Sum of 10 + 25 = 35
# Sum of 100 + 200 = 300
```

---

## Task 2 — Functions with Return Values: `disk_check.sh`

```bash
#!/bin/bash
set -euo pipefail

check_disk() {
  echo "--- Disk Usage ---"
  df -h / | awk 'NR==2 {print "Used: "$3" / "$2" ("$5" used)"}'
}

check_memory() {
  echo "--- Memory Usage ---"
  free -h | awk '/^Mem:/ {print "Used: "$3" / "$2" | Available: "$7}'
}

# Main section — call both functions
check_disk
echo ""
check_memory
```

**`awk 'NR==2 {print ...}'` explained:**
- `awk` = processes text line by line, column by column
- `NR==2` = only process line number 2 (the data row, skip header)
- `$3`, `$2`, `$5` = third, second, fifth columns of that line
- `df -h /` has header on line 1, data on line 2 — `NR==2` skips the header

**`awk '/^Mem:/ {print ...}'` explained:**
- `/^Mem:/` = pattern match — only process lines that start with `Mem:`
- `^` = start of line in regex
- `free -h` outputs `Mem:` and `Swap:` rows — this targets only `Mem:`

**Why functions don't use `return` for text output:**
In bash, `return` only passes a number (0–255) — the exit status. To return text from a function, `echo` the value and capture it with command substitution:
```bash
get_hostname() {
  echo "$(hostname)"
}
HOST=$(get_hostname)    # captures the echo output
echo "Host is: $HOST"
```

**Run it:**
```bash
chmod +x disk_check.sh && ./disk_check.sh
# --- Disk Usage ---
# Used: 7.4G / 23G (35% used)
#
# --- Memory Usage ---
# Used: 583M / 3.9G | Available: 3.3G
```

---

## Task 3 — Strict Mode: `strict_demo.sh`

```bash
#!/bin/bash
set -euo pipefail

echo "=== set -e demo ==="
# set -e: exit immediately when any command returns non-zero exit code
# Uncomment the line below to see it in action:
# cat /file/that/does/not/exist
# Script would stop here if uncommented

echo "=== set -u demo ==="
# set -u: treat unset variables as errors
# Uncomment to see:
# echo $UNDEFINED_VAR
# Error: UNDEFINED_VAR: unbound variable

echo "=== set -o pipefail demo ==="
# Without pipefail: failing_command | grep "something" returns 0 (success)
# because grep succeeded even though the first command failed
# With pipefail: the pipe returns the exit code of the FIRST failed command

echo "=== All flags working ==="
NAME="Ameerul"
echo "Name: $NAME"
echo "Strict mode script completed successfully"
```

**The three flags — commit these to memory:**

| Flag | What it does | Without it |
|------|-------------|-----------|
| `set -e` | Exit immediately on any error | Script continues even after failures |
| `set -u` | Error on undefined variable | Undefined variable = empty string silently |
| `set -o pipefail` | Pipe fails if any stage fails | Pipe succeeds if last command succeeds |

**Real example of why `set -o pipefail` matters:**
```bash
# Without pipefail:
cat /nonexistent | grep "something"
echo $?   # returns 0 — grep succeeded even though cat failed
# Script thinks everything is fine

# With pipefail:
set -o pipefail
cat /nonexistent | grep "something"
# Script exits immediately — the pipe failure is caught
```

**`set -euo pipefail` as one line:**
```bash
set -euo pipefail
# same as:
set -e
set -u
set -o pipefail
```

Always use the combined form — cleaner and standard in production scripts.

**Run it:**
```bash
chmod +x strict_demo.sh && ./strict_demo.sh
# === set -e demo ===
# === set -u demo ===
# === set -o pipefail demo ===
# === All flags working ===
# Name: Ameerul
# Strict mode script completed successfully
```

---

## Task 4 — Local Variables: `local_demo.sh`

```bash
#!/bin/bash
set -euo pipefail

# Function WITH local — safe
safe_function() {
  local MESSAGE="I am local"
  local COUNT=42
  echo "Inside safe_function: MESSAGE=$MESSAGE, COUNT=$COUNT"
}

# Function WITHOUT local — leaks into global scope
unsafe_function() {
  LEAKED_VAR="I leaked out!"
  echo "Inside unsafe_function: LEAKED_VAR=$LEAKED_VAR"
}

# Call safe function
safe_function
echo "Outside safe_function: MESSAGE=${MESSAGE:-not set}"
# MESSAGE is not set outside — local worked

# Call unsafe function
unsafe_function
echo "Outside unsafe_function: LEAKED_VAR=$LEAKED_VAR"
# LEAKED_VAR is visible outside — it leaked
```

**`${MESSAGE:-not set}` explained:**
- `${VAR:-default}` = use `VAR` if set, otherwise use `"default"`
- Used here to safely reference a variable that may not exist without `set -u` crashing the script

**Why `local` matters in real scripts:**

```bash
# Without local — silent bug example
process_user() {
  NAME="temporary"     # overwrites the global NAME!
  echo "Processing: $NAME"
}

NAME="Ameerul"
echo "Before: $NAME"   # Ameerul
process_user
echo "After: $NAME"    # temporary — silently overwritten
```

```bash
# With local — safe
process_user() {
  local NAME="temporary"   # exists only inside this function
  echo "Processing: $NAME"
}

NAME="Ameerul"
echo "Before: $NAME"   # Ameerul
process_user
echo "After: $NAME"    # Ameerul — unchanged
```

**Rule:** Every variable inside a function that should not affect the outside world gets `local`. Always. No exceptions.

**Run it:**
```bash
chmod +x local_demo.sh && ./local_demo.sh
# Inside safe_function: MESSAGE=I am local, COUNT=42
# Outside safe_function: MESSAGE=not set
# Inside unsafe_function: LEAKED_VAR=I leaked out!
# Outside unsafe_function: LEAKED_VAR=I leaked out!
```

---

## Task 5 — System Info Reporter: `system_info.sh`

```bash
#!/bin/bash
set -euo pipefail

# ─────────────────────────────────────────
# Function: print section header
# ─────────────────────────────────────────
print_header() {
  echo ""
  echo "========================================"
  echo "  $1"
  echo "========================================"
}

# ─────────────────────────────────────────
# Function: hostname and OS info
# ─────────────────────────────────────────
system_info() {
  print_header "System Information"
  echo "Hostname : $(hostname)"
  echo "OS       : $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')"
  echo "Kernel   : $(uname -r)"
  echo "Arch     : $(uname -m)"
}

# ─────────────────────────────────────────
# Function: uptime
# ─────────────────────────────────────────
uptime_info() {
  print_header "Uptime"
  uptime -p
  echo "Load average: $(uptime | awk -F'load average:' '{print $2}')"
}

# ─────────────────────────────────────────
# Function: disk usage — top 5 by size
# ─────────────────────────────────────────
disk_info() {
  print_header "Disk Usage"
  df -h | grep -v tmpfs | awk 'NR==1 || NR>1 {print}' | head -8
}

# ─────────────────────────────────────────
# Function: memory usage
# ─────────────────────────────────────────
memory_info() {
  print_header "Memory Usage"
  free -h | awk '
    /^Mem:/ {print "RAM   - Total: "$2"  Used: "$3"  Available: "$7}
    /^Swap:/ {print "Swap  - Total: "$2"  Used: "$3"  Free: "$4}
  '
}

# ─────────────────────────────────────────
# Function: top 5 CPU processes
# ─────────────────────────────────────────
top_processes() {
  print_header "Top 5 CPU Processes"
  ps aux --sort=-%cpu | awk 'NR==1 || NR<=6 {printf "%-10s %-6s %-6s %s\n", $1, $2, $3, $11}' | head -6
}

# ─────────────────────────────────────────
# Function: service status check
# ─────────────────────────────────────────
service_status() {
  print_header "Service Status"
  local SERVICES="nginx ssh docker"
  for SERVICE in $SERVICES; do
    local STATUS
    STATUS=$(systemctl is-active "$SERVICE" 2>/dev/null || echo "unknown")
    printf "%-10s : %s\n" "$SERVICE" "$STATUS"
  done
}

# ─────────────────────────────────────────
# Main — calls all functions in order
# ─────────────────────────────────────────
main() {
  echo "========================================="
  echo "  SYSTEM INFO REPORT"
  echo "  Generated: $(date)"
  echo "========================================="

  system_info
  uptime_info
  disk_info
  memory_info
  top_processes
  service_status

  echo ""
  echo "========================================="
  echo "  END OF REPORT"
  echo "========================================="
}

# Script entry point — call main
main
```

**New things explained:**

**`printf "%-10s %-6s %-6s %s\n" ...`:**
- `printf` = formatted print — more control than `echo`
- `%-10s` = left-aligned string field, 10 characters wide
- The `-` means left-align. Without it: right-aligned.
- This makes columns line up cleanly regardless of the value length

**`awk 'NR==1 || NR<=6 {printf ...}'`:**
- `NR==1` = print the header line
- `||` = OR
- `NR<=6` = print lines 2 through 6 (top 5 processes after header)
- Combined: print header + first 5 data rows

**`main()` as the entry point:**
This is a common pattern in production scripts — all logic lives in functions, and `main` is the only thing called at the script level. This makes the script readable (you scan function names to understand what it does) and testable (you can call individual functions independently).

**Run it:**
```bash
chmod +x system_info.sh && ./system_info.sh
```

---

## 3 Key Learnings

**1. `local` inside every function — no exceptions.**
Global variable leaks from functions cause silent bugs in long scripts. Use `local` for every variable that belongs to a function. Only variables that intentionally need to be global should live outside.

**2. Functions receive arguments as `$1`, `$2` — same as scripts.**
`greet "Ameerul"` makes `$1 = "Ameerul"` inside the function. These are local to the function call — the script's own `$1` is unaffected. One naming system, two contexts.

**3. Structure scripts as: functions first, `main()` last, call `main` at the bottom.**
This makes any script readable at a glance. Scan the function names — you understand the script's purpose without reading a single command. `main` shows you the sequence. Specific functions show you the detail.

---

*#90DaysOfDevOps 2026*
