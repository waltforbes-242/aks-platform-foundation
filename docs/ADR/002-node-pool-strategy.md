# ADR-002: Node Pool Strategy — System vs User Pools

## Status
Accepted

## Context
AKS clusters host both platform-critical components and application workloads with differing lifecycle, scaling, and failure characteristics. Mixing these concerns increases blast radius and complicates operations.

## Decision
We will separate **system node pools** and **user node pools**.

- System pools host Kubernetes and AKS-managed components.
- User pools host application workloads, scaled and upgraded independently.

## Alternatives Considered
### Single Node Pool
- **Pros**: Simpler configuration.
- **Cons**: Shared failure domain, upgrade coupling.
- **Rejected** due to poor isolation.

### Multiple User Pools Without System Separation
- **Pros**: Some workload isolation.
- **Cons**: Still risks platform instability.
- **Rejected**.

## Consequences
- **Operational**: Safer upgrades and clearer ownership boundaries.
- **Reliability**: Reduced blast radius during failures.
- **Cost**: Slight overhead for additional pools.
- **Scheduling**: Requires explicit taints, tolerations, and affinity rules.

## Revisit Criteria
- Introduction of workload-specific hardware (GPU, memory-optimized).
- Multi-tenancy requirements.
``