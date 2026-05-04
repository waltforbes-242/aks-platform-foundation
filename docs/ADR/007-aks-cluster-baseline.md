# ADR-007: AKS Cluster Baseline Design

## Status
Accepted

## Context

The platform requires a production-grade Kubernetes cluster to serve as the foundation for application workloads.

The cluster must:
- support multiple teams in the future
- integrate with Azure-native services
- be secure by default
- be observable from day one
- avoid unnecessary operational complexity

---

## Decision

We will deploy an AKS cluster with the following characteristics:

### Control Plane
- Public API endpoint
- Azure-managed control plane

### Networking
- Azure CNI powered by Cilium
- Subnet-per-node-pool design

### Node Pools
- System node pool for platform components
- User node pool for workloads
- Autoscaling enabled on both

### Identity
- System-assigned managed identity
- OIDC issuer enabled
- Workload Identity enabled

### Registry Integration
- ACR used as trusted registry
- AKS granted AcrPull role

### Observability
- Log Analytics Workspace for logs
- Azure Monitor Workspace for Prometheus metrics

---

## Alternatives Considered

### Private AKS Cluster
- Rejected for Phase 1 due to added complexity

### Kubenet Networking
- Rejected due to limited scalability and observability

### Single Node Pool
- Rejected due to lack of workload isolation

### Service Principal Authentication
- Rejected due to secret management risks

---

## Consequences

### Positive
- Production-aligned architecture
- Strong identity model
- Clear workload isolation
- Observability from day one

### Negative
- Slightly higher cost than minimal cluster
- Public API endpoint requires strong RBAC controls

---

## Revisit Criteria

This decision should be revisited when:
- multi-team workloads are onboarded
- stricter security requirements arise
- private networking becomes required
- egress control is introduced