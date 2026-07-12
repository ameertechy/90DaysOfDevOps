# Day 61 / TerraWeek Day 1 — Terraform Intro Notes

## 1. Infrastructure as Code, in my own words

Infrastructure as Code means defining servers, networks, and cloud resources in text files that are version-controlled and executed by a tool, instead of creating them by hand in a console. It matters in DevOps because infrastructure becomes **repeatable, reviewable, and auditable** — the same file produces the same environment every time, and a `git diff` shows exactly what changed.

**What it solves vs manual console work:** no more click-ops drift, no "works on my environment," no undocumented snowflake servers. The code *is* the documentation, and it can be tested and rolled back.

**Terraform vs the others:**
- **CloudFormation** — AWS-only; Terraform is cloud-agnostic (one tool, many providers).
- **Ansible** — configuration management (installs/configures software on existing machines); Terraform is provisioning (creates the machines/infra). They complement each other.
- **Pulumi** — same provisioning goal as Terraform but you write it in real languages (Python/Go/TS); Terraform uses its own declarative HCL.

**"Declarative"** = I describe the desired end state, not the steps; Terraform figures out how to get there. **"Cloud-agnostic"** = the same tool and workflow provision AWS, Azure, GCP, and more via providers.

---

## 2. My configuration (`main.tf`)

- `terraform { required_version, required_providers }` — pins Terraform ≥ 1.15 and the AWS provider to `~> 6.0`.
- `provider "aws" { region = "us-west-2" }` — the translator to AWS's API; credentials come from my AWS CLI config, never the file.
- `resource "aws_s3_bucket" "my-first"` — a globally-unique bucket (`terraweek-ameerul-day1-8f3a2`) with tags.
- `data "aws_ami" "ubuntu"` — reads the latest Ubuntu 24.04 AMI from Canonical (owner `099720109477`) instead of hardcoding an ID.
- `resource "aws_instance" "web"` — a `t3.micro` using `data.aws_ami.ubuntu.id`, which creates an implicit dependency (AMI resolved before instance).

---

## 3. Command reference (what each does)

| Command | What it does |
|---|---|
| `terraform init` | Downloads the provider plugins into `.terraform/`, writes `.terraform.lock.hcl` (pins versions/checksums) |
| `terraform plan` | Dry run — shows the diff between my files, state, and AWS. `+` add, `~` modify, `-` destroy. No changes made |
| `terraform apply` | Executes the plan after a `yes` confirmation; records results in `terraform.tfstate` |
| `terraform destroy` | Deletes all managed resources and updates state |
| `terraform show` | Human-readable dump of current state |
| `terraform state list` | Lists every resource Terraform is tracking |
| `terraform state show <addr>` | Detailed recorded attributes of one resource |
| `terraform fmt` | Auto-formats `.tf` files |
| `terraform validate` | Checks syntax without hitting AWS |

**What `init` downloaded:** the `hashicorp/aws` provider plugin. **`.terraform/`** contains those downloaded plugins (machine-specific, git-ignored).

---

## 4. The state file — what it holds and why it matters

`terraform.tfstate` is JSON mapping each resource in my code to its real AWS ID and all its attributes (bucket name, instance ID, AMI, private IP, ARNs, tags).

- **Why never edit it manually:** Terraform trusts it as truth. Hand-editing desyncs it from reality and causes it to destroy/recreate or orphan resources.
- **Why never commit it to Git:** it can contain sensitive values in plain text, and concurrent edits corrupt it. It's in my `.gitignore` (`*.tfstate`, `*.tfstate.*`, `.terraform/`, `*.tfvars`).
- **Production fix (Day 64 preview):** move state to a remote S3 backend with locking, so a team shares one encrypted state and can't apply over each other.

**How Terraform knew the bucket already existed (Task 4):** it was already in the state file from the first apply, so `plan` showed only the new EC2 instance to add.

**Plan symbols:** `~` = in-place update, `+` = create, `-` = destroy, `-/+` = destroy-and-recreate (a change the provider can't do in place).

---

*Screenshots of apply, AWS verification, state, and destroy are in `./screenshots/`.*
