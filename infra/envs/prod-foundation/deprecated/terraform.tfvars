resource_group_name = "apf-rg-prod"
location            = "eastus"

vnet_name          = "apf-vnet-prod"
vnet_address_space = ["10.77.0.0/16"]

subnets = {
  systempool1 = {
    name             = "apf-subnet-systempool1-prod"
    address_prefixes = ["10.77.0.0/22"]
    nsg_name         = "apf-nsg-systempool1-prod"
  }

  userpool1 = {
    name             = "apf-subnet-userpool1-prod"
    address_prefixes = ["10.77.4.0/22"]
    nsg_name         = "apf-nsg-userpool1-prod"
  }

  future1 = {
    name             = "apf-subnet-future1-prod"
    address_prefixes = ["10.77.8.0/22"]
    nsg_name         = "apf-nsg-future1-prod"
  }

  future2 = {
    name             = "apf-subnet-future2-prod"
    address_prefixes = ["10.77.12.0/22"]
    nsg_name         = "apf-nsg-future2-prod"
  }

  future3 = {
    name             = "apf-subnet-future3-prod"
    address_prefixes = ["10.77.16.0/22"]
    nsg_name         = "apf-nsg-future3-prod"
  }
}

acr_name                          = "apfacrprod01"
acr_sku                           = "Standard"
acr_admin_enabled                 = false
acr_public_network_access_enabled = true
acr_identity_type                 = null
acr_network_rule_bypass_option    = "AzureServices"

log_analytics_workspace_name    = "apf-law-prod"
log_analytics_workspace_sku     = "PerGB2018"
log_analytics_retention_in_days = 30
monitor_workspace_name          = "apf-amw-prod"

tags = {
  project     = "aks-platform-foundation"
  environment = "prod"
  owner       = "platform-team"
}