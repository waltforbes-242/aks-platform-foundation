flowchart TB
    dev[Platform Engineer / App Team] --> git[Git Repos: infra + k8s]
    git --> ci[CI Pipeline: build scan push]
    ci --> acr[Azure Container Registry]

    subgraph Azure Subscription
        subgraph Observability
            am[Azure Monitor]
            mp[Managed Prometheus]
            mg[Managed Grafana]
            la[Log Analytics]
        end

        subgraph Networking
            vnet[VNet]
            subnets[AKS Subnets]
        end

        subgraph AKS
            cp[AKS Managed Control Plane]
            snp[System Node Pool]
            unp[User Node Pool]
            ingress[Ingress / Gateway]
            apps[Workloads / Namespaces]
        end
    end

    dev --> cp
    acr --> apps
    cp --> snp
    cp --> unp
    ingress --> apps
    apps --> am
    apps --> mp
    cp --> am
    cp --> la
    mp --> mg
    vnet --> cp
    subnets --> snp
    subnets --> unp