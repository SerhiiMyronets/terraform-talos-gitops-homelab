# 03-gitops

In this stage, your Kubernetes cluster becomes fully GitOps-driven with automated deployment of platform services, observability stack, and demo workloads.
Through Argo CD, all components—including platform services, observability tools, and workloads—are deployed in a declarative and reproducible manner.

## Purpose

This layer turns your cluster into a fully GitOps-managed platform, enabling reproducible deployments, real-time observability, and traceable demo applications.

Argo CD Applications are bootstrapped in a controlled order to ensure service readiness and interdependency handling. This approach enables reproducible, declarative deployment of all Kubernetes workloads via Git.

All Argo CD Applications target the `homelab` branch as their `targetRevision`.

## Structure

The GitOps layer uses a 4-tier App-of-Apps pattern. Each tier has a root Application YAML that manages a set of child Applications, one per component.

| Tier | Root YAML | Components |
| ---- | --------- | ---------- |
| `00-core` | `00-core-root.yaml` | argocd, cert-manager, cloudflared, external-secrets, gateway-system, metrics-server, minio, open-ebs |
| `01-platform` | `01-platform-root.yaml` | postgresql, strimzi-operator |
| `02-services` | `02-services-root.yaml` | kafka, otel-demo |
| `03-observability` | `03-observability.yaml` | fluent-bit, grafana, kube-state-metrics, loki, otel-operator, prometheus-node-exporter, tempo, victoria-metrics-operator, victoria-metrics-server |

### components/ directory

The `components/` directory contains per-component Argo CD Application definitions and Kustomize configurations. Each subdirectory corresponds to one component and holds the Application manifest plus any Kustomize overlays needed to deploy it.

#### components/99-archive/

`components/99-archive/` contains retired or experimental components that are no longer part of the active stack. These are preserved for reference but not deployed by any active root Application. Archived components include:

- longhorn
- jaeger
- hubble-ui
- kube-prometheus-stack
- jenkins
- harbor
- sonarqube
- vault

## Ingress and Routing

All services in this layer are exposed using the **Cilium Gateway API** via `HTTPRoute` resources. There is no ingress-nginx controller. Cilium handles L7 routing natively through its Gateway API implementation.

## Secrets Management

Secrets are managed using **External Secrets Operator** integrated with **Infisical** as the secrets backend. The `external-secrets` component in `00-core` installs the operator and configures the `ClusterSecretStore` that references Infisical. Application secrets are then declared as `ExternalSecret` resources that pull values from Infisical at sync time.

## Usage

> **Pre-requisite**: Ensure Argo CD is already running in your cluster. It was installed via Helmfile in the previous stage (`02-bootstrap`).

Apply the tiers in order. Each tier builds on the previous one — `01-platform` depends on core infrastructure from `00-core`, `02-services` depends on platform operators, and `03-observability` depends on services being available.

### Step-by-step deployment

```bash
# 1. Apply core infrastructure (Argo CD self-management, cert-manager, external-secrets, gateway, etc.)
kubectl apply -f applications/00-core-root.yaml

# 2. Apply platform operators (PostgreSQL, Strimzi)
kubectl apply -f applications/01-platform-root.yaml

# 3. Apply services (Kafka, otel-demo)
kubectl apply -f applications/02-services-root.yaml

# 4. Apply observability stack (Grafana, Loki, Tempo, VictoriaMetrics, etc.)
kubectl apply -f applications/03-observability.yaml
```

### Tier breakdown

* `00-core-root.yaml` — bootstraps the foundational layer:
  * Puts Argo CD itself under Argo CD management
  * Installs cert-manager for TLS certificate management
  * Deploys cloudflared for external tunnel access
  * Installs External Secrets Operator with Infisical integration
  * Configures the Cilium Gateway API gateway (`gateway-system`)
  * Deploys metrics-server, MinIO, and OpenEBS for storage

* `01-platform-root.yaml` — deploys platform-level operators:
  * PostgreSQL database
  * Strimzi Kafka operator

* `02-services-root.yaml` — deploys application workloads:
  * Kafka cluster (managed by Strimzi)
  * OpenTelemetry Demo (`otel-demo`) — a 21-microservice e-commerce application

* `03-observability.yaml` — deploys the full observability stack:
  * Grafana (dashboards and visualization)
  * Loki (log aggregation)
  * Tempo (distributed tracing)
  * VictoriaMetrics operator and server (metrics backend)
  * OpenTelemetry Operator
  * Fluent Bit (log forwarding)
  * kube-state-metrics and prometheus-node-exporter (cluster metrics)

After applying all tiers, you'll have a fully observable, GitOps-driven cluster with traceable demo workloads ready for exploration.

## UI Previews

Below are sample screenshots of key components that become available after deploying this layer.

### Argo CD

Argo CD web interface showing synced applications and their health/status.

<img src="../assets/argocd.png" width="1100"/>

### Grafana

Observability dashboards with real-time service-level metrics and performance data.

<img src="../assets/grafana.png" width="1100"/>

### Tempo

Trace timeline visualization inside Grafana using the Tempo datasource.

<img src="../assets/tempo.png" width="1100"/>

### OpenTelemetry Demo

The main frontend page of the otel-demo microservices-based e-commerce application.

<img src="../assets/otel-demo.png" width="1100"/>

All components shown above are deployed declaratively and updated automatically via Argo CD.

## Navigation

[← 02-bootstrap](../02-bootstrap/README.md) • [↑ Main project README](../README.md)
