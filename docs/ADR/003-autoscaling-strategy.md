# ADR-003: Autoscaling Strategy — Cluster Autoscaler

## Status
Accepted

## Context
Workload demand is variable and unpredictable. Manual node scaling introduces operational risk and slow response to traffic changes.

## Decision
We will use **AKS Cluster Autoscaler** for node-level scaling.

It dynamically adjusts node counts based on pending pods and resource requirements.

## Alternatives Considered
### Manual Scaling
- **Pros**: Full control.
- **Cons**: Operationally unsafe, slow.
- **Rejected**.

### Node Auto-Provisioning
- **Pros**: Highly dynamic.
- **Cons**: Reduced predictability, higher cost risk.
- **Deferred** until workload maturity increases.

## Consequences
- **Operational**: Minimal manual intervention.
- **Cost**: Balanced responsiveness vs idle capacity.
- **Reliability**: Faster recovery from load spikes.
- **Complexity**: Requires correct pod resource requests.

## Revisit Criteria
- Workloads require heterogeneous node types dynamically.
- Cost variability becomes unacceptable.
``