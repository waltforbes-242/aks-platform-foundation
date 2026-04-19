# monitoring-scope.md

## Purpose

This document defines the **monitoring scope** for the Production AKS Platform Foundation.  
It establishes **what is monitored**, **why it is monitored**, and **which signals are authoritative** for operational decision-making.

The goal is not exhaustive telemetry, but **sufficient signal coverage to operate the platform safely under failure, load, and change**. 

---

## Scope Summary

| Layer | In Scope | Tooling |
|-----|--------|--------|
| AKS control plane | ✅ | Azure Monitor platform metrics + resource logs |
| Node pools (system + user) | ✅ | Azure Monitor metrics, Container Insights |
| Kubernetes workloads | ✅ | Managed Prometheus, Container Insights |
| Autoscaling behavior | ✅ | Azure Monitor metrics, Prometheus |
| CI/CD pipelines | ❌ | Out of scope |
| Application business metrics | ❌ | Owned by app teams |

---

## Monitoring Signals by Category

### 1. Platform & Infrastructure Metrics

**Authoritative source:** Azure Monitor metrics

Monitored signals:
- Node readiness and availability
- CPU and memory utilization per node pool
- Disk pressure and ephemeral storage pressure
- Control plane API request latency and error rates

Rationale:
- These signals reflect **cluster survivability**, not application correctness.
- Azure Monitor metrics are preferred for **node and control-plane health** due to native integration and low operational overhead. 

---

### 2. Kubernetes Workload Metrics

**Authoritative source:** Managed Prometheus

Monitored signals:
- Pod restart count and rate
- Deployment replica availability
- HPA scale events and target saturation
- Pending pods due to scheduling constraints

Rationale:
- Prometheus metrics provide **workload-level intent and behavior**, which Azure metrics alone cannot express.
- These signals are critical to diagnosing **capacity vs. configuration failures**. 

---

### 3. Logs and Events

**Authoritative source:** Container Insights (Log Analytics)

Collected logs:
- Container stdout/stderr
- Kubernetes events
- Kubelet and node diagnostics
- AKS control plane resource logs

Usage guidelines:
- Logs are used for **diagnosis**, not health determination.
- Alerts must never trigger directly from high-volume logs unless explicitly justified.

Rationale:
- Log ingestion is a primary cost driver; logs must be **purposefully consumed**. 

---

## Dashboards (Required)

Dashboards are treated as **operational tools**, not vanity views.

Minimum dashboards:
- **Cluster Health:** node readiness, system pod health
- **Workload Health:** deployment availability, restarts
- **Capacity & Scaling:** CPU/memory saturation, HPA activity
- **Failure Indicators:** restart spikes, unavailable replicas

Ownership:
- Platform team owns dashboard creation and signal correctness.
- App teams may contribute panels but do not define platform SLOs.

---

## Signal Ownership and Boundaries

| Signal Type | Owner |
|-----------|------|
| Control plane health | Platform team |
| Node pool capacity | Platform team |
| Autoscaler behavior | Platform team |
| Workload health signals | Shared (platform provides, apps consume) |

This separation ensures **clear operational accountability during incidents**. 

---

## Out of Scope (Explicit)

- Distributed tracing
- Third‑party APM tools
- Application‑specific business KPIs
- Long‑term metrics retention beyond platform needs

These may be introduced later but are intentionally excluded from the baseline to control complexity and cost.

---

## Why This Passes Design Review

- Explicit signal ownership prevents alert fatigue and blame diffusion.
- Azure‑native tooling minimizes operational overhead.
- Monitoring scope aligns with **failure domains**, not tooling features.
- Cost awareness is built into signal selection and retention decisions. 
``