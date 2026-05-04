terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.117"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "network" {
  source = "../../modules/network"

  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  vnet_name           = var.vnet_name
  vnet_address_space  = var.vnet_address_space
  subnets             = var.subnets
  tags                = var.tags
}

module "acr" {
  source = "../../modules/acr"

  name                          = var.acr_name
  resource_group_name           = azurerm_resource_group.this.name
  location                      = var.location
  sku                           = var.acr_sku
  admin_enabled                 = var.acr_admin_enabled
  public_network_access_enabled = var.acr_public_network_access_enabled
  identity_type                 = var.acr_identity_type
  network_rule_bypass_option    = var.acr_network_rule_bypass_option
  tags                          = var.tags
}

module "monitoring" {
  source = "../../modules/monitoring"

  resource_group_name             = azurerm_resource_group.this.name
  location                        = var.location
  log_analytics_workspace_name    = var.log_analytics_workspace_name
  log_analytics_workspace_sku     = var.log_analytics_workspace_sku
  log_analytics_retention_in_days = var.log_analytics_retention_in_days
  monitor_workspace_name          = var.monitor_workspace_name
  tags                            = var.tags
}

module "aks" {
  source = "../../modules/aks"

  cluster_name        = var.aks_cluster_name
  dns_prefix          = var.aks_dns_prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  kubernetes_version  = var.aks_kubernetes_version
  sku_tier            = var.aks_sku_tier

  system_node_pool = {
    name            = var.aks_system_node_pool.name
    vm_size         = var.aks_system_node_pool.vm_size
    subnet_id       = module.network.systempool_subnet_id
    node_count      = var.aks_system_node_pool.node_count
    min_count       = var.aks_system_node_pool.min_count
    max_count       = var.aks_system_node_pool.max_count
    os_disk_size_gb = var.aks_system_node_pool.os_disk_size_gb
    os_disk_type    = var.aks_system_node_pool.os_disk_type
  }

  user_node_pool = {
    name            = var.aks_user_node_pool.name
    vm_size         = var.aks_user_node_pool.vm_size
    subnet_id       = module.network.userpool_subnet_id
    node_count      = var.aks_user_node_pool.node_count
    min_count       = var.aks_user_node_pool.min_count
    max_count       = var.aks_user_node_pool.max_count
    os_disk_size_gb = var.aks_user_node_pool.os_disk_size_gb
    os_disk_type    = var.aks_user_node_pool.os_disk_type
  }

  service_cidr   = var.aks_service_cidr
  dns_service_ip = var.aks_dns_service_ip
  outbound_type  = var.aks_outbound_type

  oidc_issuer_enabled       = var.aks_oidc_issuer_enabled
  workload_identity_enabled = var.aks_workload_identity_enabled

  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  azure_monitor_workspace_id = module.monitoring.monitor_workspace_id

  acr_id                          = module.acr.id
  enable_acr_pull_role_assignment = var.aks_enable_acr_pull_role_assignment

  tags = var.tags
}