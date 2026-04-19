# ADR-001: Networking Model — Azure CNI Powered by Cilium

## Status
Accepted

## Context
This AKS cluster hosts production workloads that require predictable pod networking, native Azure integration, and fine-grained network policy enforcement. The cluster is single-region (eastus) with a public API endpoint and must support future platform capabilities such as advanced network policies and observability.

Key concerns include IP address management, security boundaries, and operational debuggability at scale.

## Decision
We will use **Azure CNI with Cilium** as the networking model for AKS.

Pods receive IP addresses from the Azure VNet, enabling first-class integration with Azure networking constructs. Cilium is used as the dataplane to provide eBPF-powered networking, network policy enforcement, and enhanced observability.

## Alternatives Considered
### Kubenet
- **Pros**: Simpler IP usage, smaller VNet footprint.
- **Cons**: NAT-based pod networking, reduced visibility, limited future extensibility.
- **Rejected** due to operational opacity and weaker security posture.

### Azure CNI Overlay
- **Pros**: Reduced VNet IP pressure.
- **Cons**: Additional abstraction layer, fewer advanced dataplane capabilities.
- **Deferred** until operational maturity or IP constraints require it.

## Consequences
- **Operational**: Requires upfront IP planning; easier packet-level debugging with Cilium.
- **Security**: Stronger network policy enforcement and clearer trust boundaries.
- **Cost**: Larger VNet IP allocation but reduced operational toil.
- **Complexity**: Slightly higher conceptual complexity, offset by improved observability.

## Revisit Criteria
- IP exhaustion becomes a limiting factor.
- Overlay networking reaches parity with required Cilium features.
- Multi-cluster or hub‑spoke networking introduces new constraints.
``