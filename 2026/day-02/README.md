# Day 02 - Linux Architecture, Processes & systemd 🚀

## Overview

Today was focused on revisiting Linux fundamentals and understanding how Linux works internally from a DevOps and troubleshooting perspective.

Although I already work with Linux systems in infrastructure operations, today's learning helped strengthen foundational concepts that are extremely important for DevOps, SRE, troubleshooting, monitoring, and production support.

The session covered:
- Linux architecture
- Linux boot flow
- Processes
- systemd
- Filesystem hierarchy
- Basic Linux commands
- Resource monitoring
- Networking basics

---

# What is Linux?

Linux is an open-source operating system created by Linus Torvalds in 1991 as a personal project.

Today Linux powers:
- cloud platforms
- web servers
- containers
- Kubernetes clusters
- DevOps infrastructure
- enterprise applications

Most production systems and DevOps environments heavily rely on Linux.

---

# Linux Distributions

Some popular Linux distributions:
- Ubuntu
- Debian
- RHEL
- CentOS
- Fedora

Each distribution is built around the Linux kernel with different package managers, tools, and enterprise use cases.

---

# Linux Architecture

Linux architecture can be understood in layers:

## Applications
Applications like:
- Docker
- Kubernetes
- Nginx
- Jenkins
- Databases

## Shell
The shell acts as the interface between users and the Linux kernel.

Examples:
- Bash
- Zsh
- Sh

Users execute commands through the shell.

Example:

```bash
echo "Hello Dosto"
```

The shell communicates with the kernel to execute the requested operation.

## Kernel
The kernel is the core component (heart) of Linux.

Responsibilities:
- Process management
- Memory management
- Hardware communication
- File system management
- Resource allocation

The Linux kernel was originally written in C by Linus Torvalds.

---

# Linux Boot Flow

Linux startup sequence:

```text
Power ON
→ BIOS / Firmware
→ Bootloader
→ Kernel
→ systemd (PID 1)
→ Services & Applications
```

---

# Understanding systemd

`systemd` is the first userspace process started by the Linux kernel.

Important points:
- systemd runs as PID 1
- manages system services
- handles startup processes
- controls service restarts
- manages logs and targets

Why systemd matters in DevOps:
- service troubleshooting
- monitoring failed services
- restarting applications
- checking logs during incidents

---

# Processes in Linux

Everything running in Linux is a process.

Common process states:
- Running (R)
- Sleeping (S)
- Stopped (T)
- Zombie (Z)

Process monitoring is extremely important in production troubleshooting.

---

# Filesystem Hierarchy

Important Linux concepts:
- Everything starts from `/`
- Everything is treated as a file or directory
- Everything running is a process

---

# Commands Practiced Today

## Basic Commands

```bash
pwd
ls
cd
touch
echo
cat
```

## Resource Monitoring

```bash
df -h
free -h
```

## Process Monitoring

```bash
top
ps aux
```

## systemd & Services

```bash
systemctl status ssh
```

## Networking

```bash
ip a
```

---

# Key Learning

Today's learning reinforced how Linux internals, processes, and system services work together behind the scenes.

As someone transitioning toward DevOps and SRE, understanding Linux deeply is essential because troubleshooting production systems depends heavily on:
- logs
- services
- processes
- networking
- system resources

---

# Additional Learning

At the end of the session, a live quiz helped reinforce:
- Linux architecture
- boot process
- process understanding
- systemd concepts

It also exposed areas where I want to dive deeper in upcoming days.

#90DaysOfDevOps 🚀