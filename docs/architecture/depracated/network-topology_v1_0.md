# Network Topology — AKS Platform Foundation

## 1) Purpose

This document defines the **operational network topology** for the AKS platform, including:

- Subnet layout and address mapping
- North-south and east-west traffic flows
- Trust boundaries across control plane, data plane, and external dependencies
- Outbound connectivity posture

This document complements **ADR-001 (Networking Model — Azure CNI Powered by Cilium)** and focuses on **how the network is structured and behaves**, not why decisions were made.

---

## 2) High-Level Topology

```mermaid
flowchart TB
    Internet((Internet))
    AzureCP[Azure Control Plane]
    AKSCP[AKS Control Plane (Public API)]
    
    subgraph VNet[apf-vnet (10.77.0.0/16)]
        direction TB

        subgraph Subnet1[apf-subnet-systempool1 (10.77.0.0/22)]
            Node1[System Nodes]
        end

        subgraph Subnet2[apf-subnet-userpool1 (10.77.4.0/22)]
            Node2[User Nodes]
        end

        subgraph Subnet3[apf-subnet-future1 (10.77.8.0/22)]
            Future1[Reserved]
        end

        subgraph Subnet4[apf-subnet-future2 (10.77.12.0/22)]
            Future2[Reserved]
        end

        subgraph Subnet5[apf-subnet-future3 (10.77.16.0/22)]
            Future3[Reserved]
        end
    end

    Ingress[Ingress Controller (apf-ingress)]
    Pods[Workloads (Pods)]
    AzureSvc[Azure Services (ACR, Key Vault, etc.)]

    Internet --> Ingress
    Ingress --> Node2
    Node2 --> Pods
    Pods --> AzureSvc
    Pods --> Internet

    AKSCP --> Node1
    AzureCP --> AKSCP
```
	
## 3) Address Space and Subnet Mapping

### VNet

- Name: `apf-vnet`
- CIDR: `10.77.0.0/16`

---

### Subnets (Subnet-per-Node-Pool Strategy)

| Subnet Name             | CIDR          | Purpose           | Status   |
|------------------------|---------------|------------------|----------|
| apf-subnet-systempool1 | 10.77.0.0/22  | System node pool | Active   |
| apf-subnet-userpool1   | 10.77.4.0/22  | User node pool   | Active   |
| apf-subnet-future1     | 10.77.8.0/22  | Future pool      | Reserved |
| apf-subnet-future2     | 10.77.12.0/22 | Future pool      | Reserved |
| apf-subnet-future3     | 10.77.16.0/22 | Future pool      | Reserved |

---

### Key Characteristics

- Pods receive IPs directly from subnet CIDR (Azure CNI)
- Each node pool is isolated at subnet level
- Reserved subnets eliminate need for future readdressing

---

## 4) Trust Boundaries

### Boundary 1 — Azure Control Plane

- Azure Resource Manager
- Enforces infrastructure-level RBAC
- Manages AKS lifecycle

---

### Boundary 2 — AKS Control Plane

- Public API endpoint
- Entra ID authentication
- Kubernetes API boundary

---

### Boundary 3 — Node Subnets (Data Plane)

- Subnet-per-node-pool isolation
- NSG: baseline deny with explicit allows
- No direct inbound access

---

### Boundary 4 — Workloads (Pods)

- Namespace isolation via RBAC
- Network isolation via Cilium NetworkPolicies

---

### Boundary 5 — External Dependencies

- Azure services (ACR, Key Vault)
- Public internet
- Accessed via outbound SNAT

---

## 5) North-South Traffic Flow (Ingress)

### Flow: Client → Workload

1. Client sends request from Internet  
2. Traffic reaches public LoadBalancer  
3. Routed to `apf-ingress` controller  
4. Ingress routes to Service → Pod  

---

### Characteristics

- No direct node exposure
- All ingress is mediated through Kubernetes primitives

---

## 6) East-West Traffic Flow (Intra-Cluster)

### Flow: Pod → Pod

- Uses native VNet IP routing (no overlay)
- No NAT within cluster

---

### Enforcement

- Cilium NetworkPolicies
- Deny-by-default baseline (recommended)

---

### Namespace Isolation

- `team-<name>-dev`
- `team-<name>-prod`

Isolation enforced via:

- Kubernetes RBAC
- NetworkPolicies

---

## 7) Outbound Traffic Flow (Egress)

### Flow: Pod → External

1. Pod initiates connection  
2. Traffic is routed via node  
3. Azure performs SNAT  
4. Traffic exits to destination  

---

### Current Model

- Default SNAT
- No NAT Gateway
- No Firewall
- No UDR

---

### Dependencies

- ACR
- Azure Key Vault
- Microsoft endpoints
- External APIs

---

## 8) Deferred Network Capabilities

### Controlled Egress

- Not implemented
- No deterministic outbound IP

---

### Private AKS

- Not implemented
- API server remains public

---

### Advanced Routing

- No UDR
- No forced tunneling

---

### Future Triggers

- Regulatory requirements
- Deterministic egress needs
- Multi-cluster topology
- FQDN filtering requirements

---

## 9) Security Posture (Network Layer)

- No inbound access directly to nodes
- Ingress only via ingress controller
- NSG enforces:
  - baseline deny
  - explicit allow rules
- NetworkPolicies enforce least-privilege communication

---

## 10) Operational Considerations

### Debugging

Native VNet IPs simplify:

- Packet tracing
- NSG debugging
- Flow analysis

---

### Scaling

Subnet-per-node-pool enables:

- Independent scaling
- Isolation of workloads

---

### Failure Domains

- System and user workloads isolated at subnet level
- Future node pools can be added without redesign

---

## 11) Relationship to ADR-001

This topology implements:

- Azure CNI (VNet-integrated pods)
- Subnet-per-node-pool strategy
- Pre-allocated CIDR ranges
- Default SNAT outbound model

---

### Refer to ADR-001 for:

- Design rationale
- Capacity planning
- Redesign triggers