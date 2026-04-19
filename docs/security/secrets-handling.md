<!-- secrets-handling.md -->

# Secrets Handling — AKS Platform Foundation (v1 + Explicit Future State)

## 1) Objectives

This document defines how secrets are handled to meet these goals:
- **No plaintext secrets in Kubernetes manifests or Git**
- **Avoid long-lived credentials** and eliminate secret sprawl
- Prefer **Azure-native identity and secret delivery** patterns
- Enable multi-team operation without leaking secrets across namespaces 

The design doc explicitly enables **OIDC issuer + Workload Identity from day one** to support secretless pod-to-Azure access and avoid redesign later. 

---

## 2) v1 Baseline (What Exists Day One)

### 2.1 Non-negotiable v1 rules
- **No plaintext secrets committed to Git** (including base64 “Kubernetes Secrets” checked into repos).
- **No service principal credentials stored in Kubernetes** (no secret-based Azure access).
- **AKS pulls images from ACR using managed identity** (no registry pull secrets). 

### 2.2 Identity-first access (preferred)
- Human access is Entra-integrated and governed through RBAC boundaries. 
- Workloads authenticate to Azure through **Workload Identity (OIDC + Entra)** rather than embedded credentials. 

### 2.3 What “secrets” remain in v1?
In v1, the goal is to keep secrets to a minimum. Where configuration is needed:
- Prefer **ConfigMaps** for non-sensitive config
- Prefer **runtime injection** via secure store (future state) for sensitive values
- If a Kubernetes Secret must exist temporarily (e.g., third-party integration during early phases), it must:
  - Be created via secure automation (not committed)
  - Be namespace-scoped
  - Be rotated and removed as soon as Workload Identity + Key Vault CSI path is implemented  
  *(Note: the design doc emphasizes that secret-based patterns are a rejected alternative.)* 

---

## 3) Future State (Explicitly Documented Path): Key Vault + CSI + Secretless Workloads

The design doc calls out **future extension: Key Vault + CSI driver** and modern secret handling expectations. 

### 3.1 Target Pattern
- Secrets live in **Azure Key Vault**
- Pods authenticate to Azure via **Workload Identity**
- Secrets are delivered to pods via **Key Vault CSI driver** (mounted at runtime)
- No secrets stored in etcd as Kubernetes Secret objects (or minimized), depending on configuration 

### 3.2 Why this is the target (Design Rationale)
- Removes long-lived credentials from the cluster
- Reduces blast radius for compromise (per-workload identity and scoped Key Vault access)
- Aligns with “secure defaults” and least privilege enforcement 

---

## 4) Trust Boundaries and Multi-Team Considerations

The platform is intentionally multi-team ready. 

### 4.1 Namespace boundary as the primary isolation mechanism
- Each application team operates in its own namespace
- Secret access must be scoped by:
  - Namespace boundaries (Kubernetes RBAC)
  - Workload Identity (per workload/service account)
  - Key Vault access policies/role assignments (per vault/secret) 

### 4.2 Platform vs Application ownership
- Platform Team owns:
  - Workload Identity enablement and baseline cluster configuration
  - Secret delivery mechanism (CSI driver setup, policies)
- Application Teams own:
  - Which secrets their workloads require (declared as references, not values)
  - Avoid logging or exposing secret values at runtime 

---

## 5) Secret Flows (Policy + Illustrative Examples)

## 5.1 Image pull (No secrets)
**Flow:** CI → ACR → AKS pulls using managed identity  
**No imagePullSecret** should be required in the cluster. 

## 5.2 Workload secret retrieval (Target flow: secretless)
**Flow:** Pod → Workload Identity (OIDC) → Azure AD token → Key Vault → CSI mount into pod 

### Illustrative example (conceptual)
- `serviceAccount: team-foo/app-a`
- Bound to Entra workload identity `app-a-id`
- `app-a-id` granted **Key Vault Secrets User** to *only* the required secret scope

---

## 6) Logging, Telemetry, and Secret Exposure Controls

The platform’s observability baseline is Azure Monitor + Log Analytics + Prometheus. 

**Policy:**
- Application logs must never print secret values.
- Alerting must be actionable; avoid verbose debug logging in production because:
  - It increases Log Analytics ingestion cost (explicit cost driver)
  - It increases risk of leaking sensitive material into telemetry 

---

## 7) Controls and Guardrails Checklist (Design Review Gate)

### v1 required
- [ ] OIDC issuer enabled and Workload Identity enabled on cluster. 
- [ ] No plaintext secrets in Git; no service principals stored in Kubernetes. 
- [ ] ACR integration uses managed identity; no registry pull secrets. 
- [ ] RBAC enforces namespace boundaries for application teams. 
- [ ] Observability configured with attention to retention and ingestion costs. 

### future state (explicitly documented)
- [ ] Key Vault + CSI driver used for secret delivery (no secrets committed). 
- [ ] Per-workload identity and least-privilege Key Vault permissions. 

---

## 8) Cost Awareness and Teardown

Cost drivers relevant to secrets handling and telemetry include:
- Log Analytics ingestion and retention
- Managed Prometheus / Grafana usage (metrics volume) 

**Teardown guidance:**
- Use `terraform destroy` (or equivalent) and ensure associated monitoring resources (workspaces, dashboards/alerts if out-of-RG) are removed to avoid ongoing costs. 