# Day 63 – Terraform Variables, Outputs, Data Sources and Expressions

*Also TerraWeek Challenge Day 2 (HCL). Solution repo: [ameertechy/terraweek-challenge → day-02-hcl](https://github.com/ameertechy/terraweek-challenge/tree/main/day-02-hcl)*

## Overview

Day 1's config worked, but every value was frozen into it — region, instance type, names. Day 63 was about making the same infrastructure dynamic: variables with real types and validation, per-environment `.tfvars` files, computed locals, and outputs. The result is one codebase that deploys dev or prod depending on which values you feed it — the Terraform equivalent of replacing environment-specific runbooks with one runbook plus environment-specific config files.

Done on my Ubuntu 24.04 laptop against AWS `us-west-2`, on the default VPC (the from-scratch VPC comes tomorrow with Managing Resources). Everything destroyed at the end of the session.

---

## What I Produced

- [`variables.tf`](./variables.tf) — 8 input variables covering all five types (`string`, `number`, `bool`, `list(number)`, `map(string)`), one deliberately required (no default), one with a custom `validation` block
- [`main.tf`](./main.tf) — fully parameterized: provider region from a variable, Amazon Linux 2 AMI + availability zones via data sources, a security group whose ingress rules are **generated from a list variable** with a `dynamic` block, and a `count`-based EC2 instance
- [`locals.tf`](./locals.tf) — naming convention by interpolation, merged common tags, and a conditional that force-enables monitoring in prod
- [`outputs.tf`](./outputs.tf) — instance IDs/IPs/DNS via splat expressions, SG ID, resolved AMI ID
- [`terraform.tfvars`](./terraform.tfvars) + [`prod.tfvars`](./prod.tfvars) — dev defaults vs prod overrides (committed deliberately with `git add -f`; they contain no secrets)
- [`day-63-variables-outputs.md`](./day-63-variables-outputs.md) — notes: types, precedence order, expressions
- 4 screenshots in [`screenshots/`](./screenshots/)

---

## Tasks Completed

| Task | What I Did |
|------|-----------|
| 1 | Extracted every hardcoded value into `variables.tf` — region, instance type/count, environment (with `validation` restricting it to dev/staging/prod), allowed ports as `list(number)`, extra tags as `map(string)`; left `project_name` without a default and watched `terraform plan` refuse to run without it |
| 2 | Created `terraform.tfvars` (dev) and `prod.tfvars`; proved precedence hands-on — tfvars auto-loaded, `-var-file="prod.tfvars"` switched instance type to t3.small, and a `-var` CLI flag overrode everything |
| 3 | `outputs.tf` with six outputs; after apply, queried them with `terraform output`, a single-output lookup, and `-json` |
| 4 | Data sources — `aws_ami` (Amazon Linux 2, `owners = ["amazon"]`, hvm/gp2 filters, resolved to `ami-04d78408ebc2960db`) and `aws_availability_zones` (instance pinned to `names[0]` = us-west-2a by expression, not hardcoding) |
| 5 | Locals — `name_prefix = "${var.project_name}-${var.environment}"` naming everything `terraweek-dev-*`, `merge()` of common tags with caller tags, and `environment == "prod" ? true : var.enable_detailed_monitoring` (verified: monitoring stayed `false` in dev) |
| 6 | Applied (SG with exactly 3 ingress rules generated from `[22, 80, 443]` + 1 t3.micro instance), verified outputs, then `terraform destroy` — 2 resources destroyed, `terraform state list` returned empty |

---

## Key Observations

**Variable precedence, from experience not memorization:** `default` → `TF_VAR_` env vars → `terraform.tfvars` → `*.auto.tfvars` → `-var-file`/`-var` (last flag wins). The CLI flag overriding both tfvars files was the moment the ordering stuck.

**A required variable is a design decision.** Omitting `default` on `project_name` means nobody can apply this config on autopilot — Terraform stops and asks. Use it for the values no one should assume.

**`dynamic` blocks turn data into infrastructure.** The SG's three ingress rules aren't written anywhere — they're generated from `var.allowed_ports`. Adding port 8080 to a list in a tfvars file would create a firewall rule with zero code changes. That inverts how I've always managed firewall configs.

**Variables vs locals is inputs vs derivations.** `var.*` comes from outside (a person, a tfvars file, CI); `local.*` is computed inside. The naming prefix and merged tags belong in locals because no caller should set them directly.

**Splat expressions future-proof outputs.** `aws_instance.web[*].id` works identically for `instance_count = 1` or `= 10` — outputs don't need rewriting when the fleet grows.

---

## Real-World Tie-in

- **`prod.tfvars` vs `terraform.tfvars` is change control I already know** — same procedure, different parameter sheet per environment. Except here the "procedure" can't drift between environments, because it's literally the same code.
- **The validation block is a pre-flight check.** I've seen changes land in the wrong environment because of a typo in a variable. `contains(["dev","staging","prod"], var.environment)` kills that class of error at plan time.
- **`terraform output -json` is the integration point** — the IPs/IDs of what Terraform builds, machine-readable, ready to feed an inventory or a pipeline. This is the handshake to Ansible (day 68+) and CI/CD.

---

`#90DaysOfDevOps` `#TerraWeek` `#DevOpsKaJosh` `#TrainWithShubham` `#Terraform` `#IaC`
