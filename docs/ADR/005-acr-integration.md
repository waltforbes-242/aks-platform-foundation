# ADR-005: Image Supply Chain — ACR Integration

## Status
Accepted

## Context
Container images must be securely built, stored, and pulled without embedding static credentials or expanding the attack surface of the AKS platform.

This platform is:
- single-region
- Azure-first
- designed for AKS integration through managed identity
- intended to support CI build, scan, and push workflows before later GitOps-based deployment

Key concerns include:
- secret sprawl from registry credentials
- weak control over image provenance
- operational simplicity for a first production-grade baseline
- future compatibility with workload identity, GitOps, and tighter network controls

---

## Decision
We will use **Azure Container Registry (ACR)** as the platform image registry.

For Phase 1, the ACR design is:

- **SKU:** Standard
- **Authentication model:** Azure-native identity and RBAC
- **Admin user:** Disabled
- **Network access:** Public endpoint enabled
- **Private endpoint:** Deferred
- **Geo-replication:** Deferred
- **AKS pull model:** Managed identity / AcrPull role assignment in later AKS phase
- **CI push model:** Azure identity-based push, not username/password secrets

This establishes ACR as the trusted image source for the platform.

---

## Why

### Security
- Avoids static registry credentials and imagePullSecret sprawl
- Aligns with Azure-native identity patterns
- Supports least-privilege access models for AKS and CI/CD later

### Operational Simplicity
- Standard SKU is sufficient for the initial single-region platform baseline
- Public endpoint avoids premature private networking complexity
- Azure-native service reduces registry operations burden

### Platform Alignment
- Cleanly supports the expected CI flow of:
  - build
  - scan
  - push to ACR
- Cleanly supports later AKS integration through managed identity and RBAC

---

## Alternatives Considered

### External Registry (Docker Hub or similar)
- **Pros:** Familiar, low setup friction
- **Cons:** Rate limits, weaker Azure integration, more fragmented auth model
- **Rejected** due to weaker platform alignment and less consistent enterprise control.

### Secrets-Based Registry Authentication
- **Pros:** Simple to understand
- **Cons:** Secret sprawl, poor rotation hygiene, weaker least-privilege posture
- **Rejected** because it does not meet employer-grade security expectations.

### Premium ACR in Phase 1
- **Pros:** Private link, geo-replication, richer networking capabilities
- **Cons:** Higher cost and unnecessary complexity for a single-region baseline
- **Rejected** for now in favor of a cost-aware Standard SKU.

### Private Endpoint for ACR in Phase 1
- **Pros:** Stronger network isolation
- **Cons:** Additional DNS/private networking complexity before the platform needs it
- **Deferred** until private cluster or controlled egress requirements justify it.

---

## Consequences

### Security
- No admin credentials required for normal operation
- No static secrets required for AKS image pulls later
- Stronger identity boundary between build systems, platform runtime, and workloads

### Operational
- Simple initial rollout with low operational burden
- Easy later integration with AKS using managed identity
- Public endpoint remains a deliberate trade-off until tighter network controls are needed

### Cost
- Standard SKU is a pragmatic baseline
- Avoids Premium cost before features like private endpoints or geo-replication are needed

### Complexity
- Lower complexity now
- Leaves room for later evolution to:
  - private endpoint
  - Premium SKU
  - image signing / provenance enhancements
  - retention and cleanup policies

---

## Design Review Justification
This decision passes review because:

- it removes secret-based registry auth from the platform baseline
- it aligns with Azure-native identity patterns
- it supports the intended CI supply path cleanly
- it avoids premature private networking complexity
- it is cost-aware for a single-region employer-grade foundation

---

## Revisit Criteria
This ADR must be revisited if any of the following occur:

- Private AKS or controlled egress becomes mandatory
- ACR requires private endpoint access
- Multi-region image replication becomes necessary
- Stronger supply-chain controls such as image signing become required
- Retention, cleanup, or quarantine capabilities become operational priorities
- Multi-cloud portability becomes a platform requirement