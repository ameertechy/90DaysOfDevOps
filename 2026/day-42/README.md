# Day 42 – Runners: GitHub-Hosted & Self-Hosted

## Overview

Every job in a workflow needs a machine to execute on. Day 42 is about understanding that machine — what GitHub provides for free, what it costs in terms of trust, and what it means to bring your own. I registered my EC2 free-tier instance as a self-hosted runner on my [`github-actions-practice`](https://github.com/ameertechy/github-actions-practice) repo and ran workflows on it. Watching the logs show *my server's* hostname instead of some GitHub datacenter host was a different feeling entirely.

It wasn't a straight line either: my first Multi-OS run failed, and the first self-hosted run failed before I cleared the error and re-ran green — which taught me more about reading Actions logs than any clean run would have. This EC2 runner stays alive: Day 49's DevSecOps pipeline deploys DevBoard onto it.

---

## What I Produced

- [`day-42-runners.md`](./day-42-runners.md) — notes covering GitHub-hosted runners, pre-installed tools, self-hosted setup, labels, and the comparison table
- `multi-os.yml`, `runner-tools.yml`, and `self-hosted.yml` workflows on `main` of **github-actions-practice**, the last one running on my EC2 instance
- Seven screenshots in [`screenshots/`](./screenshots/) — multi-OS jobs, pre-installed tools, runner Idle in settings, `svc.sh status`, self-hosted job log, proof file, labeled-runner run

---

## Tasks Completed

| Task | What I Did |
|------|-----------|
| 1 | Three-job workflow — `ubuntu-latest`, `windows-latest`, `macos-latest` — each prints OS name, hostname, and current user; first run failed, fixed and re-ran green |
| 2 | Printed Docker, Python, Node, Git, and Go versions from the `ubuntu-latest` runner; noted what's pre-installed |
| 3 | Registered EC2 free-tier instance as a self-hosted runner (`config.sh` with the one-time token); installed it as a systemd service with `svc.sh install/start`; confirmed **Idle** in GitHub Settings |
| 4 | `self-hosted.yml` — prints EC2 hostname, working directory, appends a proof line per run to `/tmp/actions-proof.txt`; verified the file accumulates lines on the instance across runs |
| 5 | Debugged a failed self-hosted run, cleared the error, re-ran successfully |
| 6 | Re-registered the runner with a custom label **`MUJA-RUNNER`** (`--labels ... --replace`); updated the workflow to `runs-on: [self-hosted, MUJA-RUNNER]` and verified it still picks up my EC2 |
| 7 | Filled the GitHub-Hosted vs Self-Hosted comparison table |

---

## Key Observations

**GitHub-hosted runners are ephemeral, self-hosted runners are persistent.** Each GitHub-hosted run gets a brand-new, clean Ubuntu/Windows/macOS VM — nothing lingers between runs, which is exactly why they're trustworthy. Self-hosted runners run on a persistent machine — my proof file kept growing run after run.

**The runner reaches OUT, not GitHub reaching in.** My EC2 has no inbound port open for GitHub. The runner process polls GitHub for jobs, pulls them, and streams logs back. That's why setup needs no firewall changes.

**Pre-installed software is a time-saver until it isn't.** The `ubuntu-latest` runner ships with Docker, Node, Python, Go, and more already on it. For common stacks that's great — no install step. But versions are whatever GitHub last updated. Self-hosted gives you exact control — and an empty machine to start with.

**Labels are the routing mechanism.** If you have five self-hosted runners, you need a way to target the right one. Labels let you tag a runner (`gpu-runner`, `MUJA-RUNNER`, `ec2-prod`) and point a job at it with `runs-on: [self-hosted, label]`.

**Self-hosted for private network access.** The biggest reason to use a self-hosted runner in practice: the runner can reach things GitHub's cloud can't — an internal database, a private registry, a server behind a firewall. That's the real use case.

---

## Real-World Tie-in

- **Self-hosted on EC2 = CI on your own infra.** On campus I manage physical servers. A self-hosted runner registered to one of them would let GitHub Actions deploy directly to that server — no VPN, no external gateway, just a process already running there waiting for jobs.
- **The comparison table is the decision matrix.** Every time a team asks "should we use GitHub-hosted or set up our own?" the answer comes down to those five criteria: control, cost, trust model, network access, and maintenance burden. Now I can answer it from experience, not theory.

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#GitHubActions` `#CI` `#DevOps`
