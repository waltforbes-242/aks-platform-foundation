<!-- threat-model.md -->

# Threat Model — AKS Platform Foundation (Hybrid: Trust Boundaries + STRIDE)

## 1) Scope, Intent, and Assumptions

**Scope:** A production-grade AKS platform foundation intended to support multiple application teams with a secure baseline, clear ownership boundaries, and Azure-native integrations. 

**In-scope components (v1):**
- Git repositories for infra + k8s configuration and CI pipelines 
- Terraform provisioning of Azure resources (AKS, ACR, monitoring, network) 
- AKS managed control plane + dedicated system and user node pools 
- ACR as trusted image source (CI → ACR → AKS pull) 
- Observability: Azure Monitor, Log Analytics, managed Prometheus, optional Managed Grafana 
- Identity model: Entra-integrated AKS + OIDC issuer + Workload Identity enabled from day one 

**Explicit out-of-scope for v1 (not implemented unless stated otherwise):**
- Private AKS / controlled egress (documented as a future extension option) 
- Strict network isolation between namespaces (not required in v1; can be a later control) 

---

## 2) Assets to Protect

1. **Cluster integrity and availability**
   - API server access, RBAC, system components, node pools 
2. **Supply chain integrity**
   - CI pipeline outputs, ACR image provenance, tag immutability policy decisions 
3. **Identity and authorization**
   - Platform admin access vs application team access; Workload Identity mappings 
4. **Telemetry integrity and confidentiality**
   - Logs/metrics in Azure Monitor, Log Analytics, Prometheus/Grafana paths 
5. **Provisioning privileges**
   - Terraform identity with high privilege at provisioning time 

---

## 3) Actors and Entry Points

### Actors
- **Platform Engineer / Platform Team**: manages infra and cluster baseline (Terraform, cluster lifecycle). 
- **Application Team(s)**: deploy workloads into scoped namespaces (multi-team readiness is a requirement). 
- **CI System**: builds, scans, pushes images to ACR. 
- **AKS Control Plane**: Azure-managed orchestration services. 
- **Workloads (pods)**: run on user node pools; may need Azure access via Workload Identity. 

### Entry Points
- Git repo (infra/k8s config changes)
- CI pipeline triggers and artifact publishing to ACR
- AKS API server (kubectl/automation)
- Ingress/gateway to workloads (if/when deployed) 
- Telemetry ingestion endpoints (Azure Monitor/LA/Prometheus)

---

## 4) Trust Boundaries (Hybrid Model Anchor)

The design explicitly requires trust boundaries to be documented (control plane vs nodes; platform vs app access; system vs workload namespaces; provisioning identity vs runtime identities; image source boundary). 

### TB1 — Azure-managed Control Plane vs Customer-managed Node Pools
- **Boundary:** Managed control plane components vs node pools you operate and patch via AKS mechanisms.
- **Threat focus:** Unauthorized API access, mis-scoped admin, control-plane log exposure.

### TB2 — Platform Team vs Application Teams
- **Boundary:** Platform-admin operations vs namespace-scoped application operations.
- **Threat focus:** Privilege escalation from app team to cluster-admin; cross-namespace access.

### TB3 — System Node Pool / System Namespaces vs User Node Pool / App Namespaces
- **Boundary:** Scheduling isolation protects critical components.
- **Threat focus:** Noisy-neighbor starvation, hostile workloads targeting system components.

### TB4 — Image Supply Chain Boundary (CI → ACR → AKS)
- **Boundary:** ACR is the trusted registry; images should originate from CI. 
- **Threat focus:** Image poisoning, tag swapping, unscanned images, public image pulls.

### TB5 — Provisioning-time Identity vs Runtime Identities
- **Boundary:** Terraform identity is high-privilege and should not leak into runtime; runtime uses AKS identity and Workload Identity. 
- **Threat focus:** Credential theft, lateral movement, pipeline compromise leading to infra takeover.

