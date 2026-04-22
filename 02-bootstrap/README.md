# 02-bootstrap

This stage installs the core networking and GitOps components into the Kubernetes cluster using Helmfile.

It assumes that the cluster is already initialized and accessible using the generated `kubeconfig` from the previous stage (`01-infrastructure`).

## Purpose

The components installed in this phase provide the cluster CNI (Cilium) and the GitOps controller (Argo CD). All subsequent workloads are managed by Argo CD via the `03-gitops` layer.

## Installed Components

| Name      | Chart version | Purpose                                        |
| --------- | ------------- | ---------------------------------------------- |
| `cilium`  | `1.19.0`      | CNI with kube-proxy replacement and Gateway API |
| `argo-cd` | `9.4.2`       | GitOps controller for managing Kubernetes apps  |

## Prepare Hook

Before Helmfile applies any Helm releases, it runs a `prepare` hook. This hook performs two steps:

1. **Initial Kubernetes secrets** — applies cluster secrets (e.g. image pull secrets, external-secrets bootstrap credentials) via kustomize so they are available before any chart is installed.
2. **Argo CD CRDs** — applies the Argo CD Custom Resource Definitions server-side (`--server-side`) before the Argo CD Helm release runs, avoiding CRD size limits that can cause a standard `kubectl apply` to fail.

## Cilium Configuration

Cilium is deployed with the following features enabled:

- **kube-proxy replacement** — Cilium replaces `kube-proxy` entirely using eBPF for service routing.
- **Gateway API** — Cilium implements the Kubernetes Gateway API with ALPN and `AppProtocol` support for HTTP/2 and gRPC routing.
- **L2 announcements** — Cilium announces LoadBalancer service IPs on the local L2 network, enabling bare-metal load balancing without an external LB.
- **Hubble relay + UI** — the Hubble observability plane is enabled with both the relay (gRPC API) and the web UI for network flow visibility.
- **Prometheus metrics** — Cilium exposes Prometheus metrics on port `9962`.

## Usage

Before running this stage, make sure you have:

* Access to the cluster via `kubeconfig`
* Talos cluster is fully bootstrapped and reachable
* Helmfile and Helm installed on your machine

To apply the bootstrap components:

```bash
helmfile apply
```

This command runs the prepare hook and then installs Cilium and Argo CD with their configured values.

## Readiness Check

After applying, verify that both components are running:

```bash
# Check Cilium agent status
cilium status --wait

# Check Argo CD server deployment
kubectl get deployments -n argocd
```

Example output when Argo CD is ready:

```
NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
argocd-applicationset-controller   1/1     1            1           2m
argocd-dex-server                  1/1     1            1           2m
argocd-notifications-controller    1/1     1            1           2m
argocd-redis                       1/1     1            1           2m
argocd-repo-server                 1/1     1            1           2m
argocd-server                      1/1     1            1           2m
```

Once both checks pass, the cluster is running Cilium CNI and Argo CD is ready to manage GitOps applications.

## Navigation

[← Back to 01-infrastructure](../01-infrastructure/README.md) • [→ Continue to 03-gitops](../03-gitops/README.md)
