# Shell Scripting Cheat Sheet
*#90DaysOfDevOps 2026 | Personal Reference | Days 16–20*

---

## Quick Reference Table

| Topic | Key Syntax | Example |
|-------|-----------|---------|
| Shebang | `#!/bin/bash` | First line of every script |
| Variable | `VAR="value"` | `NAME="Ameerul"` |
| Use variable | `$VAR` or `"$VAR"` | `echo "$NAME"` |
| Argument | `$1`, `$2`, `$#`, `$@` | `./script.sh arg1 arg2` |
| User input | `read -p "prompt" VAR` | `read -p "Name: " NAME` |
| If | `if [ condition ]; then` | `if [ -f file ]; then` |
| For loop | `for i in list; do` | `for i in 1 2 3; do` |
| While loop | `while [ condition ]; do` | `while [ $N -gt 0 ]; do` |
| Function | `name() { ... }` | `greet() { echo "Hi $1"; }` |
| Local var | `local VAR="value"` | `local RESULT=0` |
| Arithmetic | `$(( expr ))` | `SUM=$((A + B))` |
| Command sub | `$(command)` | `HOST=$(hostname)` |
| Grep | `grep "pattern" file` | `grep -n "ERROR" app.log` |
| Awk | `awk '{print $1}' file` | `awk '{$1=$2=""; print}' log` |
| Sed | `sed 's/old/new/g' file` | `sed -i 's/foo/bar/g' file` |
| Strict mode | `set -euo pipefail` | Top of every production script |
| Exit code | `exit 0` / `exit 1` | `exit 1` = failure |

---

## Section 1 — Basics

### Shebang

```bash
#!/bin/bash
```

Tells the OS to use `/bin/bash` as the interpreter. Without it, the system may use `sh` — which lacks bash features. Always the first line.

### Running a Script

```bash
chmod +x script.sh    # add execute permission — required for ./
./script.sh           # execute directly
bash script.sh        # pass to bash — no execute permission needed
```

### Comments

```bash
# This is a full-line comment
echo "Hello"  # This is an inline comment

# Comments are ignored by bash — use them to explain why, not what
```

### Variables

```bash
# Declare — no spaces around =
NAME="Ameerul"
COUNT=42
IS_ROOT=false

# Use — prefix with $
echo "$NAME"
echo "Count is: $COUNT"

# Double quotes — expand variables
echo "Hello $NAME"    # Hello Ameerul

# Single quotes — literal, no expansion
echo 'Hello $NAME'    # Hello $NAME

# Always quote variables — prevents word splitting
echo "$NAME"          # safe even if NAME contains spaces
echo $NAME            # unsafe if NAME has spaces
```

### Reading User Input

```bash
read -p "Enter your name: " USERNAME
# -p = prompt text displayed before waiting
# Result stored in USERNAME

read -sp "Password: " PASSWORD
# -s = silent — input not echoed (for passwords)

echo "Hello, $USERNAME"
```

### Command-Line Arguments

```bash
./script.sh first second third
```

| Variable | Value | Meaning |
|----------|-------|---------|
| `$0` | `./script.sh` | Script name |
| `$1` | `first` | First argument |
| `$2` | `second` | Second argument |
| `$#` | `3` | Total argument count |
| `$@` | `first second third` | All arguments (quoted separately) |
| `$?` | `0` or `1` | Exit code of last command |

```bash
# Always validate arguments
if [ $# -eq 0 ]; then
  echo "Usage: $0 <argument>"
  exit 1
fi
echo "Argument: $1"
```

---

## Section 2 — Operators and Conditionals

### String Comparisons

```bash
[ "$A" = "$B" ]    # equal
[ "$A" != "$B" ]   # not equal
[ -z "$A" ]        # zero length (empty)
[ -n "$A" ]        # non-zero length (not empty)
```

### Integer Comparisons

```bash
[ $A -eq $B ]    # equal
[ $A -ne $B ]    # not equal
[ $A -lt $B ]    # less than
[ $A -gt $B ]    # greater than
[ $A -le $B ]    # less than or equal
[ $A -ge $B ]    # greater than or equal
```

### File Test Operators

```bash
[ -f "$FILE" ]    # exists and is a regular file
[ -d "$DIR" ]     # exists and is a directory
[ -e "$PATH" ]    # exists (any type)
[ -r "$FILE" ]    # exists and readable
[ -w "$FILE" ]    # exists and writable
[ -x "$FILE" ]    # exists and executable
[ -s "$FILE" ]    # exists and not empty
```

### if / elif / else

```bash
if [ condition ]; then
  # runs when condition is true
elif [ other_condition ]; then
  # runs when first false, this true
else
  # runs when all conditions false
fi
```

