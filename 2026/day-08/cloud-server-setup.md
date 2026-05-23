# Cloud Server Setup – AWS EC2 and Nginx Deployment
*Day 08 | Sat 24 May 2026 | #90DaysOfDevOps 2026*

---

## Step 1 — Launch EC2 Instance

**What EC2 is:**
EC2 stands for **Elastic Compute Cloud**. It is AWS's virtual machine service — on-demand Linux (or Windows) servers that start in under 60 seconds and bill by the hour. "Elastic" means I can resize, stop, start, or terminate at any time without physical hardware constraints.

**Instance configuration used:**

| Setting | Value | Why |
|---------|-------|-----|
| AMI | Ubuntu 26.04 LTS | Standard Linux base — same OS family as my lab VM |
| Instance type | t3.small | 2 vCPU, 2GB RAM — sufficient for Nginx and learning |
| Region | us-west-2 (Oregon) | Shubham's batch standard region |
| Key pair | `.pem` file | SSH authentication — no password |
| Storage | 20GB gp3 | Default EBS volume — SSD-backed |

**AMI** stands for **Amazon Machine Image** — a pre-built OS snapshot that EC2 uses to launch the instance. Think of it as the equivalent of an ISO file, but hosted in AWS and ready to boot in seconds.

---

## Step 2 — Configure Security Group

**What a Security Group is:**
A Security Group is a stateful virtual firewall that controls what traffic is allowed in (inbound) and out (outbound) of an EC2 instance. Every instance must have at least one Security Group.

**Stateful** means: if I allow inbound traffic on port 80, the return traffic (response back to the browser) is automatically allowed without a separate outbound rule. This is different from stateless firewalls (like traditional ACLs) where both directions must be defined explicitly.

**Inbound rules configured:**

| Type | Protocol | Port | Source | Purpose |
|------|----------|------|--------|---------|
| SSH | TCP | 22 | My IP | Remote terminal access |
| HTTP | TCP | 80 | 0.0.0.0/0 | Public web access |

**Why port 80 had to be added manually:**
By default, a new Security Group only allows outbound traffic. No inbound ports are open except what I explicitly allow. Nginx was running perfectly on the server, but the browser could not reach it until port 80 was added to the inbound rules.

**`0.0.0.0/0`** means "allow from any IP address" — the entire internet. Appropriate for a public web server. For SSH, I restricted it to my own IP to reduce attack surface.

---

## Step 3 — Connect via SSH

**From Git Bash on my laptop:**

```bash
# Set correct permissions on the .pem key file (required — SSH rejects keys with open permissions)
chmod 400 mujadevops-udaan-key.pem

# Connect to the instance
ssh -i "mujadevops-udaan-key.pem" ubuntu@<public-ip>
```

**Flag breakdown:**
- `ssh` — Secure Shell client
- `-i` — stands for **identity file** — specifies the private key to use for authentication
- `"mujadevops-udaan-key.pem"` — the private key file downloaded from AWS when creating the key pair
- `ubuntu@<public-ip>` — username `ubuntu` is the default for Ubuntu AMIs on AWS. `ec2-user` is default for Amazon Linux.

**Why `chmod 400` is required:**
SSH refuses to use a private key file if it has permissions that allow other users to read it. `400` = owner read-only, no permissions for group or others. Without this step, SSH throws: `WARNING: UNPROTECTED PRIVATE KEY FILE! Permissions 0644 are too open.`

**What I saw after connecting:**
```
Welcome to Ubuntu 26.04 LTS (GNU/Linux 7.0.0-1004-aws x86_64)
System load:  0.0
Usage of /:   11.0% of 18.25GB
Memory usage: 14%
IPv4 address for ens5: 172.31.33.75
```

This is the EC2 instance MOTD (Message of the Day) — AWS adds system info here automatically. `ens5` is the primary network interface on AWS instances.

---

## Step 4 — Update Packages and Install Nginx

```bash
# Update the package index — always first on a fresh server
sudo apt update
```

