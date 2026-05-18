# Day 03 – Linux Commands Practice

## Overview

Coming from 7+ years managing enterprise infrastructure, Linux commands are already part of my daily work.

Day 3 is about deliberate formalization — building a structured, scannable cheat sheet organized the way a production engineer actually thinks during an incident: by scenario, not by alphabet.

The cheat sheet covers three operational areas:

- Process management
- Filesystem and disk operations
- Network troubleshooting

---

## What I Produced

- [`linux-commands-cheatsheet.md`](./linux-commands-cheatsheet.md)

---

## Key Decisions

**Grouped by scenario, not category name:**
During an incident you think "what is consuming my CPU?" not "which section covers processes?" The cheat sheet mirrors that mental model.

**Output notes included per command:**
Knowing a command exists is different from knowing what healthy output looks like. Each section includes what to look for — not just syntax.

**Production triage sequence at the end:**
Six steps. Covers system pulse, failed services, errors, resource consumers, network sanity, and service-specific logs. This is the sequence I run first on any alert.

---

## Real-World Tie-in

These commands map directly to what I already do in production:

- `ps aux` + `top` — first check before opening Zabbix when a host alert fires
- `ss -tulpn` — port binding verification after any service deployment
- `journalctl -u <service>` — first step before escalating any service failure
- `df -h` + `du -sh` — capacity check during backup pre-flight windows
- `ip a` + `ping` + `dig` — network triage before touching switch-layer configs

---

## Docker Installation (Day 3 Hands-on Addition)

Installed Docker Engine today to have a real running service for upcoming days.

```bash
# Install Docker Engine on Ubuntu 24.04
sudo apt update
sudo apt install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Add user to docker group (no sudo needed)
sudo usermod -aG docker $USER

# Verify
docker --version
sudo systemctl status docker
```

Docker gives a real service to apply every command from the cheatsheet — `systemctl`, `journalctl`, `ss -tulpn`, `ps aux` — against something that actually runs.

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#Linux` `#DevOps`
