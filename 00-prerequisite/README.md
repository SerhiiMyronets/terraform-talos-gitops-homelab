
# Prerequisites for Running Talos Kubernetes Cluster on Proxmox

This document describes the prerequisites and initial environment setup required to deploy a Kubernetes cluster using Talos Linux, Terraform, and Proxmox VE.

---

## Minimum Hardware Requirements

A physical server, mini PC, or spare laptop with virtualization support is sufficient.

| Resource    | Minimum (testing) | Recommended (production-like) |
|-------------|-------------------|-------------------------------|
| CPU Cores   | 4                 | 8+                            |
| RAM         | 8 GB              | 16 GB+                        |

> For running the full GitOps stack (observability, demo apps, load generation), at least 12 GB RAM is recommended.

---

## Required Software

Install the following CLI tools on your **local workstation** (not inside Proxmox):

### Mandatory

- `terraform`: Infrastructure provisioning
- `kubectl`: Kubernetes control interface
- `helmfile`: Declarative Helm release management
- `helm`: Dependency of `helmfile`
- `talosctl`: Talos Linux management CLI

### Optional

- `cilium`: Cilium CLI for CNI diagnostics

#### Installation (macOS / Ubuntu)

**macOS (Homebrew):**
```bash
brew install terraform kubectl helmfile helm
brew install talosctl cilium
```

**Ubuntu/Debian (APT + manual binaries):**
```bash
sudo apt update && sudo apt install -y terraform kubectl helmfile helm
# talosctl and cilium must be downloaded manually
```

---

## Proxmox VE Installation

Proxmox must be installed directly on the host machine that will run the cluster.

1. Download ISO: https://www.proxmox.com/en/downloads
2. Flash to USB (e.g., with Balena Etcher)
3. Boot the machine and install Proxmox
4. Access the UI: `https://<proxmox-ip>:8006`

> Ensure virtualization support (VT-x / AMD-V) is enabled in BIOS/UEFI.

---

## Post-Install Configuration

Run a standard setup script to configure repositories and base settings:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/tools/pve/post-pve-install.sh)"
```

This will:
- Enable community repositories
- Update package lists
- Remove subscription notices
- Apply default Proxmox tweaks

---

## Proxmox Network Configuration

The Kubernetes cluster VMs connect directly to the main network bridge (`vmbr0`). No NAT or isolated bridge is required — VMs receive IPs on the `10.1.1.0/24` subnet and are reachable from your workstation without any additional routing tricks.

> Replace all instances of `enp3s0` with your actual network interface (check via `ip a` or `ip link`).

Example `/etc/network/interfaces`:

```ini
# loopback
auto lo
iface lo inet loopback

# main interface
auto enp3s0
iface enp3s0 inet static
    address  10.1.1.100/24
    gateway  10.1.1.1

# main bridge for cluster VMs
auto vmbr0
iface vmbr0 inet static
    address  10.1.1.100/24
    gateway  10.1.1.1
    bridge-ports enp3s0
    bridge-stp off
    bridge-fd 0

source /etc/network/interfaces.d/*
```

Apply changes with:

```bash
ifreload -a
```

---

## Static Route (Local Machine)

To allow your workstation to reach Talos nodes on the cluster network, add a static route:

```bash
sudo route -n add 10.1.1.0/24 10.1.1.100
```

Replace `10.1.1.100` with your Proxmox host's IP address if it differs.

---

## Navigation

[← Back to Main project README](../README.md) • [→ Continue to 01-infrastructure](../01-infrastructure/README.md)