**What `apt update` does:** Downloads the latest package list from Ubuntu's repositories. It does NOT install or upgrade anything — it only refreshes the index so `apt` knows what versions are available. Always run this before installing anything on a fresh instance.

```bash
# Install Nginx
sudo apt install -y nginx
```

**Flag breakdown:**
- `apt install` — install a package from the repository
- `-y` — automatically answer "yes" to all prompts — required for non-interactive/scripted installs

**What happens during install:**
1. `apt` downloads the Nginx package and all its dependencies
2. Installs binaries to `/usr/sbin/nginx`
3. Places config files in `/etc/nginx/`
4. Creates log directories in `/var/log/nginx/`
5. Registers Nginx as a systemd service
6. **Starts Nginx automatically** — on Ubuntu, services start immediately after install

---

## Step 5 — Verify Nginx is Running

```bash
# Check service status
systemctl status nginx
```

**Expected output:**
```
● nginx.service - A high performance web server and a reverse proxy server
     Active: active (running) since ...
   Main PID: XXXX (nginx)
```

```bash
# Confirm port 80 is bound
sudo ss -tulpn | grep :80
```

```bash
# Test locally before testing from browser
curl -I http://localhost
# Expected: HTTP/1.1 200 OK
```

```bash
# Check Nginx logs
sudo tail -f /var/log/nginx/access.log
```

---

## Step 6 — Customize the Default Page

Nginx's default page lives at `/var/www/html/index.nginx-debian.html` on Ubuntu.

```bash
# Navigate to web root
cd /var/www/html

# List files
ls -lh
# index.nginx-debian.html  ← the default page

# Edit the default page
sudo nano index.nginx-debian.html
```

**What I changed:** Added my own identification to the page body:
```html
I'm Ameerul! This is my very first NGINX host !!
```

```bash
# Verify Nginx config is still valid after any edits
sudo nginx -t

# Reload Nginx to apply changes (no downtime — graceful reload)
sudo systemctl reload nginx
```

**`reload` vs `restart`:**

| Command | Behaviour | When to Use |
|---------|-----------|-------------|
| `systemctl restart nginx` | Stops then starts — brief downtime | Config changes that require full restart |
| `systemctl reload nginx` | Sends SIGHUP — workers reload gracefully, zero downtime | Config and content changes in production |

Always use `reload` in production. `restart` drops active connections.

---

## Step 7 — Verify from Browser

Opened `http://<public-ip>` in browser.

**Result:** Custom Nginx page loaded successfully — confirming:
- EC2 instance running ✅
- Nginx service active ✅
- Security Group port 80 open ✅
- Public IP routable ✅
- Custom content served ✅

---

## End-to-End Architecture

```
My Laptop (Git Bash)
        │
        │  SSH :22 (.pem key auth)
        ▼
AWS Security Group (inbound: 22, 80)
        │
        ▼
EC2 Instance (Ubuntu 26.04 LTS, t3.small, us-west-2)
        │
        ▼
Nginx (listening on :80)
        │
        ▼
/var/www/html/index.nginx-debian.html
        │
Browser ◄──── HTTP response ─────────────────────────
```

---

## Key Commands Reference

```bash
# SSH into EC2
ssh -i "keyfile.pem" ubuntu@<public-ip>

# Set .pem file permissions (required once)
chmod 400 keyfile.pem

# Update packages
sudo apt update

# Install Nginx
sudo apt install -y nginx

# Service management
systemctl status nginx
sudo systemctl start nginx
sudo systemctl stop nginx
sudo systemctl reload nginx
sudo systemctl enable nginx

# Verify port binding
sudo ss -tulpn | grep :80

# Test locally
curl -I http://localhost

# View live access logs
sudo tail -f /var/log/nginx/access.log

# Validate config
sudo nginx -t

# Web root location
ls /var/www/html/
```

---

*Day 08 | Sat 24 May 2026 | #90DaysOfDevOps 2026*
