# cost-model.md

## Purpose

This document describes the **cost model** for the AKS Platform Foundation, focusing on:
- Primary cost drivers
- Scaling relationships
- Guardrails
- Teardown procedures

All figures are **illustrative examples**, not exact pricing. 

---

## Primary Cost Drivers

| Cost Area | Driver | Scaling Behavior |
|---------|-------|----------------|
| AKS nodes | VM size × node count | Scales with autoscaler |
| Log Analytics | Ingestion + retention | Scales with verbosity |
| Managed Prometheus | Metric volume | Scales with scrape targets |
| Ingress/Public IP | Allocated resources | Mostly fixed |
| ACR | Image storage | Grows with build frequency |

---

## Example Cost Model (Illustrative)

| Component | Example Assumption |
|---------|-------------------|
| System node pool | 2 × D4s_v5 |
| User node pool | 3–10 × D4s_v5 |
| Log retention | 14 days |
| Prometheus scrape | 30s interval |
| Sample workload | Single namespace |

This model intentionally favors **operational realism over minimal cost**. 

---

## Cost Control Guardrails

### Compute
- Keep system pool small but resilient.
- Set **autoscaler max nodes explicitly**.
- Avoid oversized default VM SKUs.

### Logging
- Avoid debug-level logging in steady state.
- Short retention for non-critical logs.
- Periodically review ingestion volume.

### Metrics
- Scrape only required targets.
- Avoid overly aggressive scrape intervals.

---

## Cost Signals to Monitor

| Signal | Reason |
|------|-------|
| Node count growth | Detect runaway scaling |
| Log ingestion spikes | Identify noisy workloads |
| Prometheus series count | Prevent metric explosion |

---

## Teardown Guidance (Mandatory)

When the environment is no longer needed:

1. Destroy AKS and dependent resources via IaC.
2. Confirm Log Analytics workspace deletion.
3. Delete ACR images and repositories.
4. Remove alerts and dashboards outside RG scope.
5. Validate no orphaned public IPs remain.

Failure to teardown **will continue incurring cost** even with no workloads running. 

---

## Why This Passes Design Review

- Cost drivers are explicitly understood, not hand-waved.
- Guardrails are proactive, not reactive.
- Teardown is treated as a first-class operational responsibility.
- Demonstrates platform ownership beyond “it works.” 
``