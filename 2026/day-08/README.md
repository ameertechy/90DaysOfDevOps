# Day 08 – Cloud Server Setup: AWS EC2 and Nginx Deployment

## Overview

Day 8 moved off the local VM and onto a real cloud server — an AWS EC2 instance running Ubuntu 26.04 LTS in the us-west-2 region.

The task: launch an instance, connect via SSH using a `.pem` key from Git Bash, install Nginx, configure the security group to allow HTTP traffic, customize the default page, and verify the server is reachable from the public internet.

This is not a simulation. The server was live on the internet, serving HTTP traffic on a public IP.

---

## What I Produced

- [`cloud-server-setup.md`](./cloud-server-setup.md)

---

## Key Observations

**EC2 is just a Linux server with a managed network layer on top.**
Once SSH'd in, everything I practiced in Days 3–7 applied immediately — `systemctl status nginx`, `journalctl -u nginx`, `ss -tulpn`, `tail -f /var/log/nginx/access.log`. The cloud does not change Linux. It changes how the server is provisioned and how network access is controlled.

**Security Groups are the cloud equivalent of a firewall — and they are stateful.**
Port 22 (SSH) was open by default. Port 80 (HTTP) had to be explicitly added to the inbound rules before the browser could reach Nginx. Without that rule, the server was running perfectly but completely unreachable from outside. Understanding this layer is critical — it is the first thing I check when a cloud service is "not responding."

**SSH with a `.pem` key is the production standard for cloud access.**
No password. The private key file on my laptop is the only credential. If it is lost or leaked, the instance access must be revoked immediately from the AWS console. This is why key pair management is a governance item, not just a convenience.

**The custom Nginx page confirmed end-to-end delivery.**
Modifying `/var/www/html/index.nginx-debian.html` and seeing my own text load on a public IP from a browser — that is the complete delivery chain: server → service → public network → client. Every layer working correctly.

---

## Infrastructure Details

| Property | Value |
|----------|-------|
| Cloud | AWS |
| Region | us-west-2 (Oregon) |
| Instance type | t3.small |
| OS | Ubuntu 26.04 LTS |
| Kernel | 7.0.0-1004-aws |
| SSH method | `.pem` key via Git Bash |
| Ports configured | 22 (SSH), 80 (HTTP) |
| Web server | Nginx |

---

## Real-World Tie-in

- This is the exact same process I follow when provisioning Linux VMs in the university data centre — the only difference is Hyper-V instead of EC2 and a physical network instead of a Security Group
- SSH key authentication without passwords is the same zero-trust principle I apply in JumpServer PAM — key-based, audited, no shared credentials
- Security Group configuration is conceptually identical to FortiGate firewall rules — define source, destination, port, action
- Nginx on EC2 is the starting point for every web application deployment in the coming days — Day 8 is the foundation

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#AWS` `#Linux` `#DevOps` `#Cloud`
