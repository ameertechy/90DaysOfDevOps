# Bash Scripting Challenge: Log Analyzer and Report Generator
*#90DaysOfDevOps 2026*

---

## The Challenge

Build a script that:
1. Accepts a log file as argument — validates it exists
2. Counts lines containing `ERROR` or `Failed`
3. Finds and lists `CRITICAL` events with line numbers
4. Ranks the top 5 most common error messages
5. Generates a timestamped summary report file
6. Optionally archives the processed log

---

## Understanding the Text Processing Pipeline Before the Script

Day 20 introduces `grep`, `awk`, `sort`, and `uniq` as a pipeline.
Understand each stage before reading the script.

### `grep` — find matching lines

```bash
# Count lines containing ERROR
grep -c "ERROR" sample_log.log
# -c = count only — returns the number, not the lines
# Without -c: returns every matching line

# Find lines with CRITICAL, show line numbers
grep -n "CRITICAL" sample_log.log
# -n = line number prefix
# Output: 12:2026-06-01 02:33:17 CRITICAL Disk space below threshold...

# Find ERROR OR Failed in one command
grep -cE "ERROR|Failed" sample_log.log
# -E = extended regex — enables the | OR operator
# -c = count
```

### `awk` — extract and format columns

```bash
# awk splits each line into fields by whitespace
# $1=date, $2=time, $3=level, $4 onwards=message
grep "ERROR" sample_log.log | awk '{$1=$2=$3=""; print $0}' | head -3
# $1=$2=$3="" — blank out first 3 fields (date, time, level)
# print $0 — print the whole line (now just the message)
# Result: strips timestamp and ERROR keyword, leaves just the message text
```

**`$1=$2=$3=""` explained:**
In `awk`, each field is a variable — `$1` is the first word, `$2` the second, and so on. Assigning `""` to them replaces them with empty strings. `$0` is the entire line. After blanking three fields, `$0` still contains the separating spaces — use `sed 's/^   //'` or `xargs` to trim leading whitespace if needed.

### `sort` — order lines

```bash
# Sort alphabetically (default)
grep "ERROR" sample_log.log | awk '{$1=$2=$3=""; print $0}' | sort | head -5

# sort -r = reverse (descending)
# sort -n = numeric sort
# sort -rn = reverse numeric — largest number first
```

### `uniq -c` — count consecutive duplicates

```bash
# uniq -c = prefix each unique line with its occurrence count
# MUST be sorted first — uniq only collapses adjacent identical lines
grep "ERROR" sample_log.log | awk '{$1=$2=$3=""; print $0}' | sort | uniq -c | head -5
# Output: 9  Connection timed out - database pool exhausted
#         4  File not found - config.yaml missing
# etc.

# Then sort -rn to rank by count descending
grep "ERROR" sample_log.log | awk '{$1=$2=$3=""; print $0}' | sort | uniq -c | sort -rn | head -5
```

**The full pipeline as one mental model:**
```
grep   →  find matching lines
awk    →  strip what we don't need (date/time/level)
sort   →  group identical messages together
uniq -c →  count each unique message
sort -rn → rank by count, highest first
head -5  → keep only top 5
```

---

## `log_analyzer.sh` — Complete Script

