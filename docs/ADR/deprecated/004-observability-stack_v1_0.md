# ADR-004: Observability Stack — Azure Monitor + Prometheus

## Status
Accepted

## Context
Production AKS requires visibility into health, performance, and failure modes without operating a separate observability platform.

## Decision
We will use **Azure Monitor for logs** and **managed Prometheus for metrics**.

Logs and metrics are treated as distinct signals, each optimized for its purpose.

## Alternatives Considered
### Self-Hosted Prometheus + Grafana
- **Pros**: Full control.
- **Cons**: High operational burden.
- **Rejected**.

### Logs-Only Monitoring
- **Pros**: Simpler.
- **Cons**: Poor alerting and SLO tracking.
- **Rejected**.

## Consequences
- **Operational**: Lower maintenance overhead.
- **Alerting**: Actionable alerts only; no noise.
- **Cost**: Predictable managed-service pricing.
- **Security**: Azure-native access control.

## Revisit Criteria
- Need for highly customized metrics pipelines.
- Multi-cloud observability requirements.
``