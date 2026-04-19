# RBAC Model — AKS Platform Foundation (Azure RBAC + AKS Azure RBAC for Kubernetes + Kubernetes RBAC)

## 1) Design Goals

This RBAC model enforces:

- **Least privilege** across humans, pipelines, and workloads  
- **Clear operational ownership** (Platform Team vs Application Teams)  
- **Explicit, enforceable trust boundaries** (not conceptual)  
- **Separation of control plane vs data plane permissions**  
- **Multi-team readiness from day one**  

---

## 2) Core Enforcement Principles

### 2.1 Control Plane vs Data Plane Separation

- **Azure RBAC (Control Plane)**
  - Governs AKS resource lifecycle and infrastructure operations
  - Applies at subscription/resource group level

- **Kubernetes RBAC (Data Plane)**
  - Governs in-cluster access (namespaces, workloads, logs)
  - Enforced via Roles and RoleBindings

- **Azure RBAC for Kubernetes Authorization**
  - Used for authentication (Entra identity → cluster access)
  - Kubernetes RBAC remains the enforcement layer

---

### 2.2 Hard Security Boundary

> **No `cluster-admin` access exists outside the Platform Team Entra group.**

- Platform Team is the only entity with cluster-wide administrative privileges
- All other identities are **explicitly scoped and restricted**

---

## 3) Identity Model

### 3.1 Human Identities (Entra ID)

- **Platform Team**
  - Entra Group: (platform-admin group)
  - Full cluster operations + Azure control plane access

- **Application Teams**
  - Entra Groups per team
  - Namespace-scoped access only

- **Break-Glass Admins**
  - Separate Entra group
  - Access is:
    - Time-bound (PIM)
    - Audited
    - Used only for emergencies

---

### 3.2 Non-Human Identities

- **Terraform Provisioning Identity**
  - Contributor scoped to `rg-apf`
  - Used only during provisioning lifecycle

- **CI Identity**
  - `AcrPush` role on ACR only
  - No cluster or infrastructure modification permissions

- **GitOps Controller (Flux)**
  - Cluster-wide deployment authority
  - Reconciles desired state from Git

- **Workload Identities**
  - Namespace-scoped service accounts
  - Mapped to Entra via Workload Identity (OIDC)

---

## 4) Azure RBAC (Control Plane)

### Scope: Resource Group (`rg-apf`)

| Identity                  | Role          | Scope        | Purpose |
|--------------------------|--------------|-------------|--------|
| Platform Team            | Contributor  | rg-apf      | Full infrastructure lifecycle |
| Terraform Identity       | Contributor  | rg-apf      | Provisioning only |
| CI Identity              | AcrPush      | ACR         | Image push only |
| Break-Glass Identity     | Contributor  | rg-apf      | Emergency access |

---

### Control Plane Permissions

Only Platform Team and Break-Glass identities can:

- Upgrade AKS cluster
- Scale node pools
- Modify networking
- Rotate credentials
- Enable/disable add-ons

---

## 5) Kubernetes RBAC (Data Plane)

### 5.1 Namespace Strategy

- Naming convention:
  - `team-<name>-dev`
  - `team-<name>-prod`

- Namespace ownership:
  - **Platform Team creates namespaces**
  - Application Teams **cannot create namespaces**

---

### 5.2 Permission Matrix (Enforced)

| Persona              | Create Namespaces | Deploy Workloads | View Logs | Scope |
|---------------------|------------------|------------------|----------|------|
| Platform Team       | Yes              | Yes              | Yes      | Cluster-wide |
| Application Teams   | No               | Yes              | Yes      | Namespace בלבד |
| CI/CD Identity      | No               | Yes              | No       | All namespaces |
| GitOps Controller   | No               | Yes              | No       | Cluster-wide |
| Break-Glass Admin   | Yes              | Yes              | Yes      | Cluster-wide |

---

## 6) Workload Deployment Model

### 6.1 Primary Path: GitOps (Flux)

- Source of truth: GitLab (Helm charts / manifests)
- Flux pulls and reconciles desired state into cluster
- GitOps controller has cluster-wide write access

---

### 6.2 Secondary Path: Direct kubectl

- Application teams are allowed to:
  - Deploy workloads via kubectl
  - Modify resources within their namespace

> This introduces flexibility but increases drift risk; GitOps remains authoritative.

---

## 7) Application Team RBAC Scope

### Allowed Actions (Namespace-Scoped)

- Create/update/delete:
  - Deployments
  - Services
  - Ingresses
  - Jobs / CronJobs
  - ConfigMaps

- Read:
  - Pods
  - Logs (`pods/log`)
  - Events

---

### Explicit Deny Boundaries

Application Teams **CANNOT**:

- Create or modify:
  - `ClusterRole`
  - `ClusterRoleBinding`
  - `CustomResourceDefinition`

- Access:
  - Other namespaces
  - `kube-system` or `platform-*`

- Perform node-level operations:
  - `nodes`
  - `nodes/proxy`
  - `nodes/log`

- Modify admission controllers:
  - `MutatingWebhookConfiguration`
  - `ValidatingWebhookConfiguration`

---

## 8) Service Accounts and Workload Identity

### Policy

- Service accounts are **namespace-scoped only**
- Workloads:
  - Cannot list secrets
  - Can access ConfigMaps within namespace

> **No workload has wildcard (`*`) RBAC permissions**

---

### Azure Access

- Workloads use **Entra Workload Identity (OIDC)**
- No secrets embedded in manifests
- Permissions are:
  - Explicit
  - Resource-scoped
  - Least privilege

---

## 9) Observability Access Model

### Azure Monitor / Log Analytics

| Persona            | Access Level |
|------------------|-------------|
| Platform Team     | Cluster-wide logs |
| Application Teams | Namespace-scoped logs |

---

### Kubernetes Logs

- Application Teams:
  - `pods/log` within namespace only

- Platform Team:
  - Cluster-wide visibility

---

## 10) CI/CD and GitOps Access Boundaries

### CI Identity

- Can:
  - Push images to ACR
- Cannot:
  - Deploy to cluster
  - Modify infrastructure

---

### GitOps Controller

- Can:
  - Deploy workloads cluster-wide
- Cannot:
  - Modify Azure infrastructure

---

## 11) Provisioning vs Runtime Boundary

- **Terraform Identity**
  - High privilege
  - Used only during provisioning

- **Runtime Identities**
  - Platform (AKS managed identity)
  - Workloads (OIDC identities)

> A compromised workload cannot escalate to infrastructure control.

---

## 12) Design Review Pass Criteria

This RBAC model passes review because:

- Permissions are **explicitly mapped to actions**
- Control plane vs data plane is clearly separated
- Namespace isolation is enforced, not assumed
- `cluster-admin` is strictly limited
- GitOps and human access boundaries are defined
- Workload identity prevents secret-based access

---

## 13) Revisit Criteria

This model must be revisited if:

- Additional teams onboard
- Multi-cluster architecture is introduced
- Regulatory requirements increase
- Centralized policy enforcement is required
- GitOps becomes exclusive deployment mechanism
- Observability access needs stricter isolation

---

## 14) Cost Awareness and Teardown

### Cost Controls

- Restrict who can:
  - Enable high-volume logging
  - Increase retention policies
  - Deploy high-resource workloads

---

### Teardown Guidance

- Use `terraform destroy` to remove:
  - Resource groups
  - Role assignments
  - AKS cluster and dependencies

- Ensure:
  - No orphaned RBAC assignments remain
  - No lingering identities incur cost

---
```
