# AKS Architecture — Platform Foundation

## Overview

This document describes the architecture of the production-grade Azure Kubernetes Service (AKS) cluster deployed as part of the AKS Platform Foundation.

The cluster is designed as a **shared platform layer** supporting future multi-team workloads, with clear separation of control plane, system components, and application workloads.

---

## Architecture Summary

- **Region**: eastus
- **Cluster Type**: Public AKS (managed control plane)
- **Network Model**: Azure CNI powered by Cilium
- **Node Pools**:
  - System node pool (platform components)
  - User node pool (application workloads)
- **Identity**:
  - System-assigned managed identity
  - OIDC issuer enabled
  - Workload Identity enabled
- **Registry**: Azure Container Registry (ACR)
- **Observability**:
  - Log Analytics Workspace (logs)
  - Azure Monitor Workspace (Prometheus metrics)

---

## High-Level Architecture

```mermaid
flowchart TB
    subgraph Azure
        subgraph Network
            VNet
            SystemSubnet
            UserSubnet
        end

        subgraph AKS
            ControlPlane
            SystemPool
            UserPool
        end

        ACR
        LogAnalytics
        MonitorWorkspace
    end

    ControlPlane --> SystemPool
    ControlPlane --> UserPool

    SystemPool --> SystemSubnet
    UserPool --> UserSubnet

    UserPool --> ACR
    ControlPlane --> LogAnalytics
    ControlPlane --> MonitorWorkspace
	
**Control Plane Design**
- Managed by Azure
- Public API endpoint
- Secured via Azure AD (Entra ID) and RBAC

**Rationale**
- Simpler operational model for Phase 1
- Avoids early complexity of private endpoints and DNS
- Enables faster troubleshooting and iteration
```
---

**Networking Design**
- Azure CNI (VNet-integrated pod networking)
- Dedicated subnets per node pool:
  - systempool subnet
  - userpool subnet

**Rationale**
- Enables IP-level observability
- Aligns with enterprise networking standards
- Prepares for future network policy enforcement

---

**Node Pool Design**

**System Node Pool**
- Purpose: platform and Kubernetes system workloads
- Isolated from application workloads
- Autoscaling enabled

**User Node Pool**
- Purpose: application workloads and ingress
- Autoscaling enabled

**Rationale**
- Reduces blast radius
- Prevents resource starvation of critical components

---

**Identity Model**
- System-assigned managed identity for cluster
- OIDC issuer enabled
- Workload Identity enabled

**Rationale**
- Eliminates need for secrets in Kubernetes
- Enables fine-grained Azure access per workload

---

**Image Supply Chain**
- ACR is the only trusted registry
- AKS pulls images via managed identity (AcrPull role)

---

**Observability**
- Logs → Log Analytics Workspace
- Metrics → Azure Monitor Workspace (Prometheus)

**Rationale**
- Separation of logs and metrics
- Azure-native, low-ops solution
- Enables future Grafana integration

---

**Future Enhancements**
- Private AKS cluster
- Controlled egress (NAT Gateway / Firewall)
- GitOps (Flux)
- Network policies (Cilium)
- Azure Managed Grafana