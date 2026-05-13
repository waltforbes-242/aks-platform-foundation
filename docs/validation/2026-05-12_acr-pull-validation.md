# ACR Pull Validation — AKS Platform Foundation

## Objective

Validate end-to-end container image delivery from Azure Container Registry (ACR) into AKS using managed identity authentication.

This validation confirms:
- successful image build
- successful image push to ACR
- successful image pull by AKS
- successful workload deployment using ACR-hosted images
- successful service connectivity inside the cluster

---

## Environment

| Item | Value |
|---|---|
| Cluster | apf-aks-prod |
| Namespace | apps |
| Registry | apfacrprod01.azurecr.io |
| Validation Application | sample-web |
| Date | 2026-05-12 |

---

## Validation Scope

The following capabilities were validated:

- Docker image build
- Docker push to ACR
- ACR authentication
- AcrPull role assignment functionality
- AKS image pull from ACR
- workload scheduling to user node pool
- internal Kubernetes service connectivity

---

## Architecture Context

The AKS cluster uses:
- system-assigned managed identity
- kubelet identity with AcrPull role assignment
- Azure Container Registry as trusted image source

No Kubernetes imagePullSecrets were used.

---

## Commands Executed

### Authenticate to ACR

```bash
az acr login --name apfacrprod01
```

---

### Build Container Image

```bash
docker build -t apfacrprod01.azurecr.io/sample-web:v1 .
```

---

### Push Image to ACR

```bash
docker push apfacrprod01.azurecr.io/sample-web:v1
```

---

### Deploy Workload to AKS

```bash
kubectl apply -f acr-sample-web.yaml
```

---

### Validate Pod Status

```bash
kubectl get pods -n apps -o wide
```

---

### Validate Internal Service Connectivity

```bash
kubectl run acr-test -n apps \
  --rm -it \
  --image=busybox:1.36 \
  --restart=Never \
  -- wget -qO- http://acr-sample-web
```

---

## Results

### Pod Scheduling

Pods successfully scheduled to:

```text
aks-userpool1-23041794-vmss000005
```

This confirms:
- node selector behavior
- workload isolation onto user node pool

---

### Pod Status

All application pods reached:

```text
STATUS = Running
```

No:
- ImagePullBackOff
- ErrImagePull
- CrashLoopBackOff

conditions were observed.

---

### Service Connectivity

The validation workload responded successfully:

```html
<h1>AKS Platform Foundation</h1>
<h2>Image pulled from Azure Container Registry.</h2>
```

This confirms:
- successful image pull from ACR
- successful Kubernetes service routing
- successful in-cluster HTTP communication

---

## Operational Observations

### Authentication Model

AKS successfully pulled images without:
- imagePullSecrets
- static credentials
- admin-enabled registry authentication

Authentication occurred through:
- kubelet managed identity
- AcrPull role assignment

---

### Security Benefits

This design:
- eliminates registry credentials in Kubernetes
- reduces secret sprawl
- aligns with least-privilege access principles
- supports future multi-team workload isolation

---

## Conclusion

ACR integration is functioning correctly.

The AKS platform successfully supports:
- Azure-native container registry integration
- managed identity-based image pulls
- secure workload deployment
- internal Kubernetes service communication

This validates the platform image supply chain baseline.