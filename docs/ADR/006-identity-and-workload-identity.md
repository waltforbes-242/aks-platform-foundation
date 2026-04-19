# ADR-006: Identity Model — Entra ID + Workload Identity

## Status
Accepted

## Context
Pods require access to Azure resources without long-lived credentials or excessive privileges.

## Decision
We will use **Microsoft Entra ID with AKS Workload Identity** based on OIDC federation.

Each workload receives a least-privilege managed identity.

## Alternatives Considered
### Service Principals in Pods
- **Pros**: Legacy compatibility.
- **Cons**: Secret leakage risk.
- **Rejected**.

### Node Managed Identity
- **Pros**: Simpler.
- **Cons**: Over-privileged.
- **Rejected**.

## Consequences
- **Security**: Strong identity isolation.
- **Operational**: Easier rotation and auditing.
- **Complexity**: Requires correct federated identity configuration.

## Revisit Criteria
- Integration with Azure Key Vault CSI drivers.
- Cross-tenant identity scenarios.
``