resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  sku_tier = var.sku_tier

  oidc_issuer_enabled       = var.oidc_issuer_enabled
  workload_identity_enabled = var.workload_identity_enabled

  role_based_access_control_enabled = true

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name                 = var.system_node_pool.name
    vm_size              = var.system_node_pool.vm_size
    vnet_subnet_id       = var.system_node_pool.subnet_id
    type                 = "VirtualMachineScaleSets"
    enable_auto_scaling = true
    min_count            = var.system_node_pool.min_count
    max_count            = var.system_node_pool.max_count
    node_count           = var.system_node_pool.node_count
    os_disk_size_gb      = var.system_node_pool.os_disk_size_gb
    os_disk_type         = var.system_node_pool.os_disk_type
    only_critical_addons_enabled = true

    node_labels = {
      "nodepool-role" = "system"
    }

    tags = var.tags
  }

  network_profile {
    network_plugin      = "azure"
    network_data_plane  = "cilium"
    network_policy      = "cilium"
    service_cidr        = var.service_cidr
    dns_service_ip      = var.dns_service_ip
    outbound_type       = var.outbound_type
    load_balancer_sku   = "standard"
  }

  oms_agent {
    log_analytics_workspace_id      = var.log_analytics_workspace_id
    msi_auth_for_monitoring_enabled = true
  }

  monitor_metrics {
    annotations_allowed = null
    labels_allowed      = null
  }

  tags = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = var.user_node_pool.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = var.user_node_pool.vm_size
  vnet_subnet_id        = var.user_node_pool.subnet_id
  mode                  = "User"

  enable_auto_scaling = true
  min_count            = var.user_node_pool.min_count
  max_count            = var.user_node_pool.max_count
  node_count           = var.user_node_pool.node_count

  os_disk_size_gb = var.user_node_pool.os_disk_size_gb
  os_disk_type    = var.user_node_pool.os_disk_type

  node_labels = {
    "nodepool-role" = "user"
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "acr_pull" {
  count = var.enable_acr_pull_role_assignment ? 1 : 0

  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}