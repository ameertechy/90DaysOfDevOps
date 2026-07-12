# Day 61 – Introduction to Terraform & Your First AWS Infrastructure

*Also TerraWeek Challenge Day 1. Solution repo: [ameertechy/terraweek-challenge → day-01-introduction](https://github.com/ameertechy/terraweek-challenge/tree/main/day-01-introduction)*

## Overview

I've spent 7+ years provisioning infrastructure the imperative way — SSH in, run the runbook, click through consoles, hope the next rebuild matches the last. Day 61 flipped that: I described an S3 bucket and an EC2 instance in a single `main.tf`, and Terraform created them, tracked them, and tore them down — identically, from code. The concept that used to be a CMDB I maintained by hand is now a state file the tool reconciles for me.

This was my re-entry into the challenge after a gap, done live alongside Shubham's #TerraWeekChallenge. Everything ran from my Ubuntu 24.04 laptop against real AWS (region `us-west-2`); no resource was left running.

---

## What I Produced

- [`main.tf`](./main.tf) — provider config + S3 bucket + AMI data source + EC2 instance
- [`day-61-terraform-intro.md`](./day-61-terraform-intro.md) — IaC notes, command reference, and state-file write-up
- 5 screenshots in [`screenshots/`](./screenshots/) — apply (S3), AWS verify, apply (EC2), state list, destroy
- Committed solution in my TerraWeek fork under `my-solutions/day-01/` (with `.terraform.lock.hcl` pinned; state git-ignored)

---

## Tasks Completed

| Task | What I Did |
|------|-----------|
| 1 | Wrote IaC notes in my own words — what it is, what it solves vs manual console work, Terraform vs CloudFormation/Ansible/Pulumi, what "declarative" and "cloud-agnostic" mean |
| 2 | Installed Terraform (v1.15+) on Ubuntu 24.04; confirmed AWS auth with `aws sts get-caller-identity` — Terraform reuses the CLI credentials, so no keys in code |
| 3 | First config — `terraform { required_providers }`, `provider "aws"` (region `us-west-2`, AWS provider `~> 6.0`), and an `aws_s3_bucket`; ran init → plan → apply and verified with `aws s3 ls` |
| 4 | Added an `aws_instance` (`t3.micro`) using a `data "aws_ami"` lookup for the latest Ubuntu 24.04 — plan showed only 1 resource to add, proving Terraform tracked the existing bucket |
| 5 | Inspected state — `terraform state list`, `terraform show`, `terraform state show aws_instance.web`; documented what state holds and why it must never be edited or committed |
| 6 | `terraform destroy` — removed both resources, verified they were gone from AWS. Confirmed the IaC promise: `.tf` stays, `apply` rebuilds it identically |

---

## Key Observations

**The reconciliation loop is the whole tool.** Every run, Terraform compares three things — my `.tf` (desired), the state file (last-known), and the live AWS API (actual) — and computes the diff. `plan` shows that diff before anything changes. That safety net is exactly what imperative runbooks never gave me.

**Implicit dependencies come from references, not ordering.** My EC2 `ami = data.aws_ami.ubuntu.id` line alone told Terraform to resolve the AMI lookup before creating the instance. I never sequenced anything by hand — Terraform builds the graph from references.

**State is the make-or-break concept.** `terraform.tfstate` maps my resource names to real AWS IDs and can contain sensitive attributes in plain text. Delete it and Terraform forgets it owns the infra; commit it and you leak secrets. Local state is fine for solo learning but not for a team — the production fix (remote S3 backend with locking) is Day 64.

**Provider version pinning matters.** I used `~> 6.0` (the current AWS provider major). Pinning stops a teammate's different provider version from producing a surprise plan.

---

## Real-World Tie-in

- **IaC replaces my runbooks with something enforceable.** The maintenance procedures I keep as documents become code that *is* the procedure — and `plan` tells me when reality has drifted from it. Drift detection alone is worth the switch.
- **State file ≈ a CMDB that enforces itself.** I've maintained inventories of what's deployed; they go stale the moment someone changes something out-of-band. Terraform's state, reconciled against the live API every run, is that inventory made honest.
- **`terraform destroy` = clean teardown of a whole environment.** Spinning up an identical test environment and tearing it down with two commands is something I'd have scripted painstakingly before. This is the reproducibility I always wanted.

---

`#90DaysOfDevOps` `#TerraWeek` `#DevOpsKaJosh` `#TrainWithShubham` `#Terraform` `#IaC`
