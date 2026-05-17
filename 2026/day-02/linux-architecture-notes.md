# Linux Architecture Notes

## Linux Core Components

### 1. Kernel
The kernel is the core of Linux.

Responsibilities:
- process management
- memory management
- hardware communication
- filesystem management

---

### 2. Shell
The shell acts as the communication layer between user and kernel.

Examples:
- bash
- zsh
- sh

Example command:

```bash
echo "Hello Dosto"
```

---

### 3. Applications
Applications run on top of Linux.

Examples:
- Docker
- Kubernetes
- Jenkins
- Nginx

---

# Linux Boot Process

```text
Power ON
→ BIOS/Firmware
→ Bootloader
→ Kernel
→ systemd
→ Applications
```

---

# systemd

Important points:
- PID 1 process
- manages services
- controls startup
- manages logs
- handles service restarts

Useful command:

```bash
systemctl status ssh
```

---

# Process States

| State | Meaning |
|---|---|
| R | Running |
| S | Sleeping |
| T | Stopped |
| Z | Zombie |

---

# Important Commands

## Process Monitoring

```bash
ps aux
top
```

## Resource Monitoring

```bash
df -h
free -h
```

## Networking

```bash
ip a
```

---

# Key Understanding

Linux is the foundation of most modern DevOps and cloud environments.

Understanding:
- processes
- services
- logs
- system resources

is essential for troubleshooting and production operations.