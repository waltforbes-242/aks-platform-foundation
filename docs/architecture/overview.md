# AKS Platform Foundation — Architecture Overview

## Purpose and Scope

This document describes a **production-grade Azure Kubernetes Service (AKS) platform foundation**, designed as a **shared internal platform** rather than a single-application cluster.

The architecture emphasizes:
- Clear separation of **Azure-managed vs customer-managed responsibilities**
- Explicit **trust boundaries** between platform, workloads, and identities
- A controlled **image supply chain**
- First-class **observability as a platform capability**

This is a **platform baseline** intended to support multiple application teams safely over time, not a disposable lab environment.

---

## High-Level Architecture Narrative

A **platform engineer** interacts with the system primarily through **Git**.  
Infrastructure and cluster configuration are provisioned using **Terraform**, while application images are built via a **CI pipeline** and pushed into **Azure Container Registry (ACR)**.

Within the Azure subscription:
- Networking is provided by a **VNet with dedicated AKS subnets**
- AKS runs with an **Azure-managed control plane**
- Customer-managed **node pools** host workloads
- Observability data flows into **Azure Monitor, Log Analytics, and managed Prometheus**

Operational ownership and failure domains are explicitly designed and documented, rather than implied.

---

## Control Plane

**Component:** AKS Managed Control Plane  
**Ownership:** Azure-managed  
**Trust Level:** Azure trusted boundary

Responsibilities:
- Kubernetes API server
- Scheduler and controller managers
- Cluster state management

Key characteristics:
- Not accessible at the node OS level
- Emits platform logs and metrics into Azure Monitor
- Acts as the authoritative source for scheduling and reconciliation

**Trust Boundary:**  
The control plane is **outside customer trust**. Platform engineers interact through supported APIs only; no direct control plane modification is possible or required.

---

## Node Pools

### System Node Pool

**Purpose:**  
Hosts **system-critical and platform-managed components**.

Characteristics:
- Runs `kube-system` and platform namespaces
- Reserved capacity to protect cluster stability
- Tightly controlled scheduling

Risk addressed:
- Prevents application workloads from starving system components

### User Node Pool(s)

**Purpose:**  
Hosts **application workloads** owned by product teams.

Characteristics:
- Autoscaling enabled
- Application namespaces only
- Capacity scales based on scheduler demand

Risk addressed:
- Contains application failures and resource spikes
- Enables cleaner incident triage and scaling behavior

**Trust Boundary:**  
System and user node pools are a **hard operational boundary** enforced through node selectors, taints, and tolerations.

---

## Image Registry and Supply Chain

**Registry:** Azure Container Registry (ACR)  
**Trust Level:** Trusted image source

Image flow: CI Pipeline → Azure Container Registry → AKS

Key properties:
- AKS pulls images using **managed identity**
- No imagePullSecrets stored in Kubernetes
- No ad-hoc public registry pulls

Risk addressed:
- Reduces supply chain attacks
- Eliminates credential leakage
- Establishes a controlled and auditable image boundary

**Trust Boundary:**  
ACR represents the **image trust boundary**. Only images published through approved CI pipelines are intended to run in the cluster. [1](https://the242consulting-my.sharepoint.com/personal/walt_forbes_the242consulting_onmicrosoft_com/_layouts/15/Doc.aspx?sourcedoc=%7B9314B3E1-D116-4BF1-AEEE-7F9A93C983BA%7D&file=architecture_overview.docx&action=default&mobileredirect=true)[3](https://the242consulting-my.sharepoint.com/personal/walt_forbes_the242consulting_onmicrosoft_com/_layouts/15/Doc.aspx?sourcedoc=%7BBA7088B1-C19B-4AE2-916D-F1A256DABB89%7D&file=trust_boundaries.docx&action=default&mobileredirect=true)

---

## Observability Path

Observability is treated as **platform infrastructure**, not a per-workload concern.

### Telemetry Sources
- AKS control plane logs and metrics
- Node and kubelet signals
- Container logs
- Prometheus metrics from workloads

### Telemetry Flow
AKS → Log Analytics Workspace AKS → Azure Monitor Workspace (metrics) Managed Prometheus → Azure Monitor Optional: Azure Monitor → Managed Grafana

Key outcomes:
- Unified visibility into cluster health and workload behavior
- Actionable alerting instead of raw telemetry noise
- Clear ownership of monitoring responsibilities

**Trust Boundary:**  
Observability systems are **read-only consumers** of platform and workload signals. They do not influence runtime behavior directly.

---

## Explicit Trust Boundaries

This platform defines the following **non-negotiable trust boundaries**:

1. **Azure Control Plane vs Customer Resources**
   - Azure manages control plane internals
   - Platform team manages nodes and workloads

2. **Platform Team vs Application Teams**
   - Platform team owns cluster lifecycle and shared services
   - Application teams are restricted to namespaces

3. **System Namespaces vs Application Namespaces**
   - System namespaces are restricted and platform-managed
   - Application namespaces are isolated and scoped

4. **Image Source Boundary**
   - Only images from ACR are trusted

5. **Workload Boundary**
   - System workloads and application workloads are isolated via node pools

6. **Identity Boundary**
   - Human identities (Entra ID users)
   - Platform identity (AKS managed identity)
   - Workload identities (OIDC + Entra Workload Identity)

7. **Provisioning Identity vs Runtime Identities**
   - Terraform identity exists only at provision time
   - Runtime identities have limited, scoped permissions

Ignoring these boundaries leads to privilege sprawl, unclear ownership, and elevated operational risk.

---

## Why This Architecture Passes Design Review

- Control plane responsibility is clearly understood and respected
- Failure domains are explicitly designed, not accidental
- Security boundaries align with modern AKS guidance
- Observability is operationally useful, not decorative
- Trade-offs (cost, complexity, scope) are intentional and documented

This architecture demonstrates **platform engineering judgment**, not just Kubernetes familiarity.