### TB6 — Observability Plane vs Workload Plane
- **Boundary:** Monitoring is an external consumer of logs/metrics.
- **Threat focus:** Telemetry exfiltration, injection/poisoning of logs, over-collection of secrets.

---

## 5) STRIDE Mapping (Key Threats + Required Mitigations)

> This section is intentionally control-oriented for internal design review.

### Spoofing
**Threats**
- Impersonation of platform engineer via stolen credentials to access AKS API or Terraform pipeline.
- Spoofed workload identity (incorrect OIDC mapping) to access Azure resources. 

**Mitigations (required)**
- Entra-integrated access for humans + strong RBAC boundaries. 
- Workload Identity enabled from day one; forbid secret-based SP credentials in cluster. 

### Tampering
**Threats**
- Git repo tampering (malicious manifest or Terraform change).
- Container image tampering (push malicious image / replace tag).

**Mitigations (required)**
- CI performs build/scan/push; ACR used as trusted source. 
- Use pull-based GitOps later (Flux recommended in design doc) to reduce drift and make changes traceable. 

### Repudiation
**Threats**
- “Who changed what?” gaps in infra or workload deployment history.

**Mitigations (required)**
- Git-based change control for infra and k8s config; rollback by Git revert is an explicit design goal. 

### Information Disclosure
**Threats**
- Secrets leaking via logs/metrics into Log Analytics / Azure Monitor.
- Public image pull reveals usage or introduces untrusted code paths.

**Mitigations (required)**
- Observability is baseline, but alerts/logging must be “actionable,” not noisy (reduces accidental leakage via verbose logs). 
- Future: adopt secretless workloads via Workload Identity + Key Vault CSI; do not embed credentials in manifests. 

### Denial of Service
**Threats**
- App workloads overwhelm cluster causing system component starvation.
- Unbounded logging spikes ingestion costs and throttles telemetry.

**Mitigations (required)**
- Dedicated system node pool + dedicated user node pool(s) is a core decision. 
- Autoscaling: HPA for workloads; cluster autoscaler for user pools. 
- Control log retention/volume (explicit cost driver noted). 

### Elevation of Privilege
**Threats**
- App team escalates to cluster-admin.
- Workload gains Azure privileges beyond intended scope (over-broad role assignments).

**Mitigations (required)**
- Namespace-scoped roles for app teams; platform-admin group for cluster operations. 
- Workload Identity with fine-grained permissions; avoid shared credentials. 

---

## 6) Abuse Cases (Most Likely / Highest Impact)

1. **Compromised CI pipeline pushes malicious image to ACR**
   - Impact: cluster compromise at scale (many workloads pull the image). 
2. **Mis-scoped RBAC grants app team cluster-wide access**
   - Impact: lateral movement, deletion of workloads, access to secrets/logs. 
3. **Workload identity bound to overly-privileged Azure role**
   - Impact: Azure resource exfiltration or infrastructure modification. 
4. **Namespace isolation not enforced**
   - Impact: cross-team data access, noisy neighbor failures. 

---

## 7) Required Controls Checklist (Design Review Gate)

- [ ] Entra-integrated AKS access model defined (platform vs app team). 
- [ ] OIDC issuer + Workload Identity enabled (no secret-based Azure auth). 
- [ ] Dedicated system and user node pools; scheduling rules documented. 
- [ ] ACR is the trusted source; CI build/scan/push is the only publishing path. 
- [ ] Observability baseline defined (Azure Monitor, Log Analytics, Prometheus). 
- [ ] Cost drivers acknowledged: nodes + Log Analytics ingestion/retention + managed Prometheus/Grafana. 

---

## 8) Teardown / Risk Containment (Cost + Safety)

Teardown is part of the design expectations:
- Use `terraform destroy` (or equivalent) to remove resource groups and dependent monitoring and registry resources, ensuring ACR images and Log Analytics workspaces are deleted to stop ongoing cost. 
``