# Day 38 – YAML Basics
*#90DaysOfDevOps 2026*

Before I touch a single CI/CD pipeline, I needed to actually *know* YAML — not just recognise it from the Docker Compose files I've been writing all week. So this day was hand-writing YAML, breaking it on purpose, and validating it.

---

## Task 1 — Key/Value Pairs (`person.yaml`)

```yaml
name: Ameerul Mujahidin
role: Infrastructure / Systems Engineer
experience_years: 7
learning: true
```

- `key: value` — note the **space after the colon** (`key:value` is wrong).
- `experience_years: 7` → a number; `learning: true` → a **boolean**. `"true"` in quotes would be a string instead.
- `cat person.yaml` looked clean — no tabs (my editor is set to insert spaces).

---

## Task 2 — Lists

```yaml
tools:                    # block style
  - Linux
  - Git
  - Docker
  - Docker Compose
  - Nginx

hobbies: [reading, cricket, road trips]   # inline (flow) style
```

### Q: What are the two ways to write a list in YAML?
1. **Block style** — each item on its own line, indented under the key, prefixed with `- ` (dash + space). Best when the list is long or items are complex.
2. **Inline / flow style** — everything on one line inside square brackets: `[a, b, c]`. Best for short, simple lists.

Both produce the exact same data — it's purely about readability.

---

## Task 3 — Nested Objects (`server.yaml`)

```yaml
server:
  name: web-01
  ip: 10.0.0.12
  port: 8080

database:
  host: db-01
  name: devboard
  credentials:
    user: devboard
    password: devboard
```

- Nesting is just **more indentation** — `credentials` sits under `database`, so its keys go 2 more spaces in.
- Indentation is the *only* thing defining structure here. There are no braces, no closing tags.

### Q: I added a tab instead of spaces — what happened?
The validator rejected it immediately:
```
error: found character '\t' that cannot start any token
```
YAML flat-out forbids tabs for indentation. This is the #1 beginner trap — and the worst part is a tab can *look* identical to spaces in the editor, so you can't see it. (`cat -A file.yaml` shows tabs as `^I`.)

---

## Task 4 — Multi-line Strings

```yaml
startup_script: |
  #!/bin/bash
  echo "Starting web-01..."
  docker compose up -d
  echo "web-01 is up."

health_note: >
  This server hosts the DevBoard frontend and proxies /api to the backend
  container. It is checked every five minutes and restarts automatically
  if the health check fails.
```

### Q: When would you use `|` vs `>`?
- **`|` (block / literal):** *keeps every newline.* Use it when line breaks matter — shell scripts, multi-line commands, config blocks, anything you'd run line-by-line.
- **`>` (folded):** *folds newlines into spaces*, turning the block into one long line. Use it for long prose — descriptions, notes, messages — where you want to wrap the source for readability but store it as a single line.

One-liner: **`|` is for code, `>` is for paragraphs.**

---

## Task 5 — Validate Your YAML

```bash
# Option A — yamllint (a proper linter)
pip install yamllint
yamllint person.yaml server.yaml

# Option B — let a YAML parser try to load it
python -c "import yaml; yaml.safe_load(open('server.yaml')); print('valid ✅')"

# Option C — paste into yamllint.com (no install)
```

**Broke the indentation on purpose** (knocked `port` out of line under `server`):
```
error: mapping values are not allowed here
```
That message means YAML found a `key: value` where it didn't expect one — almost always an indentation problem. Fixed the spacing → validated clean again.

---

## Task 6 — Spot the Difference

```yaml
# Block 1 — correct
name: devops
tools:
  - docker
  - kubernetes
```
```yaml
# Block 2 — broken
name: devops
tools:
- docker
  - kubernetes
```

**What's wrong with Block 2:** the two list items are at **different indentation levels**. `- docker` and `- kubernetes` belong to the same list, so they must line up at the same indent. In Block 2, `kubernetes` is pushed further in, so the parser tries to read it as a nested item *inside* `docker` and chokes. **Fix:** indent both items the same amount (Block 1). Consistency is everything.

---

## 3 Key Things I Learned

1. **Whitespace is the syntax.** No braces, no tags — indentation alone defines the structure, and it must use **spaces, never tabs**. 2 spaces per level is the standard.
2. **YAML has real types.** `7` is a number, `true` is a boolean, `"true"` is a string. The quotes (or lack of them) change the meaning, which matters a lot once a pipeline reads the value.
3. **Validate before you ship.** A linter catches the tab/indent mistakes I literally couldn't see by eye — far better to fail on `yamllint` than to fail in a running pipeline.

---

## Command Reference — YAML

| Command | What it does |
|---------|-------------|
| `cat -A file.yaml` | Show hidden characters — tabs appear as `^I`, line ends as `$` |
| `pip install yamllint` | Install the YAML linter |
| `yamllint file.yaml` | Lint a file for syntax + style problems |
| `python -c "import yaml; yaml.safe_load(open('f.yaml'))"` | Try to parse the file; errors if invalid |

---

*#90DaysOfDevOps 2026*
