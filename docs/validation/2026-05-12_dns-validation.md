# DNS Validation — AKS Platform Foundation

## Objective

Validate Kubernetes DNS resolution and internal service discovery within the AKS platform foundation.

This validation confirms:
- CoreDNS functionality
- Kubernetes service discovery
- ClusterIP service resolution
- pod-to-service communication
- internal HTTP connectivity

---

## Environment

| Item | Value |
|---|---|
| Cluster | apf-aks-prod |
| Namespace | apps |
| DNS Service IP | 10.78.0.10 |
| Validation Service | validation-nginx |
| Date | 2026-05-12 |

---

## Validation Scope

The following capabilities were validated:

- CoreDNS availability
- DNS service resolution
- Kubernetes service FQDN resolution
- pod-to-service communication
- ClusterIP routing
- HTTP response validation

---

## Architecture Context

The AKS cluster was configured with:

| Setting | Value |
|---|---|
| Network Plugin | Azure CNI |
| Data Plane | Cilium |
| Service CIDR | 10.78.0.0/16 |
| DNS Service IP | 10.78.0.10 |

The validation workload:
- runs on the user node pool
- is exposed internally through a ClusterIP service

---

## Commands Executed

### Launch Diagnostic Pod

```bash
kubectl run dns-test -n apps \
  --rm -it \
  --image=busybox:1.36 \
  --restart=Never \
  -- sh
```

---

### Validate DNS Resolution

```sh
nslookup validation-nginx
```

---

### Validate HTTP Connectivity

```sh
wget -qO- http://validation-nginx
```

---

## Results

### DNS Resolution

Successful resolution occurred:

```text
Name:   validation-nginx.apps.svc.cluster.local
Address: 10.78.41.42
```

This confirms:
- CoreDNS operational status
- Kubernetes service discovery functioning
- ClusterIP allocation functioning

---

### DNS Service Validation

DNS queries were answered by:

```text
Server: 10.78.0.10
```

This matches the configured AKS DNS service IP.

---

### HTTP Connectivity Validation

Successful HTTP response received:

```html
<h1>Welcome to nginx!</h1>
```

This confirms:
- pod-to-service networking
- ClusterIP routing
- successful internal HTTP communication

---

## Observed NXDOMAIN Responses

Additional `NXDOMAIN` responses were observed during DNS lookup attempts.

Example:

```text
server can't find validation-nginx.cluster.local: NXDOMAIN
```

These responses are expected behavior.

Kubernetes DNS performs multiple search-path expansion attempts automatically before resolving the fully qualified service name.

The successful resolution of:

```text
validation-nginx.apps.svc.cluster.local
```

confirms DNS functionality is operating correctly.

---

## Operational Observations

### Networking Validation

This test indirectly validated:

- Azure CNI pod IP allocation
- Cilium dataplane operation
- service routing
- kube-proxy replacement behavior

---

### Workload Placement

Validation workloads were successfully scheduled onto the user node pool.

This confirms:
- node selector behavior
- workload isolation strategy

---

## Conclusion

Kubernetes DNS and service discovery are functioning correctly.

The AKS platform successfully supports:
- internal DNS resolution
- Kubernetes service discovery
- ClusterIP service routing
- pod-to-service communication

This validates the internal networking and service discovery baseline for the platform.
````
