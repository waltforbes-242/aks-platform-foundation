# AKS Module

## Overview

This module provisions a production-grade Azure Kubernetes Service (AKS) cluster.

---

## Features

- Azure CNI with Cilium
- System and user node pools
- Cluster autoscaler
- OIDC issuer enabled
- Workload Identity enabled
- ACR integration via managed identity
- Azure Monitor + Log Analytics integration

---

## Inputs

### Required

- cluster_name
- resource_group_name
- location
- system_node_pool
- user_node_pool
- log_analytics_workspace_id
- azure_monitor_workspace_id
- acr_id

---

## Outputs

- cluster ID
- cluster name
- node resource group
- OIDC issuer URL
- kubelet identity object ID

---

## Usage

```hcl
module "aks" {
  source = "../../modules/aks"

  cluster_name = "apf-aks-prod"
...
}
```

## Design Principles
- secure by default
- no secrets in configuration
- separation of system and workload resources
- Azure-native integrations
- production-first defaults


## Future Enhancements
- private cluster support
- controlled egress
- GitOps integration
- network policies

---