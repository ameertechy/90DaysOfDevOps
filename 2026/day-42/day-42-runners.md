# Day 42 – Runners: GitHub-Hosted & Self-Hosted
*#90DaysOfDevOps 2026*

Every job needs a machine. Today is about understanding what that machine is — what GitHub provides by default, and what it takes to register your own.

All workflows live on `main` of my **github-actions-practice** repo. The self-hosted runner is my EC2 free-tier instance.

---

## Task 1 — GitHub-Hosted Runners Across Three OSes

```yaml
name: Multi-OS Check

on: [push]

jobs:
  ubuntu-info:
    runs-on: ubuntu-latest
    steps:
      - name: OS info
        run: |
          echo "OS: ${{ runner.os }}"
          hostname
          whoami

  windows-info:
    runs-on: windows-latest
    steps:
      - name: OS info
        run: |
          echo "OS: ${{ runner.os }}"
          hostname
          whoami

  macos-info:
    runs-on: macos-latest
    steps:
      - name: OS info
        run: echo "OS ${{ runner.os }}" && hostname && whoami
```

- All three jobs run **in parallel** — they don't `needs:` each other.
- `hostname` prints the runner's machine name — a random GitHub infrastructure hostname, different every run.
- `whoami` on ubuntu shows `runner`; on Windows `runneruser`; on macOS `runner`.
- Each job gets a completely **fresh VM** — nothing from a previous run carries over.

### What is a GitHub-hosted runner?
A VM that GitHub spins up specifically for your job and tears down after. GitHub manages the OS, software, and networking. You never see the machine; it just works.

---

## Task 2 — Pre-installed Software on ubuntu-latest

```yaml
- name: What's already here?
  run: |
    docker --version
    python3 --version
    node --version
    git --version
    go version
```

Why this matters: you don't need install steps for the common stack. The runner already has it. Where it gets complicated is version pinning — you can't control *which* version of Go or Python is pre-installed. If you need an exact version, use `actions/setup-go@v5` or `actions/setup-python@v5` to override it.

---

## Task 3 — Setting Up a Self-Hosted Runner (EC2)

Go to: **github-actions-practice repo → Settings → Actions → Runners → New self-hosted runner → Linux x64**

GitHub generates the exact commands. Run them on your EC2 instance:

```bash
# On your EC2 instance
mkdir actions-runner && cd actions-runner

# Download the runner package (GitHub provides the exact URL in the setup page)
curl -o actions-runner-linux-x64.tar.gz -L https://github.com/actions/runner/releases/download/v<version>/actions-runner-linux-x64-<version>.tar.gz

# Extract
tar xzf ./actions-runner-linux-x64.tar.gz

# Configure — GitHub provides the token automatically on the setup page
./config.sh --url https://github.com/ameertechy/github-actions-practice --token <YOUR_TOKEN>

# Run (foreground — good for testing, exits when SSH session ends)
./run.sh
```

The runner shows as **Idle** in GitHub Settings → Runners when it's connected and waiting for a job.

### Run as a persistent service (survives SSH disconnection)

```bash
# Install as a systemd service
sudo ./svc.sh install

# Start it
sudo ./svc.sh start

# Check status
sudo ./svc.sh status

# Stop it
sudo ./svc.sh stop

# Uninstall (remove the service)
sudo ./svc.sh uninstall
```

After `svc.sh install`, the runner starts automatically on EC2 reboot.

---

## Task 4 — Workflow on the Self-Hosted Runner

```yaml
name: Self-Hosted Demo

on: [push]

jobs:
  self-hosted-job:
    runs-on: self-hosted          # targets any available self-hosted runner
    steps:
      - name: Print hostname
        run: hostname

      - name: Print working directory
        run: pwd

      - name: Create a file
        run: echo "Created by GitHub Actions on $(date)" > /tmp/actions-proof.txt

      - name: Verify the file
        run: cat /tmp/actions-proof.txt
```

After the run: SSH into the EC2 instance and `cat /tmp/actions-proof.txt` — the file is there. Because it's a persistent machine, files persist between runs (unlike GitHub-hosted).

---

## Task 5 — Runner Labels

When you have more than one self-hosted runner, labels let you route jobs to the right one.

**Add a label during config:**
```bash
./config.sh --url https://github.com/ameertechy/github-actions-practice --token <TOKEN> --labels MUJA-RUNNER
```

Or add it in GitHub Settings → Runners → click the runner → Edit → Labels.

**Target it in your workflow:**
```yaml
runs-on: [self-hosted, linux, MUJA-RUNNER]
```

The runner must match **all** labels in the array. `linux` and `x64` are added automatically by the runner agent — `MUJA-RUNNER` is your custom one.

---

## Task 6 — GitHub-Hosted vs Self-Hosted Comparison

| | GitHub-Hosted | Self-Hosted |
|---|---|---|
| Who manages it? | GitHub | You |
| Cost | Free for public repos; minutes quota for private | Your server/VM cost; no GitHub billing per minute |
| Pre-installed tools | Rich standard set (Docker, Node, Go, Python, etc.) | Whatever you install |
| Good for | Most CI workloads — build, test, lint | Private network access, GPU jobs, custom OS/hardware, cost at scale |
| Security concern | Jobs share GitHub's infrastructure — don't use on public repos with `pull_request` trigger | Malicious PR code could execute on your machine — restrict to trusted branches/collaborators |

---

## Command Reference

| Command | Flags / What it does |
|---------|---------------------|
| `curl -o <file> -L <url>` | `-o` output filename; `-L` follow redirects — download runner package |
| `tar xzf <file>` | `x` extract; `z` gzip; `f` filename — unpack runner |
| `./config.sh --url <repo> --token <token>` | Register runner to a GitHub repo |
| `./config.sh … --labels <label>` | `--labels` add custom labels during registration |
| `./run.sh` | Start runner in foreground (testing) |
| `sudo ./svc.sh install` | Install runner as systemd service |
| `sudo ./svc.sh start` | Start the service |
| `sudo ./svc.sh status` | Check service health |
| `sudo ./svc.sh stop` | Stop the service |
| `hostname` | Print machine hostname |
| `whoami` | Print current user |
| `pwd` | Print working directory |

GitHub Actions YAML:
| Key | What it does |
|-----|-------------|
| `runs-on: ubuntu-latest` | GitHub-hosted Ubuntu VM |
| `runs-on: windows-latest` | GitHub-hosted Windows VM |
| `runs-on: macos-latest` | GitHub-hosted macOS VM |
| `runs-on: self-hosted` | Any available self-hosted runner |
| `runs-on: [self-hosted, linux, my-label]` | Self-hosted runner matching all labels |
| `${{ runner.os }}` | Runner OS name (`Linux`, `Windows`, `macOS`) |
| `${{ runner.name }}` | Runner name as registered |

---

*#90DaysOfDevOps 2026*
