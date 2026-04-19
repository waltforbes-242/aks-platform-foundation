
## Enforcement

- AKS pulls images only from ACR
- No ad-hoc public image pulls (future: policy enforcement)
- Image pull uses managed identity (no secrets)

## Risks Addressed

- supply chain attacks
- unverified images
- credential leakage via pull secrets

## Future Enhancements

- image signing (Cosign / Notary)
- admission policies restricting registries

## Design Rationale

Establishes a controlled supply chain boundary early.

---

# 5. Workload Boundary

## Definition

Separates:

- system workloads
- platform workloads
- application workloads

## Implementation

### System Workloads

- scheduled on system node pool
- critical components only

### Application Workloads

- scheduled on user node pool
- isolated via:
  - node selectors
  - taints/tolerations

## Enforcement

- node pool separation
- scheduling constraints
- resource requests/limits

## Design Rationale

Prevents:

- application workloads starving system components
- cluster instability from poorly behaving apps

This aligns with AKS best practices for node pool isolation.

---

# 6. Identity Boundary

## Definition

Separates human, platform, and workload identities.

## Identity Types

### Human Identities

- Microsoft Entra users/groups
- access via RBAC

### Platform Identity

- AKS managed identity
- used for:
  - ACR access
  - Azure resource integration

### Workload Identities

- Kubernetes service accounts mapped via OIDC
- use Microsoft Entra Workload Identity

## Enforcement

- no shared credentials
- no service principals stored in Kubernetes
- RBAC scoped access

## Design Rationale

This boundary enforces:

- least privilege
- traceability
- separation of concerns

---

# 7. Terraform Provisioning Identity vs Runtime Workload Identities

## Definition

Separates:

- provisioning-time identity (Terraform)
- runtime identities (AKS + workloads)

---

## Terraform Provisioning Identity

### Role

Creates Azure resources:

- AKS
- ACR
- networking
- monitoring

### Access

- high privilege (Contributor or scoped equivalent)

### Constraints

- used only during provisioning
- not used by workloads
- not embedded in cluster

---

## Runtime Platform Identity (AKS)

### Role

- AKS-managed identity

### Responsibilities

- pull images from ACR
- integrate with Azure services

---

## Runtime Workload Identities

### Role

Per-workload identity via:

- OIDC issuer
- Microsoft Entra Workload Identity

### Usage

- access Azure resources without secrets
- fine-grained permissions

---

## Boundary Enforcement

| Identity Type      | Scope               | Risk if Misused                     |
|-------------------|--------------------|------------------------------------|
| Terraform Identity | Infra provisioning | Full environment compromise        |
| AKS Identity       | Platform runtime   | Platform-wide access misuse        |
| Workload Identity  | App-level          | Limited to workload scope          |

---

## Design Rationale

This separation ensures:

- provisioning power is not leaked into runtime
- workloads cannot escalate to infrastructure control
- credentials are not reused across boundaries

This is a critical security boundary and a common failure point in weaker AKS designs.

---

# Summary

These trust boundaries define:

- who can do what
- where failures are contained
- how identities are separated
- how the platform scales to multiple teams

If enforced correctly, they provide:

- secure defaults
- operational clarity
- controlled growth of the platform

If ignored, they lead to:

- privilege sprawl
- operational ambiguity
- security risk accumulation

---

# Revisit Criteria

Re-evaluate this model when:

- introducing private AKS or controlled egress
- onboarding multiple product teams
- implementing strict network isolation
- introducing regulated workload requirements
- adding multi-cluster or multi-region architectures