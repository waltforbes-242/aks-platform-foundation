# ADR-001: Networking Model — Azure CNI Powered by Cilium

## Status
Proposed

## Context
This AKS cluster hosts production workloads requiring predictable pod networking, Azure-native integration, and enforceable network security boundaries.

The cluster is:
- Region: eastus
- Scope: single production cluster in a dedicated VNet
- API Server: public endpoint

Key design concerns:
- IP address management and exhaustion risk
- Subnet growth strategy and future node pool expansion
- Outbound connectivity model and future control requirements
- Clear, enforceable network security boundaries

This ADR expands beyond networking model selection to include **IP addressing strategy, subnet allocation, and outbound design**, ensuring the platform can scale without requiring disruptive re-architecture.

---

## Decision
We will use **Azure CNI with Cilium (VNet-integrated pod IP model)**.

- Pods receive IP addresses directly from the Azure VNet
- Each node pool is assigned a **dedicated subnet (subnet-per-node-pool strategy)**
- Subnet space is **pre-allocated for future node pools**
- Outbound connectivity uses **default SNAT**
- **Controlled egress is explicitly deferred** to a later phase

This design prioritizes:
- Network transparency and debuggability
- Strong security boundaries via NetworkPolicies
- Predictable scaling through upfront IP planning

---

## Network Topology and Addressing

### VNet
- CIDR: `10.77.0.0/16`

This provides sufficient address space for:
- Current cluster
- Future node pools
- Potential future platform expansion

---

### AKS Subnet Allocation

| Subnet CIDR       | Purpose                  | Status      |
|------------------|--------------------------|-------------|
| 10.77.0.0/22     | systempool1              | Active      |
| 10.77.4.0/22     | userpool1                | Active      |
| 10.77.8.0/22     | future node pool         | Reserved    |
| 10.77.12.0/22    | future node pool         | Reserved    |
| 10.77.16.0/22    | future node pool         | Reserved    |

### Design Rationale
- Subnet-per-node-pool isolates failure domains and simplifies scaling decisions
- Pre-reserving subnets avoids:
  - VNet readdressing
  - cluster rebuilds due to IP exhaustion
- Enables independent scaling characteristics per workload class

---

## Node Pool and Scaling Model

### Current Node Pools

**systempool1**
- Purpose: system
- VM SKU: Standard_D2s_v3
- Autoscaler: 2–4 nodes
- Steady state: 2 nodes

**userpool1**
- Purpose: user workloads
- VM SKU: Standard_B2s
- Autoscaler: 2–3 nodes
- Steady state: 2 nodes

### Scaling Characteristics
- Cluster Autoscaler enabled
- Workload profile: **bursty scaling**
- Subnets are sized to absorb:
  - autoscaler expansion
  - transient pod churn
  - future workload onboarding

---

## IP Capacity and Exhaustion Planning

### Subnet Size
Each `/22` subnet provides:
- 1024 total IP addresses
- ~1019 usable IPs (Azure reserves 5)

### Current Allocation Model
- Pods receive VNet IPs directly
- Default max pods per node applies
- IP consumption scales with:
  - node count
  - pod density per node

---

### Headroom Strategy
- Two active subnets support current node pools
- Three additional `/22` subnets reserved for expansion
- Total reserved capacity supports:
  - multiple additional node pools
  - approximately **600–700 additional pods**

---

### Design Statement
> The subnet layout is intentionally oversized relative to initial node count to avoid early re-addressing.

---

### Explicit Capacity Envelope
- Each subnet: ~1019 usable IPs
- Total allocated AKS address space (5 subnets): ~5095 usable IPs

This design:
- Supports current workloads comfortably
- Supports multiple future node pools
- Delays need for overlay networking or VNet redesign

---

### Scale Risk Threshold (Redesign Trigger)
A redesign is required when:
- Subnet utilization approaches exhaustion (operational threshold ~70–80%)
- Additional node pools cannot be allocated cleanly
- Pod density requirements exceed subnet capacity
- Multi-cluster or shared VNet patterns emerge

---

## Outbound Connectivity Model

### Current State
- Outbound: **default Azure SNAT**
- No NAT Gateway or Firewall
- No user-defined routing

### Dependencies
- Pulling images from ACR
- Accessing Azure Key Vault and Azure services
- Reaching Microsoft package endpoints
- General application outbound internet access

---

### Deferred Design
> Controlled egress is deferred for this phase.

### Future Triggers for Controlled Egress
- Regulatory requirements
- Deterministic outbound IP requirement
- FQDN/domain allow-listing requirements
- Multiple clusters sharing outbound paths

---

## Security Model (Network Layer)

- No direct inbound access to nodes
- Ingress via Kubernetes-managed load balancing only
- NSG posture: **baseline deny with explicit allows**
- NetworkPolicies enforced via Cilium

This establishes:
- Clear trust boundaries
- Least-privilege traffic flow
- Separation of system and application workloads

(Aligned with AKS security model principles :contentReference[oaicite:0]{index=0})

---

## Alternatives Considered

### Kubenet
- Pros:
  - Lower VNet IP consumption
- Cons:
  - NAT-based networking reduces visibility
  - Poor alignment with Azure-native integrations
- Rejected due to operational opacity and weaker security posture

---

### Azure CNI Overlay
- Pros:
  - Reduces VNet IP pressure
- Cons:
  - Additional abstraction layer
  - Less mature dataplane integration compared to Cilium VNet mode
- Deferred until IP pressure justifies complexity

---

### Controlled Egress (NAT Gateway / Firewall)
- Pros:
  - Deterministic outbound IP
  - Centralized control and inspection
- Cons:
  - Increased cost and operational complexity
- Deferred to avoid premature optimization in single-cluster phase

---

## Consequences

### Operational
- Requires deliberate IP planning upfront
- Simplifies debugging due to native VNet visibility
- Subnet-per-pool improves isolation but increases planning overhead

### Security
- Strong network policy enforcement via Cilium
- Clear ingress/egress boundaries
- Future-ready for stricter egress control

### Cost
- Larger CIDR allocation than minimal designs
- Avoids future cost of re-platforming or migration

### Complexity
- Higher conceptual complexity than Kubenet
- Offset by improved observability and control

---

### Design Review Justification
This design passes review because:
- CIDR allocation is explicit and scalable
- Subnet growth strategy is defined upfront
- IP exhaustion risk is quantified and mitigated
- Outbound model is intentional, not accidental
- Redesign triggers are clearly defined

---

## Revisit Criteria

This ADR must be revisited if any of the following occur:

- Subnet utilization exceeds safe thresholds
- Additional node pools are required beyond reserved capacity
- A second cluster is introduced into the VNet
- Private AKS or private endpoints are adopted
- Controlled egress becomes mandatory
- Pod density requirements change
- Regulatory or security requirements increase

---