<!-- rbac-model.md -->

# RBAC Model — AKS Platform Foundation (Azure RBAC + AKS Azure RBAC for Kubernetes + K8s RBAC)

## 1) Design Goals

This RBAC model exists to enforce:
- **Least privilege** across humans, pipelines, and workloads
- **Clear operational ownership** (Platform Team vs Application Teams)
- **Multi-team readiness from day one** (namespace-per-team, scoped access)
- **Separation of provisioning-time power from runtime permissions** 

---

## 2) Identity Types (Who Gets Access)

The design doc explicitly calls out:
- Entra-integrated AKS access model
- OIDC issuer + Workload Identity enabled from day one
- Platform-admin group for cluster operations; namespace roles for application teams
- Separate infra pipeline permissions from runtime identities 

### 2.1 Human Identities (Entra ID users/groups)
- **Platform Team (cluster operators)**: elevated access for lifecycle and baseline operations. 
- **Application Teams**: restricted to their namespaces (no platform-admin privileges). 

### 2.2 Non-human Identities
- **Terraform Provisioning Identity**: high privilege, used only during provisioning. 
- **CI Pipeline Identity**: pushes images to ACR (and possibly updates GitOps manifests in Git, depending on flow). 
- **Runtime Platform Identity (AKS managed identity)**: pulls from ACR and integrates with Azure services. 
- **Workload Identity**: per-workload Azure access via OIDC/Entra Workload Identity. 

---

## 3) RBAC Layers (All Included)

### Layer A — Azure RBAC (Subscription / RG / Resource)
Used to control:
- Who can create/modify AKS, ACR, networking, monitoring resources
- Who can administer AKS at the Azure resource level

**Primary assignments (conceptual):**
- Platform Team: Contributor (scoped to platform RGs) + specific AKS admin roles as needed
- Terraform Provisioning Identity: Contributor (scoped; time-bounded usage)
- CI Identity: ACR push permissions (scoped to ACR) 

### Layer B — Azure RBAC for Kubernetes Authorization (AKS integration)
Used to map Entra users/groups into Kubernetes permissions (cluster-level and namespace-level). 

### Layer C — Kubernetes RBAC (Roles / RoleBindings)
Used for fine-grained, namespace-scoped permissions for application teams and service accounts. 

---

## 4) Authorization Model by Persona

## 4.1 Platform Team (Cluster Operators)

**Responsibilities (implied by design scope):**
- AKS cluster lifecycle (provisioning, upgrades, scaling policy)
- Node pools (system vs user) and platform add-ons
- Observability platform integration
- Security baseline enforcement (RBAC model, identity model) 

**Access characteristics**
- Cluster-level administration for operations
- Azure RBAC to AKS, ACR, networking, monitoring resources 

**Kubernetes scope**
- ClusterRole/ClusterRoleBinding for platform operator actions
- Full access to `kube-system` and platform namespaces

## 4.2 Application Teams (Namespace Operators)

**Responsibilities**
- Deploy and operate workloads in their namespace(s)
- View logs/metrics relevant to their workloads (bounded access) 

**Access characteristics**
- No cluster-admin
- No write access to `kube-system` or platform namespaces
- Namespace-scoped Roles/RoleBindings only 

---

## 5) Namespace Strategy (Multi-Team Ready Day One)

The design expects multi-team onboarding with minimal rework, and calls out namespace-scoped roles for app teams. 

**Namespace conventions (conceptual):**
- `kube-system` (system)
- `platform-*` (platform-managed add-ons)
- `team-<name>` (application team namespaces)

**Default rule:** Application Teams operate only inside `team-<name>`.

---

## 6) Illustrative RBAC Examples (Policy + Example)

> Examples are intentionally compact to demonstrate intent; tune verbs/resources during implementation.

### 6.1 Application Team Role (namespace-scoped)

