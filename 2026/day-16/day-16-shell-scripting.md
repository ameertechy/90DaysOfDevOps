# Shell Scripting Basics
*#90DaysOfDevOps 2026*

---

## The Shebang — `#!/bin/bash`

Every bash script starts with this line:

```bash
#!/bin/bash
```

**What `#!` means:**
The `#!` is called a **shebang** (also hashbang). It tells the operating system: "use the program at this path to interpret the rest of this file."

- `#!` = signal to the OS that this is an interpreter directive
- `/bin/bash` = path to the bash interpreter

**What happens without the shebang:**
The OS falls back to the default shell — usually `sh`, not `bash`. `sh` is a simpler, older shell. Some bash features (`[[ ]]`, arrays, `local` variables in functions) do not exist in `sh`. Scripts may fail silently or behave differently. Always include the shebang.

**How to run a script — two ways:**

```bash
# Method 1: direct execution — requires execute permission
chmod +x script.sh
./script.sh

# Method 2: pass to bash explicitly — no execute permission needed
bash script.sh
```

---

## Task 1 — First Script: `hello.sh`

```bash
#!/bin/bash
echo "Hello, DevOps!"
```

**`echo` explained:**
- `echo` = print text to the terminal (standard output)
- Everything after `echo` is printed as-is
- `echo` automatically adds a newline at the end

**Run it:**
```bash
chmod +x hello.sh
./hello.sh
# Output: Hello, DevOps!
```

**What happens without shebang:**
```bash
# Remove #!/bin/bash, run with ./
./hello.sh
# May still work for simple echo — but unreliable for complex scripts
# bash-specific syntax will fail
```

---

## Task 2 — Variables: `variables.sh`

```bash
#!/bin/bash

NAME="Ameerul"
ROLE="DevOps Engineer"

echo "Hello, I am $NAME and I am a $ROLE"
```

**Variable rules in bash:**

| Rule | Correct | Wrong |
|------|---------|-------|
| No spaces around `=` | `NAME="Ameer"` | `NAME = "Ameer"` |
| Access with `$` | `echo $NAME` | `echo NAME` |
| Quote variables | `echo "$NAME"` | (safe either way for simple values) |

**Why no spaces around `=`:**
Bash parses `NAME = "Ameer"` as: run a command called `NAME` with arguments `=` and `"Ameer"`. There is no command called `NAME` — error. The `=` with no spaces is the assignment operator.

**Single quotes vs double quotes:**

```bash
NAME="Ameerul"

echo "Hello $NAME"    # Output: Hello Ameerul    ← variable expanded
echo 'Hello $NAME'    # Output: Hello $NAME      ← literal, no expansion
```

**Rule:** Use double quotes when you want variables expanded. Use single quotes when you want the exact literal text.

**Run it:**
```bash
chmod +x variables.sh
./variables.sh
# Output: Hello, I am Ameerul and I am a DevOps Engineer
```

---

## Task 3 — User Input: `greet.sh`

```bash
#!/bin/bash

read -p "Enter your name: " USERNAME
read -p "Enter your favourite tool: " TOOL

echo "Hello $USERNAME, your favourite tool is $TOOL"
```

**`read` explained:**
- `read` = reads a line of input from the user and stores it in a variable
- `-p "text"` = **prompt** — display this text before waiting for input
- `USERNAME` = the variable name to store the input in

**What happens step by step:**
1. Script reaches `read -p "Enter your name: " USERNAME`
2. Terminal displays: `Enter your name: ` and waits
3. User types: `Ameerul` and presses Enter
4. Value `Ameerul` is stored in `$USERNAME`
5. Continues to next line

**Run it:**
```bash
chmod +x greet.sh
./greet.sh
# Enter your name: Ameerul
# Enter your favourite tool: Docker
# Output: Hello Ameerul, your favourite tool is Docker
```

---

## Task 4a — If-Else: `check_number.sh`

```bash
#!/bin/bash

read -p "Enter a number: " NUM

if [ $NUM -gt 0 ]; then
  echo "Positive"
elif [ $NUM -lt 0 ]; then
  echo "Negative"
else
  echo "Zero"
fi
```

**`if-elif-else-fi` structure:**

```bash
if [ condition ]; then
  # runs if condition is true
elif [ other_condition ]; then
  # runs if first condition false, this one true
else
  # runs if all conditions false
fi
```

**`fi`** = "if" spelled backwards — closes the if block. Bash uses this pattern for all block closings (`fi` for if, `done` for loops, `esac` for case).

