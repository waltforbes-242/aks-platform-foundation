# Workload Identity Validation — AKS Platform Foundation

## Objective

Validate Azure Workload Identity integration between AKS and Azure Key Vault using federated authentication and managed identities.

This validation confirms:

- OIDC issuer functionality
- Kubernetes ServiceAccount federation
- Azure Workload Identity integration
- managed identity authentication from workloads
- Azure Key Vault secret retrieval
- Azure SDK authentication without secrets
- RBAC-based authorization to Azure resources

---

## Environment

| Item | Value |
|---|---|
| Cluster | apf-aks-prod |
| Namespace | apps |
| ServiceAccount | wi-keyvault-reader |
| Managed Identity | apf-wi-kv-reader-prod |
| Key Vault | apf-kv-wi-prod-242 |
| Validation Secret | platform-validation-message |
| Date | 2026-05-13 |

---

## Validation Scope

The following capabilities were validated:

- AKS OIDC issuer configuration
- federated credential creation
- Kubernetes ServiceAccount identity binding
- Azure managed identity federation
- Azure SDK authentication using Workload Identity
- Key Vault RBAC authorization
- secret retrieval without static credentials

---

## Architecture Context

The AKS platform was configured with:

| Capability | Status |
|---|---|
| OIDC Issuer | Enabled |
| Workload Identity | Enabled |
| Azure RBAC | Enabled |
| Managed Identity | User-assigned |

The validation workflow used:

- Kubernetes ServiceAccount
- Azure federated credential
- Azure SDK `DefaultAzureCredential`
- Azure Key Vault RBAC authorization

No:
- Kubernetes Secrets
- service principals
- static credentials
- imagePullSecrets

were used for authentication.

---

## Azure Resources Created

### Managed Identity

```text
apf-wi-kv-reader-prod
```

---

### Azure Key Vault

```text
apf-kv-wi-prod-242
```

---

### Key Vault Secret

```text
platform-validation-message
```

---

## Kubernetes Resources Created

### ServiceAccount

```text
wi-keyvault-reader
```

---

### Validation Pod

```text
wi-kv-test
```

---

## Validation Workflow

### 1. Configure Azure Workload Identity Components

The following components were configured:

- user-assigned managed identity
- federated credential
- Kubernetes ServiceAccount annotation
- Azure RBAC role assignment

---

### 2. Create Validation Pod

A Python-based validation pod was deployed.

The pod used:

- `python:3.11-slim`
- Azure SDK libraries
- Kubernetes ServiceAccount federation

---

### Validation Pod Manifest

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: wi-kv-test
  namespace: apps
  labels:
    azure.workload.identity/use: "true"

spec:
  serviceAccountName: wi-keyvault-reader

  nodeSelector:
    nodepool-role: user

  restartPolicy: Never

  containers:
  - name: python
    image: python:3.11-slim
    command: ["bash"]
    stdin: true
    tty: true
```

---

## Commands Executed

### Deploy Validation Pod

```bash
kubectl apply -f workload-identity-python-test-pod_v3.yaml
```

---

### Validate Pod Status

```bash
kubectl get pod wi-kv-test -n apps -o wide
```

---

### Attach Interactive Shell

```bash
kubectl exec -it wi-kv-test -n apps -- bash
```

---

### Install Azure SDK Packages

```bash
pip install --upgrade pip
pip install azure-identity azure-keyvault-secrets
```

---

### Create Validation Script

```bash
cat << 'EOF' > test_kv.py
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

vault_url = "https://apf-kv-wi-prod-242.vault.azure.net/"
secret_name = "platform-validation-message"

cred = DefaultAzureCredential()
client = SecretClient(vault_url=vault_url, credential=cred)

print(client.get_secret(secret_name).value)
EOF
```

---

### Execute Validation Script

```bash
python3 test_kv.py
```

---

## Results

### Azure SDK Authentication

The Azure SDK successfully authenticated using:

```python
DefaultAzureCredential()
```

This confirms:
- federated token projection functioning
- Workload Identity webhook functioning
- Azure identity federation functioning

---

### Secret Retrieval

The following output was returned successfully:

```text
Workload Identity validation succeeded
```

This confirms:

- successful authentication to Azure
- successful Key Vault authorization
- successful secret retrieval
- successful Azure SDK integration

---

## Operational Observations

### No Static Credentials Used

Authentication occurred entirely through:

- Kubernetes ServiceAccount federation
- Azure managed identity
- OIDC token exchange

No:
- passwords
- client secrets
- certificates
- Kubernetes Secrets

were required.

---

### Security Benefits

This design provides:

- secretless authentication
- reduced credential sprawl
- least-privilege Azure access
- workload-level identity isolation
- cloud-native authentication patterns

---

### Workload Placement

The validation pod was successfully scheduled onto:

```text
aks-userpool1-*
```

This confirms:
- workload placement controls
- user workload isolation strategy

---

## Enterprise Relevance

This validation demonstrates a modern enterprise identity pattern used for:

- application-to-cloud authentication
- secretless Kubernetes workloads
- secure Azure resource access
- multi-team workload isolation
- zero-trust platform architecture

---

## Future Enhancements

Future platform phases may extend this pattern with:

- per-namespace identities
- Key Vault CSI Driver integration
- GitOps-managed identity bindings
- admission policy enforcement
- workload identity governance

---

## Conclusion

Azure Workload Identity is functioning correctly.

The AKS platform successfully supports:

- federated workload authentication
- managed identity integration
- Azure SDK authentication
- secure Key Vault access
- secretless workload authorization

This validates the enterprise identity baseline for the AKS platform foundation.