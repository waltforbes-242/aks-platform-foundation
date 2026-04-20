output "vnet_id" {
  description = "ID of the virtual network."
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Name of the virtual network."
  value       = azurerm_virtual_network.this.name
}

output "vnet_address_space" {
  description = "Address space of the virtual network."
  value       = azurerm_virtual_network.this.address_space
}

output "subnet_ids" {
  description = "Map of subnet IDs keyed by logical subnet key."
  value = {
    for key, subnet in azurerm_subnet.this : key => subnet.id
  }
}

output "subnet_names" {
  description = "Map of subnet names keyed by logical subnet key."
  value = {
    for key, subnet in azurerm_subnet.this : key => subnet.name
  }
}

output "subnet_address_prefixes" {
  description = "Map of subnet address prefixes keyed by logical subnet key."
  value = {
    for key, subnet in azurerm_subnet.this : key => subnet.address_prefixes
  }
}

output "systempool_subnet_id" {
  description = "ID of the system node pool subnet."
  value       = azurerm_subnet.this["systempool1"].id
}

output "userpool_subnet_id" {
  description = "ID of the user node pool subnet."
  value       = azurerm_subnet.this["userpool1"].id
}