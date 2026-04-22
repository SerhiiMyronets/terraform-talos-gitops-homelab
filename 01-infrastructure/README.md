# 01-infrastructure

This stage provisions the base infrastructure for the Kubernetes cluster using Talos Linux and Terraform on a Proxmox VE host.

It creates control plane and worker node virtual machines, injects machine configurations, and applies environment-specific patches to customize Talos behavior.

## Purpose

Supports single-node and HA configurations depending on variable overrides.

* Provision VMs on Proxmox with static IPs
* Generate and inject Talos machine configurations
* Apply Talos patches for control plane, workers, and Cilium mode
* Output all required data for the bootstrap phase

## Directory Structure

* `providers.tf` – defines Terraform providers
* `proxmox_nodes.tf` – VM resource definitions
* `talos_configs.tf` – generation and injection of Talos machine configs
* `variables.tf` – input variables
* `terraform.tfvars` – example configuration
* `outputs.tf` – exposed outputs (e.g., IPs, config paths)
* `patches/` – Talos machine config patches grouped by role or function

## Usage

Before you begin, add your Proxmox connection details to `terraform.tfvars`.

Example:

```hcl
proxmox_endpoint = "https://10.1.1.100:8006/"
proxmox_username = "root@pam"
proxmox_password = "your-password"
proxmox_node_name = "proxmox"
```

Additional cluster settings (e.g., Talos version, VM resources, IPs) are defined in [`variables.tf`](./variables.tf) and can be overridden if needed.

### Network topology

The default configuration uses the `10.1.1.0/24` subnet:

| Role | IP range |
|------|----------|
| Cluster VIP | `10.1.1.50` |
| Control plane nodes | `10.1.1.60`, `10.1.1.61`, … |
| Worker nodes | `10.1.1.70`, `10.1.1.71`, … |

The default topology is **1 control plane node + 3 worker nodes**.

### Worker node disks

Each worker node is provisioned with a second disk (`open_ebs_disk`, 100 GB) dedicated to OpenEBS storage. This disk is mounted and managed by the `00-mount-open-ebs-disk` Talos patch applied to all worker nodes.

### Talos patches

The following patches are applied during provisioning:

| Scope | Patch |
|-------|-------|
| common | `00-enable-kubeprism` |
| common | `01-enable-hostdns` |
| common | `02-enable-cluster-discovery` |
| common | `03-disable-network-cni` |
| common | `04-disable-kubeproxy` |
| common | `05-enable-otel-logging` |
| worker | `00-mount-open-ebs-disk` |
| controller | `00-set-network-vip` |

```bash
terraform init
terraform apply

# Save kubeconfig locally to access the cluster
terraform output -raw kubeconfig > ~/.kube/config

# Save talosconfig locally to manage the cluster with talosctl
terraform output -raw talosconfig > ~/.talos/config
```

Terraform will provision the VMs, generate Talos configurations, and return the required outputs for the next deployment stage. Wait until all nodes become `Ready` before proceeding. You can verify this using:

```bash
kubectl get nodes
```

Expected output:

```
NAME                      STATUS   ROLES           AGE     VERSION
talos-controlplane-01     Ready    control-plane   3m24s   v1.34.2
talos-worker-01           Ready    <none>          3m08s   v1.34.2
talos-worker-02           Ready    <none>          3m05s   v1.34.2
talos-worker-03           Ready    <none>          3m02s   v1.34.2
```

## Verification

Once the cluster is up, you can visually confirm successful provisioning:

### Proxmox VM view

This screenshot shows Talos VMs created in the Proxmox Virtual Environment, including control plane and worker nodes with their assigned IPs and resource allocations.

> ⚠️ The screenshot shows a 5-node cluster. The default configuration provisions 4 nodes (1 controlplane + 3 workers).

<img src="../assets/proxmox.png" width="1100"/>

### Talos Cluster Status

Cluster node status as seen via `k9s`, a terminal-based UI for managing Kubernetes clusters. Make sure `k9s` is installed locally to use this view.

<img src="../assets/k9s.png" width="1100"/>

## Navigation

[← Back to 00-prerequisite](../00-prerequisite/README.md) • [→ Continue to 02-bootstrap](../02-bootstrap/README.md)
