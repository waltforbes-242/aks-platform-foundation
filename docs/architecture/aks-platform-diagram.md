flowchart TB
    eng[Platform Engineer] --> repo[Git Repository]
    repo --> tf[Terraform]
    repo --> ci[CI Pipeline]

    ci --> acr[Azure Container Registry]

    subgraph Azure Subscription
        subgraph Network
            vnet[VNet]
            akssubnet[AKS Subnet]
        end

        subgraph Observability
            law[Log Analytics Workspace]
            amw[Azure Monitor Workspace]
            mon[Azure Monitor / Container Insights]
            graf[Managed Grafana Optional]
        end

        subgraph AKS
            cp[AKS Managed Control Plane]
            snp[System Node Pool]
            unp[User Node Pool]
            ns1[kube-system / platform namespaces]
            ns2[application namespaces]
        end
    end

    tf --> vnet
    tf --> law
    tf --> amw
    tf --> acr
    tf --> cp

    vnet --> akssubnet --> cp
    cp --> snp
    cp --> unp
    snp --> ns1
    unp --> ns2

    acr --> ns2
    cp --> mon
    cp --> law
    cp --> amw
    amw --> graf