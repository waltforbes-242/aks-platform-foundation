terraform {
  backend "azurerm" {
    resource_group_name  = "rg-apf-tfstate"
    storage_account_name = "stapftfstateprod01"
    container_name       = "tfstate"
    key                  = "prod-foundation.tfstate"
  }
}