```bash
#!/bin/bash
set -euo pipefail

# ─────────────────────────────────────────
# log_analyzer.sh
# Usage: ./log_analyzer.sh /path/to/logfile.log
# ─────────────────────────────────────────

# ── Validation ────────────────────────────
if [ $# -eq 0 ]; then
  echo "Error: No log file provided"
  echo "Usage: $0 /path/to/logfile.log"
  exit 1
fi

LOG_FILE="$1"

if [ ! -f "$LOG_FILE" ]; then
  echo "Error: File not found: $LOG_FILE"
  exit 1
fi

# ── Variables ─────────────────────────────
REPORT_DATE=$(date +%Y-%m-%d)
REPORT_FILE="log_report_${REPORT_DATE}.txt"
LOG_NAME=$(basename "$LOG_FILE")

# ── Functions ─────────────────────────────

get_total_lines() {
  wc -l < "$LOG_FILE"
}

get_error_count() {
  grep -cE "ERROR|Failed" "$LOG_FILE" || true
  # || true prevents set -e from exiting when grep finds 0 matches
  # grep returns exit code 1 when no matches found — with set -e this would kill the script
}

get_critical_events() {
  grep -n "CRITICAL" "$LOG_FILE" || true
}

get_top_errors() {
  grep "ERROR" "$LOG_FILE" \
    | awk '{$1=$2=$3=""; print $0}' \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq -c \
    | sort -rn \
    | head -5 \
    || true
}

print_section() {
  echo ""
  echo "─────────────────────────────────────────"
  echo "  $1"
  echo "─────────────────────────────────────────"
}

generate_report() {
  local TOTAL_LINES ERROR_COUNT

  TOTAL_LINES=$(get_total_lines)
  ERROR_COUNT=$(get_error_count)

  # ── Console output ─────────────────────
  echo "========================================="
  echo "  LOG ANALYSIS REPORT"
  echo "  File    : $LOG_NAME"
  echo "  Date    : $REPORT_DATE"
  echo "========================================="

  print_section "Summary"
  echo "  Total lines processed : $TOTAL_LINES"
  echo "  Total errors found    : $ERROR_COUNT"

  print_section "Critical Events"
  local CRITICAL_EVENTS
  CRITICAL_EVENTS=$(get_critical_events)
  if [ -z "$CRITICAL_EVENTS" ]; then
    echo "  No critical events found"
  else
    while IFS= read -r LINE; do
      LINE_NUM=$(echo "$LINE" | cut -d: -f1)
      LINE_CONTENT=$(echo "$LINE" | cut -d: -f2-)
      echo "  Line $LINE_NUM: $LINE_CONTENT"
    done <<< "$CRITICAL_EVENTS"
  fi

  print_section "Top 5 Error Messages"
  local TOP_ERRORS
  TOP_ERRORS=$(get_top_errors)
  if [ -z "$TOP_ERRORS" ]; then
    echo "  No errors found"
  else
    while IFS= read -r LINE; do
      echo "  $LINE"
    done <<< "$TOP_ERRORS"
  fi

  echo ""
  echo "========================================="

  # ── Write report to file ───────────────
  {
    echo "========================================="
    echo "  LOG ANALYSIS REPORT"
    echo "  Generated : $(date '+%Y-%m-%d %H:%M:%S')"
    echo "  Log file  : $LOG_NAME"
    echo "========================================="
    echo ""
    echo "SUMMARY"
    echo "-------"
    echo "Total lines processed : $TOTAL_LINES"
    echo "Total errors found    : $ERROR_COUNT"
    echo ""
    echo "CRITICAL EVENTS"
    echo "---------------"
    if [ -z "$CRITICAL_EVENTS" ]; then
      echo "No critical events found"
    else
      while IFS= read -r LINE; do
        LINE_NUM=$(echo "$LINE" | cut -d: -f1)
        LINE_CONTENT=$(echo "$LINE" | cut -d: -f2-)
        echo "Line $LINE_NUM: $LINE_CONTENT"
      done <<< "$CRITICAL_EVENTS"
    fi
    echo ""
    echo "TOP 5 ERROR MESSAGES"
    echo "--------------------"
    if [ -z "$TOP_ERRORS" ]; then
      echo "No errors found"
    else
      echo "$TOP_ERRORS"
    fi
    echo ""
    echo "========================================="
    echo "  END OF REPORT"
    echo "========================================="
  } > "$REPORT_FILE"

  echo "  Report saved to: $REPORT_FILE"
}

archive_log() {
  local ARCHIVE_DIR
  ARCHIVE_DIR="$(dirname "$LOG_FILE")/archive"
  mkdir -p "$ARCHIVE_DIR"
  mv "$LOG_FILE" "$ARCHIVE_DIR/"
  echo "  Log archived to: $ARCHIVE_DIR/$LOG_NAME"
}

# ── Main ──────────────────────────────────
main() {
  generate_report

  read -rp "Archive processed log? (y/n): " ARCHIVE_CHOICE
  if [ "$ARCHIVE_CHOICE" = "y" ]; then
    archive_log
  fi
}

main
```

**All new concepts explained:**

