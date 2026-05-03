resource "azurerm_log_analytics_workspace" "this" {
  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = var.log_analytics_retention_in_days
  tags                = var.tags
}

resource "azurerm_monitor_workspace" "this" {
  name                = var.monitor_workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}