```yaml
# Example: Role in namespace team-foo allowing typical workload ops
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: app-team-operator
  namespace: team-foo
rules:
- apiGroups: ["", "apps", "batch", "networking.k8s.io"]
  resources: ["pods", "pods/log", "deployments", "replicasets", "services", "ingresses", "jobs", "cronjobs", "configmaps"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
```

- Design intent: Application Teams can deploy and debug **their** workloads without any cluster-wide privilege.

## 6.2 Deny-by-Design Controls (What Application Teams should NOT have)

**Policy:** Application Teams must not have permissions that allow cluster takeover, cross-team access, or modification of platform controls.

**Disallowed capabilities (conceptual):**

- No ability to create or modify cluster-scoped authorization:
  - `ClusterRole`
  - `ClusterRoleBinding`

- No ability to modify admission control surfaces:
  - `ValidatingWebhookConfiguration`
  - `MutatingWebhookConfiguration`

- No ability to define cluster-wide API schema:
  - `CustomResourceDefinition`

- No node-level control:
  - `nodes`
  - `nodes/proxy`
  - `nodes/log`
  - `pods/exec` across namespaces

- No access to `kube-system` or `platform-*` namespaces

**Operational consequence:**  
This preserves the Platform Team boundary and reduces blast radius from compromised or misconfigured workloads.

## 7) Service Accounts and Workload Identity (RBAC + Azure)

The design enables OIDC + Workload Identity from day one to avoid secret-based Azure access patterns.

### 7.1 Policy

- Workloads use Kubernetes service accounts with minimal Kubernetes RBAC.
- Azure access is granted via **Entra Workload Identity** mapping (OIDC), not via secrets embedded in manifests.

### 7.2 Illustrative Mapping Example (Conceptual)

- `serviceAccount: team-foo/app-a` ↔ Entra workload identity `app-a-id`
- `app-a-id` receives narrowly scoped Azure permissions (least privilege) for only the required resource(s).

## 8) CI/CD and GitOps Controller Access

The design doc recommends:

- CI: build → scan → push image to ACR
- CD: GitOps pull-based deployment (Flux) and rollback via Git revert

### 8.1 CI Identity (Pipeline)

**Policy:**

- CI identity should be scoped to:
  - push images to ACR (and optionally update Git if the workflow requires)
- CI identity should not have broad Azure Contributor access over the platform.

### 8.2 GitOps Controller Identity (Cluster-side, if implemented)

**Policy:**

- GitOps controller should have:
  - Read access to the repository (implementation-dependent)
  - Write access limited to the namespaces it reconciles
- Avoid cluster-admin unless there is explicit justification and compensating controls.

## 9) Provisioning Identity vs Runtime Identity Boundary

This separation is explicitly required:

- **Terraform provisioning identity:** high privilege, used only during provisioning.
- **Runtime platform identity (AKS):** platform operations and integration scope (for example, ACR pulls).
- **Runtime workload identities:** per-workload scoped permissions via Workload Identity.

**Operational consequence:**

- A compromised workload should not be able to “become Terraform” and take over infrastructure.
- Infrastructure changes remain governed via IaC workflows.

## 10) Design Review Pass Criteria (RBAC)

- Platform Team has cluster operations access; Application Teams do not.
- Application access is namespace-scoped; multi-team ready from day one.
- OIDC issuer + Workload Identity enabled; no secret-based Azure authentication in the cluster.
- Terraform provisioning identity is separated, scoped, and used only for the provisioning lifecycle.
- CI/CD identities are scoped to their responsibilities (ACR push, Git changes, reconcile).

## 11) Cost Awareness and Teardown (RBAC-Relevant)

The design doc calls out operational cost awareness and teardown as required artifacts.

**RBAC-related cost controls:**

- Limit who can enable high-cost telemetry configurations (for example, broad logging or retention changes).
- Restrict creation of uncontrolled resources that increase spend (for example, unmanaged add-ons).

**Teardown guidance:**

- Use `terraform destroy` (or equivalent) and ensure access assignments and platform resources are removed along with resource groups to avoid orphaned spend.
``