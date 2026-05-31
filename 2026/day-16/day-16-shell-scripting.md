# Day 16 – Shell Scripting Basics

## Task 1: Your First Script

### hello.sh

```bash
#!/bin/bash

echo "Hello, DevOps!"
```

Run:

```bash
chmod +x hello.sh
./hello.sh
```

### What happens without shebang?

Without `#!/bin/bash`, the script may execute using the current shell and can fail if Bash-specific syntax is used.

---

## Task 2: Variables

### variables.sh

```bash
#!/bin/bash

NAME="Mujahidin"
ROLE="DevOps Engineer"

echo "Hello, I am $NAME and I am a $ROLE"
```

### Single Quotes vs Double Quotes

```bash
echo '$NAME'
```

Output:

```text
$NAME
```

```bash
echo "$NAME"
```

Output:

```text
Mujahidin
```

---

## Task 3: User Input with read

### greet.sh

```bash
#!/bin/bash

read -p "Enter your name: " NAME
read -p "Enter your favourite tool: " TOOL

echo "Hello $NAME, your favourite tool is $TOOL"
```

---

## Task 4: If-Else Conditions

### check_number.sh

```bash
#!/bin/bash

read -p "Enter a number: " NUM

if [ "$NUM" -gt 0 ]; then
    echo "Positive"
elif [ "$NUM" -lt 0 ]; then
    echo "Negative"
else
    echo "Zero"
fi
```

### file_check.sh

```bash
#!/bin/bash

read -p "Enter filename: " FILE

if [ -f "$FILE" ]; then
    echo "File exists"
else
    echo "File not found"
fi
```

---

## Task 5: Combine It All

### server_check.sh

```bash
#!/bin/bash

SERVICE="sshd"

read -p "Do you want to check the status? (y/n): " ANSWER

if [ "$ANSWER" = "y" ]; then

    if systemctl is-active --quiet "$SERVICE"; then
        echo "$SERVICE is active"
    else
        echo "$SERVICE is not active"
    fi

else
    echo "Skipped."
fi
```

---

## What I Learned

1. The shebang defines which interpreter executes the script.
2. Variables and `read` allow user interaction.
3. `if-elif-else` enables decision-making and automation logic.
