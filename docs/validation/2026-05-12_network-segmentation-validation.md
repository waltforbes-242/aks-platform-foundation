# Network Segmentation Validation — AKS Platform Foundation

## Objective

Validate network segmentation and workload placement within the AKS platform foundation.

This validation confirms:
- subnet segmentation
- node pool subnet isolation
- Azure CNI pod IP allocation
- workload placement onto intended network segments
- future multi-team network readiness

---

## Environment

| Item | Value |
|---|---|
| Cluster | apf-aks-prod |
| Region | eastus |
| Network Plugin | Azure CNI |
| Data Plane | Cilium |
| Date | 2026-05-12 |

---

## Validation Scope

The following capabilities were validated:

- subnet creation
- node pool subnet assignment
- pod IP allocation
- workload scheduling onto intended node pools
- Azure CNI VNet integration
- ClusterIP service networking

---

## Architecture Context

The AKS platform uses dedicated subnets for workload isolation.

### Virtual Network

| Resource | Address Space |
|---|---|
| apf-vnet-prod | 10.77.0.0/16 |

---

### Node Pool Subnets

| Subnet | Purpose | CIDR |
|---|---|---|
| systempool1 | Kubernetes system workloads | 10.77.0.0/22 |
| userpool1 | Application workloads | 10.77.4.0/22 |

Additional reserved subnets exist for future expansion.

---

## Commands Executed

### Validate Node Placement

```bash
kubectl get nodes -o wide
```

---

### Validate Node Labels

```bash
kubectl get nodes --show-labels
```

---

### Validate Application Workload Placement

```bash
kubectl get pods -n apps -o wide
```

---

### Validate Service Networking

```bash
kubectl get svc -n apps
```

---

## Results

### Node Pool Segmentation

The cluster successfully provisioned:

- dedicated system node pool
- dedicated user node pool

Observed node pools:

```text
aks-systempool1-*
aks-userpool1-*
```

---

### Pod Placement Validation

Validation workloads were successfully scheduled onto:

```text
aks-userpool1-*
```

using:

```yaml
nodeSelector:
  nodepool-role: user
```

This confirms:
- workload placement enforcement
- workload isolation strategy
- correct scheduler behavior

---

### Pod IP Allocation

Observed pod IPs:

```text
10.77.4.x
```

These IPs fall within:

```text
10.77.4.0/22
```

which is the dedicated user workload subnet.

This confirms:
- Azure CNI pod networking
- VNet-integrated pod IP allocation
- subnet alignment between node pools and workloads

---

### Service Networking

Observed ClusterIP service allocation:

```text
10.78.x.x
```

This confirms:
- Kubernetes service networking functioning
- service CIDR allocation functioning correctly

---

## Operational Observations

### Azure CNI Benefits

Azure CNI provides:

- routable pod IPs
- direct VNet integration
- improved observability
- enterprise network compatibility

This aligns with enterprise networking expectations and future hybrid connectivity scenarios.

---

### Workload Isolation Strategy

The subnet-per-node-pool model reduces blast radius between:

- platform components
- application workloads

This architecture prepares the platform for future:
- network policies
- egress controls
- firewall integration
- multi-team segmentation

---

### Cilium Integration

Observed node labels confirmed:

```text
kubernetes.azure.com/ebpf-dataplane=cilium
```

This validates:
- Cilium dataplane activation
- modern eBPF-based networking support
- future network policy readiness

---

## Security Considerations

Subnets alone are not sufficient security boundaries.

Future controls will include:

- Kubernetes NetworkPolicies
- egress restrictions
- Azure Firewall or NAT Gateway
- workload identity isolation
- namespace RBAC segmentation

---

## Conclusion

Network segmentation is functioning correctly.

The AKS platform successfully supports:

- subnet-per-node-pool architecture
- Azure CNI pod networking
- workload placement isolation
- VNet-integrated pod IP allocation
- future enterprise networking expansion

This validates the foundational network segmentation architecture of the platform.