```bash
# Real example
if [ ! -f "$CONFIG" ]; then
  echo "Error: Config not found"
  exit 1
fi
```

### Logical Operators

```bash
# AND — both must be true
if [ $A -gt 0 ] && [ $A -lt 100 ]; then echo "In range"; fi

# OR — at least one must be true
if [ "$STATUS" = "active" ] || [ "$STATUS" = "running" ]; then echo "OK"; fi

# NOT
if [ ! -f "$FILE" ]; then echo "File missing"; fi

# Chain commands — && runs right only if left succeeds
mkdir /opt/app && cd /opt/app && echo "Ready"

# || runs right only if left FAILS
mkdir /opt/app || echo "Already exists"
```

### Case Statement

```bash
case "$CHOICE" in
  start)
    systemctl start nginx
    ;;
  stop)
    systemctl stop nginx
    ;;
  restart)
    systemctl restart nginx
    ;;
  *)
    echo "Usage: $0 start|stop|restart"
    exit 1
    ;;
esac
```

`;;` = end of each case. `*)` = default — matches anything not matched above.

---

## Section 3 — Loops

### For Loop — List

```bash
for ITEM in apple banana mango; do
  echo "Item: $ITEM"
done
```

### For Loop — Range

```bash
for i in $(seq 1 10); do
  echo "Number: $i"
done

# C-style
for ((i=1; i<=10; i++)); do
  echo "Number: $i"
done
```

### While Loop

```bash
COUNT=5
while [ $COUNT -gt 0 ]; do
  echo "Count: $COUNT"
  COUNT=$((COUNT - 1))
done
```

### Until Loop

```bash
# Runs UNTIL condition becomes true (opposite of while)
COUNT=0
until [ $COUNT -ge 5 ]; do
  echo "Count: $COUNT"
  COUNT=$((COUNT + 1))
done
```

### Break and Continue

```bash
# break — exit the loop entirely
for i in 1 2 3 4 5; do
  if [ $i -eq 3 ]; then break; fi
  echo $i
done
# Prints: 1 2

# continue — skip current iteration, continue loop
for i in 1 2 3 4 5; do
  if [ $i -eq 3 ]; then continue; fi
  echo $i
done
# Prints: 1 2 4 5
```

### Loop Over Files

```bash
# Loop over all .log files
for FILE in /var/log/*.log; do
  echo "Processing: $FILE"
done

# Safe loop over find output (handles spaces in filenames)
while IFS= read -r -d '' FILE; do
  echo "Found: $FILE"
done < <(find /var/log -name "*.log" -type f -print0)
```

### Loop Over Command Output

```bash
# Read command output line by line
while IFS= read -r LINE; do
  echo "Line: $LINE"
done < <(ps aux | grep nginx)
```

---

## Section 4 — Functions

### Define and Call

```bash
greet() {
  echo "Hello, $1!"
}

greet "Ameerul"   # call with argument
greet "DevOps"
```

### Arguments Inside Functions

`$1`, `$2`, `$#`, `$@` inside a function refer to the function's own arguments — not the script's.

```bash
add() {
  local RESULT=$(( $1 + $2 ))
  echo "$RESULT"
}
SUM=$(add 10 20)
echo "Sum: $SUM"
```

### Return Values

```bash
# return only passes an exit code (0-255)
is_running() {
  systemctl is-active "$1" > /dev/null 2>&1
  return $?    # 0 = active, non-zero = not active
}

if is_running nginx; then
  echo "nginx is running"
fi

# To return text — echo it and capture with $()
get_hostname() {
  echo "$(hostname)"
}
HOST=$(get_hostname)
```

### Local Variables

```bash
my_function() {
  local NAME="local value"    # only exists inside function
  echo "$NAME"
}
my_function
echo "${NAME:-not set}"   # not set — local was destroyed on exit
```

**Rule:** Every variable inside a function that should not affect the outside scope gets `local`. Always.

---

## Section 5 — Text Processing

### grep

```bash
grep "ERROR" file.log           # find lines with ERROR
grep -i "error" file.log        # case-insensitive
grep -n "CRITICAL" file.log     # show line numbers
grep -c "ERROR" file.log        # count matching lines
grep -v "INFO" file.log         # invert — lines NOT matching
grep -E "ERROR|Failed" file.log # regex OR
grep -r "ERROR" /var/log/       # recursive — search directory
grep -l "ERROR" /var/log/*.log  # list filenames that match, not lines
```

### awk

```bash
# Print specific columns
awk '{print $1}' file         # first column
awk '{print $1, $3}' file     # first and third

# Custom field separator
awk -F: '{print $1}' /etc/passwd   # split on :, print first field

# Pattern match
awk '/ERROR/ {print $0}' file      # print lines containing ERROR

# Skip header (line 1)
awk 'NR>1 {print}' file

# Process only specific line
awk 'NR==2 {print $5}' file        # line 2, column 5

# Blank out fields
awk '{$1=$2=$3=""; print $0}' file  # blank first 3 fields
```

