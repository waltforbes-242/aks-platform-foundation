output "id" {
  description = "Resource ID of the Azure Container Registry."
  value       = azurerm_container_registry.this.id
}

output "name" {
  description = "Name of the Azure Container Registry."
  value       = azurerm_container_registry.this.name
}

output "login_server" {
  description = "Login server of the Azure Container Registry."
  value       = azurerm_container_registry.this.login_server
}

output "sku" {
  description = "SKU of the Azure Container Registry."
  value       = azurerm_container_registry.this.sku
}

output "admin_enabled" {
  description = "Whether the admin user is enabled on the Azure Container Registry."
  value       = azurerm_container_registry.this.admin_enabled
}

output "public_network_access_enabled" {
  description = "Whether public network access is enabled on the Azure Container Registry."
  value       = azurerm_container_registry.this.public_network_access_enabled
}

output "identity_principal_id" {
  description = "Principal ID of the ACR managed identity, if enabled."
  value       = try(azurerm_container_registry.this.identity[0].principal_id, null)
}

output "identity_tenant_id" {
  description = "Tenant ID of the ACR managed identity, if enabled."
  value       = try(azurerm_container_registry.this.identity[0].tenant_id, null)
}