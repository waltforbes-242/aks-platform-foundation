output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.this.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.this.name
}

output "log_analytics_workspace_workspace_id" {
  description = "Workspace ID of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.this.workspace_id
}

output "monitor_workspace_id" {
  description = "Resource ID of the Azure Monitor workspace."
  value       = azurerm_monitor_workspace.this.id
}

output "monitor_workspace_name" {
  description = "Name of the Azure Monitor workspace."
  value       = azurerm_monitor_workspace.this.name
}

output "monitor_workspace_query_endpoint" {
  description = "Query endpoint of the Azure Monitor workspace."
  value       = azurerm_monitor_workspace.this.query_endpoint
}