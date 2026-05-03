# ADR-004: Observability Stack — Azure Monitor + Managed Prometheus

## Status
Accepted

## Context
Production AKS requires visibility into health, performance, and failure modes without requiring the platform team to operate a separate self-managed observability stack.

Current AKS monitoring guidance treats observability as multiple distinct signal layers:
- platform metrics
- Prometheus metrics
- container logs and events
- control plane and resource logs

This platform is:
- single-region
- Azure-first
- intended to use Azure Monitor for logs and Azure Monitor managed service for Prometheus for metrics
- designed to enable AKS monitoring cleanly in a later phase

Key design concerns include:
- separating logs from metrics operationally
- reducing the maintenance burden of self-hosted observability tooling
- keeping the baseline cost-aware and production-credible
- preserving a clean path to AKS integration later

---

## Decision
We will use an Azure-native observability baseline composed of:

- **Log Analytics Workspace** for container logs, events, and Container Insights support
- **Azure Monitor Workspace** for managed Prometheus metrics
- A later optional integration with **Azure Managed Grafana** for visualization
- A later AKS configuration that emits:
  - logs to Log Analytics
  - Prometheus metrics to the Azure Monitor workspace
  - control plane/resource logs through Azure Monitor diagnostics

For Phase 1, we will provision:
- one Log Analytics workspace
- one Azure Monitor workspace

Baseline settings:
- Log Analytics SKU: `PerGB2018`
- Log Analytics retention: `30 days`
- Azure Monitor workspace: single workspace for the production foundation

---

## Why

### Operational
- avoids operating self-hosted Prometheus and Grafana from day one
- matches Azure-native AKS monitoring patterns
- provides a stable platform baseline before any cluster exists

### Signal Separation
- logs and metrics have different retention, query, and alerting behaviors
- treating them as distinct signals improves clarity and operational reasoning
- avoids the anti-pattern of using logs as the only monitoring signal

### Future AKS Compatibility
- Log Analytics supports Container Insights and cluster logs
- Azure Monitor workspace supports managed Prometheus for AKS
- the baseline can later attach to Azure Managed Grafana if richer dashboards are needed

### Cost Awareness
- PerGB2018 is an appropriate initial Log Analytics pricing model for a modest platform baseline
- 30-day retention is enough for early operational debugging without overcommitting ingestion/retention cost
- Managed services reduce operational cost even when direct service cost exists

---

## Alternatives Considered

### Self-Hosted Prometheus + Grafana
- **Pros:** Full control, broad ecosystem familiarity
- **Cons:** Higher operational burden, extra upgrade and reliability ownership
- **Rejected** because it adds platform toil before the project needs that flexibility.

### Logs-Only Monitoring
- **Pros:** Simpler initial setup
- **Cons:** Weak metric-driven alerting, weak SLO support, poor separation of concerns
- **Rejected** because production AKS requires more than log collection.

### Single Log Analytics Workspace Only
- **Pros:** Fewer resources, simpler mental model
- **Cons:** Does not align with managed Prometheus architecture for AKS
- **Rejected** because Prometheus metrics and container logs should remain distinct capabilities.

### Azure Managed Grafana in Phase 1
- **Pros:** Better dashboarding and Prometheus visualization
- **Cons:** Additional cost and another service to manage before it is needed
- **Deferred** until AKS exists and real dashboards are required.

---

## Consequences

### Security
- Uses Azure-native access control boundaries
- Avoids exposing self-managed observability endpoints
- Keeps identity and access management aligned with the broader Azure platform model

### Operational
- Lower maintenance overhead than self-hosted observability
- Clear separation between metrics and logs
- Clean later path to AKS monitoring enablement

### Cost
- Log Analytics ingestion and retention become primary cost drivers
- Azure Monitor workspace introduces managed Prometheus cost later when connected to AKS
- 30-day retention limits unnecessary early spend

### Complexity
- Slightly more resource complexity than a logs-only baseline
- Lower operational complexity than self-hosted Prometheus/Grafana

---

## Design Review Justification
This decision passes review because:
- it aligns with current AKS monitoring architecture
- it separates logs and metrics intentionally
- it provides day-2 operational readiness before cluster deployment
- it avoids unnecessary self-hosted observability burden
- it remains cost-aware and appropriately scoped for a single-region platform baseline

---

## Revisit Criteria
This ADR must be revisited if any of the following occur:

- Multi-cluster observability strategy is introduced
- Azure Managed Grafana becomes a firm requirement
- A higher log retention requirement is imposed
- Highly customized metrics pipelines are needed
- Multi-cloud observability becomes a requirement
- Compliance or security requirements drive a different workspace strategy