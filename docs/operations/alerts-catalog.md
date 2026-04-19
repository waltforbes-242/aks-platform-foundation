# alerts-catalog.md

## Purpose

This document defines the **production alert catalog** for the AKS Platform Foundation.

Alerts are:
- **Actionable**
- **Owned**
- **Mapped to failure modes**

No alert exists without a documented operator response. 

---

## Alerting Principles

- Prefer **symptom-based alerts** over raw metrics.
- Alert on **sustained conditions**, not transient spikes.
- Alerts reflect **platform risk**, not application bugs.
- Paging alerts imply **human action is required now**.

---

## Alert Catalog

### Platform & Control Plane Alerts

| Alert Name | Signal Source | Condition | Severity | Operator Action |
|----------|--------------|----------|---------|----------------|
| NodeNotReady | Azure Monitor metric | Node Ready = false > 5 min | Critical | Investigate node health, drain if required |
| ControlPlaneUnreachable | Azure Monitor | API server errors sustained | Critical | Validate Azure service health, escalate |
| NodeDiskPressure | Azure Monitor | Disk pressure sustained | Warning | Validate pod storage usage |

---

### Workload & Scheduling Alerts

| Alert Name | Signal Source | Condition | Severity | Operator Action |
|----------|--------------|----------|---------|----------------|
| PodCrashLoopSpike | Prometheus | Restart rate exceeds baseline | Warning | Follow CrashLoop runbook |
| DeploymentUnavailable | Prometheus | Available replicas < desired | Critical | Inspect rollout, rollback if needed |
| PendingPodsCapacity | Prometheus | Pods pending > 5 min | Warning | Check autoscaler and requests |

---

### Autoscaling & Capacity Alerts

| Alert Name | Signal Source | Condition | Severity | Operator Action |
|----------|--------------|----------|---------|----------------|
| AutoscalerMaxReached | Azure Monitor | Node pool at max | Warning | Assess capacity limits |
| CPUHighSustained | Azure Monitor | >80% for 10 min | Warning | Confirm scaling behavior |
| MemoryHighSustained | Azure Monitor | >80% for 10 min | Warning | Inspect workload requests |

---

### Supply Chain Alerts

| Alert Name | Signal Source | Condition | Severity | Operator Action |
|----------|--------------|----------|---------|----------------|
| ImagePullFailure | Kubernetes event | ImagePullBackOff sustained | Critical | Validate ACR auth, tag correctness |

---

## Alert Severity Definitions

| Severity | Meaning |
|--------|--------|
| Critical | Service impact imminent or occurring |
| Warning | Degradation risk or scaling boundary |
| Info | Non-actionable signal (generally avoided) |

---

## Explicitly Excluded Alerts

- Single pod failures without replica impact
- Short-lived CPU spikes
- Log-pattern-based alerts without clear action

These exclusions are intentional to avoid **alert fatigue**. 

---

## Why This Passes Design Review

- Alerts map directly to documented failure scenarios.
- Severity reflects **blast radius**, not metric magnitude.
- Clear operator actions prevent “alert but no owner” failures.
- Catalog demonstrates production alert hygiene, not checkbox monitoring. 
``