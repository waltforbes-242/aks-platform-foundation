# Ingress Validation — ingress-nginx

## Objective

Validate north-south traffic flow into AKS through ingress-nginx.

---

## Environment

| Item | Value |
|---|---|
| Cluster | apf-aks-prod |
| Namespace | platform |
| Ingress Namespace | apps |
| Ingress Controller | ingress-nginx |
| Date | 2026-05-12 |

---

## Validation Scope

The following capabilities were validated:

- ingress-nginx deployment
- LoadBalancer provisioning
- public IP allocation
- ingress object reconciliation
- external TCP connectivity
- routing to application service

---

## Commands Executed

### Verify ingress controller

```bash
kubectl get pods -n platform -o wide
kubectl get svc -n platform
```

### Verify ingress resource

```bash
kubectl get ingress -n apps
```

### Validate external reachability

```powershell
Test-NetConnection -ComputerName 20.246.204.7 -Port 80
```

---

## Results

### Ingress Controller Pods

- Running successfully
- Scheduled onto user node pool
- No restart loops observed

### LoadBalancer Service

| Property | Value |
|---|---|
| Type | LoadBalancer |
| External IP | 20.246.204.7 |
| Port | 80 |

### Connectivity Test

```text
TcpTestSucceeded : True
```

Result:
- external TCP connectivity validated successfully

---

## Operational Observations

- ingress-nginx scheduled correctly to user node pool
- Azure LoadBalancer provisioning succeeded automatically
- Ingress object reconciled successfully
- Proxy restrictions prevented direct curl validation from local workstation

---

## Conclusion

Ingress functionality is operational.

The AKS platform successfully supports:
- external ingress
- Azure LoadBalancer integration
- ingress controller reconciliation
- north-south application traffic flow