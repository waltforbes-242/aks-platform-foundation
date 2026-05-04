# AKS Cost Model — Platform Foundation

## Overview

This document outlines the cost structure of the AKS platform foundation.

---

## Primary Cost Drivers

### 1. Node Pools
- VM size and count
- System pool (baseline cost)
- User pool (scaling cost)

### 2. Storage
- OS disks per node

### 3. Networking
- Load balancer (future)
- outbound traffic

### 4. Observability
- Log Analytics ingestion
- Prometheus metrics ingestion

### 5. Container Registry
- ACR storage and operations

---

## Baseline Configuration

| Component | Configuration |
|----------|--------------|
| System Pool | 2–4 nodes (D2s_v3) |
| User Pool | 2–3 nodes (B2s) |
| Log Retention | 30 days |
| ACR | Standard |

---

## Cost Optimization Strategies

- Right-size VM SKUs
- Use autoscaler effectively
- Limit log verbosity
- Reduce retention if needed
- Avoid unnecessary add-ons

---

## Future Cost Considerations

- Azure Managed Grafana
- NAT Gateway / Firewall
- Private endpoints
- additional node pools

---

## Teardown

```bash
terraform destroy
```

Ensure:
- no orphaned resources remain
- state backend is preserved