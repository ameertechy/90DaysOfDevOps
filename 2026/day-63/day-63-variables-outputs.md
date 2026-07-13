# Day 63 / TerraWeek Day 2 — Variables, Outputs & Expressions Notes

## The five variable types

| Type | Example in my config | Notes |
|---|---|---|
| `string` | `region`, `project_name`, `environment` | Quote version numbers or YAML/HCL may parse them as numbers |
| `number` | `instance_count` | Drives `count` on the instance |
| `bool` | `enable_detailed_monitoring` | Combined with a conditional in locals |
| `list(number)` | `allowed_ports = [22, 80, 443]` | Fed a `dynamic` block → became 3 SG ingress rules |
| `map(string)` | `extra_tags = {}` | Merged onto common tags with `merge()` |

Plus: **no `default` = required** (`project_name` — plan prompts for it), and `validation { condition, error_message }` for custom rules (`contains(["dev","staging","prod"], var.environment)`).

## Variable precedence (lowest → highest)

1. variable `default`
2. `TF_VAR_name` environment variables
3. `terraform.tfvars` (auto-loaded)
4. `*.auto.tfvars` (alphabetical)
5. `-var-file="x.tfvars"` and `-var="k=v"` CLI flags — last one on the command line wins

Proved hands-on: `terraform.tfvars` gave t3.micro → `-var-file="prod.tfvars"` gave t3.small → `-var="instance_type=t2.nano"` beat them all.

## Expressions used

- **Interpolation:** `name_prefix = "${var.project_name}-${var.environment}"` → `terraweek-dev`
- **Conditional:** `var.environment == "prod" ? true : var.enable_detailed_monitoring` — monitoring is policy in prod, choice elsewhere
- **Function:** `merge(common, var.extra_tags)` — later map wins on key conflicts
- **Dynamic block:** `dynamic "ingress" { for_each = var.allowed_ports }` — one nested block generated per list element
- **Splat:** `aws_instance.web[*].id` — collect an attribute across all `count` copies

## Variables vs locals

`var.*` = inputs from outside (person/tfvars/CI). `local.*` = values derived inside the config. If the user should choose it → variable; if it's computed from other values → local.

## Outputs

Six outputs (instance IDs, public IPs, public DNS, SG ID, AMI ID). Query patterns:
```bash
terraform output                       # all
terraform output instance_public_ips  # one value
terraform output -json                 # machine-readable — the handoff to scripts/CI/Ansible
```

## Data sources

- `aws_ami` — Amazon Linux 2 (`owners=["amazon"]`, hvm + gp2 filters, `most_recent`), resolved `ami-04d78408ebc2960db` in us-west-2
- `aws_availability_zones` — instance placed in `names[0]` (us-west-2a) by expression, portable across regions

*Screenshots: required-var prompt, CLI precedence override, apply with outputs, `terraform output` — in `./screenshots/`.*
