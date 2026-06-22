# Day 38 – YAML Basics

## Overview

Day 38 is the gateway to the CI/CD half of this challenge: before writing a single pipeline, get genuinely comfortable with **YAML** — the config language behind the Docker Compose files I've been writing all week and the CI/CD pipelines I'm about to start. I'd already been *reading and writing* YAML all through the Docker week (every `docker-compose.yml`), but I'd never sat down and learned the actual rules. This day fixed that.

The work was deliberately hands-on: write YAML by hand, break it on purpose, and validate it. I built two files — `person.yaml` (key/values, both list styles) and `server.yaml` (nested objects + multi-line strings) — then ran them through `yamllint` and watched exactly which mistakes it catches.

The headline lesson is the one everyone hits: **YAML's structure is its whitespace.** No braces, no closing tags — indentation alone defines the shape, and it must be **spaces, never tabs**. A single stray tab (which looks identical to spaces on screen) is a hard error.

---

## What I Produced

- [`day-38-yaml.md`](./day-38-yaml.md) — my notes: both YAML files, answers to the task questions (two list styles, `|` vs `>`, the "spot the difference"), and the 3 things that stuck
- [`person.yaml`](./person.yaml) — me described in YAML: key/values, a block-style list and an inline list
- [`server.yaml`](./server.yaml) — a server + database with nested objects and multi-line strings (`|` and `>`)
- Screenshots of `yamllint` passing and the tab/indent errors in [`screenshots/`](./screenshots/)

---

## Tasks Completed

| Task | What I Did |
|------|-----------|
| 1 | Wrote `person.yaml` with key/value pairs — string, number, and a real **boolean** |
| 2 | Added two lists — **block style** (`- item`) and **inline style** (`[a, b]`) |
| 3 | Built `server.yaml` with **nested objects** (`database → credentials → user/password`) |
| 4 | Added multi-line strings using `|` (keep newlines) and `>` (fold to one line) |
| 5 | Validated both files with `yamllint`, then **broke the indentation** to read the errors |
| 6 | "Spot the difference" — diagnosed why an inconsistently-indented list won't parse |

---

## Key Observations

**Tabs are a hard error, not a style preference.**
Swapping two spaces for a tab made the parser fail with `found character '\t' that cannot start any token`. The nasty part is a tab looks exactly like spaces in the editor — `cat -A file.yaml` (tabs show as `^I`) is how you actually catch it.

**Indentation *is* the structure.**
There's nothing else holding the shape together — no `{}`, no tags. Two spaces per level, consistent all the way down. The "spot the difference" task drove it home: two list items at different indents simply can't be parsed as the same list.

**YAML has real types, and quotes change meaning.**
`7` is a number, `true` is a boolean, `"true"` is a string. That distinction is invisible until a pipeline reads the value and behaves differently — so it's worth getting right from day one.

**`|` vs `>` is "code vs paragraph."**
`|` preserves every newline (perfect for a shell script block); `>` folds the lines into one (perfect for a long description you want to wrap in the source). Same idea, opposite outcome.

---

## Real-World Tie-in

- **The next step speaks YAML** — the Docker Compose files I've been writing all week are YAML, and the GitHub Actions / CI/CD pipelines I'm moving into next are too. Building the indentation instinct now pays off the moment I start writing workflows.
- **Whitespace-sensitive config is familiar pain.** In the datacenter, a config that broke on one stray character was a recurring 2 a.m. lesson — YAML's strictness is the same discipline, just made explicit.
- **Lint before you apply.** Running `yamllint` before a file hits a pipeline is the same instinct as testing a config before reloading a service — catch it where it's cheap, not in production.
- **Readability is a feature.** YAML is meant to be human-readable, which is exactly why teams use it for the config that humans have to review in pull requests.

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#YAML` `#CICD` `#DevOps`
