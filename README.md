# Talos Kubernetes Cluster on Proxmox with Terraform

This repository contains infrastructure-as-code configurations for deploying a minimal, production-grade Kubernetes cluster using Talos Linux and Terraform on Proxmox VE. This repository provides a fully declarative, script-free setup: Talos is configured and installed automatically during VM provisioning via Terraform.

## Overview

This project is designed for enthusiasts, students, or professionals who want to gain hands-on experience with a production-grade GitOps Kubernetes cluster using modest hardware — such as an old laptop or mini PC. It offers a fully automated deployment pipeline without requiring cloud resources or expensive infrastructure.

The Kubernetes cluster is composed of multiple control plane and worker nodes provisioned on a Proxmox host using Terraform. Talos Linux is injected and configured automatically as part of the VM provisioning step. The configuration supports high availability (HA) and uses a virtual IP for the control plane endpoint. The deployment includes core platform components (ingress, certificate management, GitOps), observability stack (metrics, logs, traces), and demo microservices applications for testing.

## Architecture

The Kubernetes cluster operates on the main network subnet (`10.1.1.0/24`) with virtual machines provisioned directly on a Proxmox VE host. The main bridge (`vmbr0`) is used to provide connectivity. Each node is assigned a static IP from this subnet. The control plane node shares a virtual IP (`10.1.1.50`) for the Kubernetes API.

```
Proxmox VE (10.1.1.100)
  └─ vmbr0: 10.1.1.1 (Gateway)
       ├─ controlplane-1: 10.1.1.60
       ├─ worker-1:       10.1.1.70
       ├─ worker-2:       10.1.1.71
       ├─ worker-3:       10.1.1.72
       └─ cluster VIP:    10.1.1.50 (Kubernetes API)
```

A static route to `10.1.1.0/24` must be configured on the developer workstation via the Proxmox host (`10.1.1.100`).

## Features

* 1 control plane node + 3 worker nodes (Talos `v1.12.4`, Kubernetes `1.34.2`)
* Fully declarative setup (no shell scripts)
* Talos Linux installed and configured via Terraform
* Proxmox-native VM provisioning
* GitOps with Argo CD and Helmfile
* Cilium CNI with kube-proxy disabled and Gateway API (HTTPRoute) for ingress
* OpenEBS for persistent volumes
* External Secrets with Infisical for secrets management
* Full observability stack with OpenTelemetry Collector (metrics via VictoriaMetrics, logs via Loki, traces via Tempo, dashboards via Grafana)
* Demo microservices instrumented for end-to-end tracing and performance metrics collection

## Directory Structure

| Path                                                  | Description                                                                                |
| ----------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| [`00-prerequisite/`](./00-prerequisite/README.md)     | Environment preparation: hardware requirements, dependencies, Proxmox and networking setup |
| [`01-infrastructure/`](./01-infrastructure/README.md) | Terraform configurations for Proxmox VM provisioning and Talos injection                   |
| [`02-bootstrap/`](./02-bootstrap/README.md)           | Bootstraps the cluster with Cilium and Argo CD only using Helmfile                         |
| [`03-gitops/`](./03-gitops/README.md)                 | Deploys applications via Argo CD using a 4-tier App-of-Apps (`00-core`, `01-platform`, `02-services`, `03-observability`) |


## UI Preview

Below is a preview of the cluster after deployment. For a complete set of UI screenshots, see the [03-gitops UI Previews](./03-gitops/README.md#ui-previews).

|                    Proxmox                    |                    Argocd                    |
|:---------------------------------------------:|:--------------------------------------------:|
| <img src="./assets/proxmox.png" width="400"/> | <img src="./assets/argocd.png" width="400"/> |
|                    Grafana                    |                    Tempo                     |
| <img src="./assets/grafana.png" width="400"/> | <img src="./assets/tempo.png" width="400"/>  |

## Getting Started

To get started, begin with [00-prerequisite](./00-prerequisite/README.md), which walks through system setup, required dependencies, and network configuration.