# AKS Validation Runbook

## Purpose

Validate that the AKS cluster is deployed correctly and operational.

---

## Terraform Validation

```bash
terraform plan
```
Expected:
No changes. Your infrastructure matches the configuration.

## Azure Validation

```bash
az aks show \
  --resource-group apf-rg-prod \
  --name apf-aks-prod
```

Verify:
- provisioningState = Succeeded
- OIDC issuer enabled
- Workload Identity enabled

## Node Pool Validation

```bash
az aks nodepool list \
  --resource-group apf-rg-prod \
  --cluster-name apf-aks-prod \
  -o table
```

Verify:
- systempool1 exists
- userpool1 exists
- autoscaling enabled

## Kubernetes Access

```bash
az aks get-credentials \
  --resource-group apf-rg-prod \
  --name apf-aks-prod
```

```bash
kubectl get nodes -o wide
```

Verify:
- nodes from both pools present

## System Health
```bash
kubectl get pods -A
```

Verify:
- kube-system pods running
- no CrashLoopBackOff

## ACR Integration
```bash
az role assignment list --scope <acr-id>
```

Verify:
- AcrPull assigned to kubelet identity

## Monitoring Validation
```bash
kubectl get pods -n kube-system
```

Verify:
- monitoring agents running

## Success Criteria
- cluster reachable
- nodes ready
- monitoring active
- no Terraform drift