### sed

```bash
sed 's/old/new/' file          # replace first match per line
sed 's/old/new/g' file         # replace all matches per line (g=global)
sed -i 's/old/new/g' file      # in-place edit (modifies the file)
sed -n '5,10p' file            # print lines 5 to 10
sed '/pattern/d' file          # delete lines matching pattern
sed -i '/test_var/d' file      # delete lines matching, in-place
sed 's/^[[:space:]]*//' file   # strip leading whitespace
```

### sort, uniq, cut, wc

```bash
sort file                      # sort alphabetically
sort -r file                   # reverse sort
sort -n file                   # numeric sort
sort -rn file                  # reverse numeric (largest first)
sort -k2 file                  # sort by second field

uniq file                      # remove adjacent duplicates
uniq -c file                   # prefix with count
sort file | uniq -c | sort -rn # count + rank — the log analysis pattern

cut -d: -f1 /etc/passwd        # split on :, take first field
cut -d: -f1,3 /etc/passwd      # take fields 1 and 3
cut -c1-10 file                # take first 10 characters per line

wc -l file                     # count lines
wc -w file                     # count words
wc -c file                     # count bytes
```

---

## Section 6 — Real-World Patterns

### Check if a Service is Running

```bash
check_service() {
  local SERVICE="$1"
  local STATUS
  STATUS=$(systemctl is-active "$SERVICE" 2>/dev/null || echo "unknown")
  if [ "$STATUS" = "active" ]; then
    echo "$SERVICE: running"
  else
    echo "$SERVICE: $STATUS"
  fi
}
check_service nginx
check_service docker
```

### Disk Usage Alert

```bash
check_disk() {
  local THRESHOLD=85
  local USAGE
  USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
  if [ "$USAGE" -gt "$THRESHOLD" ]; then
    echo "ALERT: Disk at ${USAGE}% — threshold is ${THRESHOLD}%"
    exit 1
  else
    echo "Disk OK: ${USAGE}% used"
  fi
}
```

### Tail Log for Errors in Real Time

```bash
# Stream a log and filter for errors live
tail -f /var/log/nginx/error.log | grep --line-buffered "ERROR"

# --line-buffered ensures grep flushes output immediately
# Without it, grep buffers — output only appears in chunks
```

### Process Files Safely (Handles Spaces in Names)

```bash
while IFS= read -r -d '' FILE; do
  echo "Processing: $FILE"
  gzip "$FILE"
done < <(find /var/log -name "*.log" -mtime +7 -type f -print0)
```

### Write Report with Timestamped Logging

```bash
LOG_FILE="/var/log/myscript.log"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOG_FILE"
}

log "Script started"
log "Task completed"
```

### Sudo Write to Root-Owned File

```bash
# Wrong — shell opens file with YOUR permissions before sudo runs
sudo echo "value" > /etc/file    # fails

# Correct — sudo applies to tee which does the write
echo "value" | sudo tee -a /etc/file
```

---

## Section 7 — Error Handling and Debugging

### Exit Codes

```bash
command
echo $?       # 0 = success, non-zero = failure

exit 0        # script exited successfully
exit 1        # script failed — CI/CD pipeline marks step as failed
exit 2        # custom codes — any non-zero value
```

### Strict Mode

```bash
set -e          # exit immediately on any error
set -u          # error on unset variable (catches typos)
set -o pipefail # catch failures inside pipes
# Combined:
set -euo pipefail
```

### grep Returns Exit Code 1 on Zero Matches

```bash
# With set -e active — this kills the script if no matches found
COUNT=$(grep -c "ERROR" file)

# Safe version — || true makes expression succeed even with no matches
COUNT=$(grep -c "ERROR" file || true)
```

### Debug Mode

```bash
set -x           # print every command before running it
set +x           # turn off debug mode

# Run a script in debug mode
bash -x script.sh

# Debug only a section
set -x
# commands to debug
set +x
```

### Trap — Run Cleanup on Exit

```bash
cleanup() {
  echo "Cleaning up..."
  rm -f /tmp/tempfile.$$   # $$ = current script's PID
}

# Register cleanup to run whenever script exits (success or failure)
trap cleanup EXIT

# Trap specific signals
trap cleanup INT TERM EXIT   # INT=Ctrl+C TERM=kill EXIT=any exit
```

**Why trap matters:** If a script creates temp files and crashes midway, cleanup never runs — temp files accumulate. `trap cleanup EXIT` guarantees cleanup runs regardless of how the script exits.

---

*#90DaysOfDevOps 2026 — Shell Scripting Chapter Complete*
