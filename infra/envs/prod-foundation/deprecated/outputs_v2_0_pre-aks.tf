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

output "systempool_subnet_id" {
  description = "ID of the system node pool subnet."
  value       = module.network.systempool_subnet_id
}

output "userpool_subnet_id" {
  description = "ID of the user node pool subnet."
  value       = module.network.userpool_subnet_id
}