**Comparison operators for numbers:**

| Operator | Meaning | Example |
|----------|---------|---------|
| `-gt` | greater than | `[ $NUM -gt 0 ]` |
| `-lt` | less than | `[ $NUM -lt 0 ]` |
| `-eq` | equal to | `[ $NUM -eq 0 ]` |
| `-ne` | not equal | `[ $NUM -ne 5 ]` |
| `-ge` | greater than or equal | `[ $NUM -ge 10 ]` |
| `-le` | less than or equal | `[ $NUM -le 10 ]` |

**Why not `>` and `<` for numbers:**
In bash, `>` and `<` inside `[ ]` are string comparison operators, not numeric. They compare ASCII values — `9 > 10` would be TRUE because `'9'` comes after `'1'` in ASCII. Always use `-gt`, `-lt` for numbers.

**Spaces inside `[ ]` are mandatory:**
```bash
[ $NUM -gt 0 ]    # correct
[$NUM -gt 0]      # wrong — bash error
```

**Run it:**
```bash
chmod +x check_number.sh
./check_number.sh
# Enter a number: 5
# Output: Positive
```

---

## Task 4b — File Check: `file_check.sh`

```bash
#!/bin/bash

read -p "Enter filename: " FILENAME

if [ -f "$FILENAME" ]; then
  echo "File exists: $FILENAME"
else
  echo "File does not exist: $FILENAME"
fi
```

**File test operators:**

| Operator | Checks |
|----------|--------|
| `-f file` | File exists and is a regular file |
| `-d file` | Exists and is a directory |
| `-e file` | Exists (any type — file, dir, symlink) |
| `-r file` | Exists and is readable |
| `-w file` | Exists and is writable |
| `-x file` | Exists and is executable |
| `-s file` | Exists and is not empty |

**Why quote `"$FILENAME"`:**
If the user enters a filename with a space — `my file.txt` — without quotes `[ -f $FILENAME ]` expands to `[ -f my file.txt ]` — bash sees three arguments instead of one and fails. `"$FILENAME"` keeps it as a single argument.

**Run it:**
```bash
chmod +x file_check.sh
./file_check.sh
# Enter filename: /etc/hostname
# Output: File exists: /etc/hostname

./file_check.sh
# Enter filename: /etc/doesnotexist
# Output: File does not exist: /etc/doesnotexist
```

---

## Task 5 — Combined: `server_check.sh`

```bash
#!/bin/bash

SERVICE="nginx"

read -p "Do you want to check the status of $SERVICE? (y/n): " ANSWER

if [ "$ANSWER" = "y" ]; then
  STATUS=$(systemctl is-active "$SERVICE")
  if [ "$STATUS" = "active" ]; then
    echo "$SERVICE is running"
  else
    echo "$SERVICE is NOT running (status: $STATUS)"
  fi
elif [ "$ANSWER" = "n" ]; then
  echo "Skipped."
else
  echo "Invalid input. Please enter y or n."
fi
```

**New concepts introduced:**

**`$(command)`** = command substitution — runs the command and stores its output in a variable:
```bash
STATUS=$(systemctl is-active nginx)
# Runs: systemctl is-active nginx
# Output of that command (e.g. "active") is stored in STATUS
```

**`systemctl is-active service`** = returns the service state as a single word:
- `active` — running
- `inactive` — stopped
- `failed` — crashed
- `unknown` — service not found

**String comparison uses `=` not `-eq`:**
```bash
[ "$ANSWER" = "y" ]    # string comparison — correct
[ "$ANSWER" -eq "y" ]  # wrong — -eq is for numbers only
```

**Run it:**
```bash
chmod +x server_check.sh
./server_check.sh
# Do you want to check the status of nginx? (y/n): y
# Output: nginx is running
```

---

## 3 Key Learnings

**1. No spaces around `=` in assignment — spaces inside `[ ]` are mandatory.**
Two opposite rules that catch every beginner. `NAME="value"` assigns. `[ $NAME = "value" ]` tests. The space rule is the opposite in each context.

**2. `$()` is command substitution — store command output in a variable.**
`STATUS=$(systemctl is-active nginx)` — this pattern is used in nearly every production script. Run a command, capture the result, make a decision based on it.

**3. Always quote variables that may contain spaces: `"$VARIABLE"`.**
Unquoted variables with spaces break argument parsing silently. Quoting is a habit to build from day one.

---

*#90DaysOfDevOps 2026*
