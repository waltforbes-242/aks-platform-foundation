# ADR-005: Image Supply Chain — ACR Integration

## Status
Accepted

## Context
Container images must be securely built, stored, and pulled without embedding secrets or increasing attack surface.

## Decision
We will use **Azure Container Registry (ACR)** integrated with AKS using **managed identity**.

## Alternatives Considered
### External Registry (Docker Hub)
- **Pros**: Convenience.
- **Cons**: Rate limits, weaker security controls.
- **Rejected**.

### Secrets-Based Auth
- **Pros**: Simple.
- **Cons**: Secret sprawl.
- **Rejected**.

## Consequences
- **Security**: No static credentials in clusters.
- **Performance**: Reduced pull latency due to locality.
- **Cost**: Predictable Azure-native billing.

## Revisit Criteria
- Multi-cloud portability requirements.
- Advanced supply-chain signing (e.g., Notary v2).
``