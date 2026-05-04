output "resource_group_id" {
  description = "ID of the production foundation resource group."
  value       = azurerm_resource_group.this.id
}

output "resource_group_name" {
  description = "Name of the production foundation resource group."
  value       = azurerm_resource_group.this.name
}

output "network_vnet_id" {
  description = "ID of the production foundation virtual network."
  value       = module.network.vnet_id
}

output "network_vnet_name" {
  description = "Name of the production foundation virtual network."
  value       = module.network.vnet_name
}

output "network_subnet_ids" {
  description = "Map of production foundation subnet IDs keyed by logical subnet key."
  value       = module.network.subnet_ids
}

output "systempool_subnet_id" {
  description = "ID of the system node pool subnet."
  value       = module.network.systempool_subnet_id
}

output "userpool_subnet_id" {
  description = "ID of the user node pool subnet."
  value       = module.network.userpool_subnet_id
}

output "acr_id" {
  description = "Resource ID of the Azure Container Registry."
  value       = module.acr.id
}

output "acr_login_server" {
  description = "Login server of the Azure Container Registry."
  value       = module.acr.login_server
}

output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace."
  value       = module.monitoring.log_analytics_workspace_id
}

output "monitor_workspace_id" {
  description = "Resource ID of the Azure Monitor workspace."
  value       = module.monitoring.monitor_workspace_id
}

output "aks_cluster_id" {
  description = "AKS cluster resource ID."
  value       = module.aks.id
}

output "aks_cluster_name" {
  description = "AKS cluster name."
  value       = module.aks.name
}

output "aks_oidc_issuer_url" {
  description = "AKS OIDC issuer URL."
  value       = module.aks.oidc_issuer_url
}

output "aks_node_resource_group" {
  description = "AKS managed node resource group."
  value       = module.aks.node_resource_group
}

output "aks_kubelet_identity_object_id" {
  description = "AKS kubelet identity object ID."
  value       = module.aks.kubelet_identity_object_id
}

output "aks_system_node_pool_name" {
  description = "AKS system node pool name."
  value       = module.aks.system_node_pool_name
}

output "aks_user_node_pool_name" {
  description = "AKS user node pool name."
  value       = module.aks.user_node_pool_name
}

output "network_subnet_names" {
  description = "Map of production foundation subnet names keyed by logical subnet key."
  value       = module.network.subnet_names
}

output "network_nsg_ids" {
  description = "Map of production foundation NSG IDs keyed by logical subnet key."
  value       = module.network.nsg_ids
}

output "network_nsg_names" {
  description = "Map of production foundation NSG names keyed by logical subnet key."
  value       = module.network.nsg_names
}