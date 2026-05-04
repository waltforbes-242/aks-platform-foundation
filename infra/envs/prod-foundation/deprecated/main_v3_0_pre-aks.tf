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