**`grep -cE "ERROR|Failed" "$LOG_FILE" || true`:**
- `-E` = extended regex — enables `|` as OR operator
- `-c` = count — returns the number of matching lines
- `|| true` — when `grep` finds zero matches it exits with code 1. With `set -e` active, that would kill the script even though zero matches is a valid result. `|| true` makes the overall expression succeed regardless of grep's exit code.

**`sed 's/^[[:space:]]*//'`:**
- `sed` = stream editor — transforms text line by line
- `s/old/new/` = substitute old pattern with new
- `^` = start of line
- `[[:space:]]*` = zero or more whitespace characters
- `//` = replace with nothing (delete)
- After `awk` blanks the first 3 fields, leading spaces remain — `sed` strips them

**`<<< "$VARIABLE"` (here-string):**
- `<<<` = here-string — passes a variable's value directly as stdin to a command
- `while IFS= read -r LINE; do ... done <<< "$CRITICAL_EVENTS"` reads the variable line by line
- Alternative to `echo "$VAR" | while read` but cleaner and avoids a subshell

**`{ ... } > "$REPORT_FILE"`:**
- Groups multiple commands in `{ }` and redirects ALL their combined output to the file
- Without grouping, each `echo` would need `>> "$REPORT_FILE"` — 20+ separate redirects
- The group redirect is the cleanest way to write a multi-line report to a file

**`read -rp "Archive log? (y/n): " ARCHIVE_CHOICE`:**
- `-r` = raw — disable backslash interpretation
- `-p "text"` = display prompt before reading

**Run it against the sample log:**
```bash
chmod +x log_analyzer.sh
./log_analyzer.sh sample_log.log
```

**Expected console output:**
```
=========================================
  LOG ANALYSIS REPORT
  File    : sample_log.log
  Date    : 2026-06-03
=========================================
─────────────────────────────────────────
  Summary
─────────────────────────────────────────
  Total lines processed : 67
  Total errors found    : 30

─────────────────────────────────────────
  Critical Events
─────────────────────────────────────────
  Line 12: 2026-06-01 02:33:17 CRITICAL Disk space below threshold - 95% used on /
  Line 26: 2026-06-01 07:15:09 CRITICAL Database connection lost - failover initiated
  Line 45: 2026-06-01 13:45:22 CRITICAL Out of memory - kernel OOM killer activated

─────────────────────────────────────────
  Top 5 Error Messages
─────────────────────────────────────────
  10  Connection timed out - database pool exhausted
   6  Permission denied - cannot write to /var/log/app
   5  File not found - config.yaml missing
   4  Disk I/O error - read failure on /dev/sdb
   3  Out of memory - process killed by OOM killer

=========================================
  Report saved to: log_report_2026-06-03.txt
```

---

## Tools Used

| Tool | What it did |
|------|------------|
| `grep -cE` | Count ERROR and Failed lines with OR |
| `grep -n` | Find CRITICAL lines with line numbers |
| `awk` | Strip timestamp and log level from error lines |
| `sed` | Remove leading whitespace after awk processing |
| `sort` | Group identical error messages |
| `uniq -c` | Count occurrences of each unique message |
| `sort -rn` | Rank by count, highest first |
| `head -5` | Keep only top 5 results |
| `wc -l` | Count total lines |
| `basename` | Extract filename from full path |
| `cut -d: -f1` | Extract line number from grep -n output |

---

## 3 Key Learnings

**1. `grep -c` returns exit code 1 when zero matches — always add `|| true` in `set -e` scripts.**
This is a silent trap. A log with no errors is valid. Without `|| true`, your entire analysis script fails the moment it processes a clean log file.

**2. `sort` must come before `uniq -c` — `uniq` only collapses adjacent identical lines.**
If you run `uniq -c` without sorting first, it counts runs of duplicates but misses duplicates that are not adjacent. Sorting groups all identical lines together first — then `uniq -c` counts each group correctly.

**3. `{ } > file` groups multiple outputs into one redirect.**
This pattern replaces writing `>> file` on every single echo in a report. Group all output, redirect once. Cleaner, faster to write, and the file gets written atomically rather than appended line by line.

---

*#90DaysOfDevOps 2026*
