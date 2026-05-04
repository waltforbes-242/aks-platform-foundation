variable "resource_group_name" {
  description = "Name of the resource group for the production foundation environment."
  type        = string

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name must not be empty."
  }
}

variable "location" {
  description = "Azure region for the production foundation environment."
  type        = string

  validation {
    condition     = trimspace(var.location) != ""
    error_message = "location must not be empty."
  }
}

variable "vnet_name" {
  description = "Name of the virtual network for the production foundation environment."
  type        = string

  validation {
    condition     = trimspace(var.vnet_name) != ""
    error_message = "vnet_name must not be empty."
  }
}

variable "vnet_address_space" {
  description = "Address space for the production foundation virtual network."
  type        = list(string)

  validation {
    condition     = length(var.vnet_address_space) > 0
    error_message = "vnet_address_space must contain at least one CIDR block."
  }

  validation {
    condition = alltrue([
      for cidr in var.vnet_address_space : can(cidrhost(cidr, 0))
    ])
    error_message = "Every value in vnet_address_space must be a valid CIDR block."
  }
}

variable "subnets" {
  description = "Map of subnet definitions for the production foundation virtual network."
  type = map(object({
    name             = string
    address_prefixes = list(string)
    nsg_name         = string
  }))

  validation {
    condition = (
      contains(keys(var.subnets), "systempool1") &&
      contains(keys(var.subnets), "userpool1")
    )
    error_message = "subnets must include the logical keys \"systempool1\" and \"userpool1\"."
  }

  validation {
    condition = alltrue([
      for subnet in values(var.subnets) : trimspace(subnet.name) != ""
    ])
    error_message = "Each subnet.name must not be empty."
  }

  validation {
    condition = alltrue([
      for subnet in values(var.subnets) : trimspace(subnet.nsg_name) != ""
    ])
    error_message = "Each subnet.nsg_name must not be empty."
  }

  validation {
    condition = alltrue(flatten([
      for subnet in values(var.subnets) : [
        for cidr in subnet.address_prefixes : can(cidrhost(cidr, 0))
      ]
    ]))
    error_message = "Every subnet address prefix must be a valid CIDR block."
  }
}

variable "acr_name" {
  description = "Globally unique name of the Azure Container Registry."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{5,50}$", var.acr_name))
    error_message = "acr_name must be 5-50 lowercase alphanumeric characters."
  }
}

variable "acr_sku" {
  description = "SKU for the Azure Container Registry."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "acr_sku must be one of: Basic, Standard, Premium."
  }
}

variable "acr_admin_enabled" {
  description = "Whether the ACR admin user is enabled."
  type        = bool
  default     = false
}

variable "acr_public_network_access_enabled" {
  description = "Whether public network access is enabled for the ACR."
  type        = bool
  default     = true
}

variable "acr_identity_type" {
  description = "Managed identity type for ACR. Use null for no managed identity."
  type        = string
  default     = null

  validation {
    condition     = var.acr_identity_type == null || contains(["SystemAssigned"], var.acr_identity_type)
    error_message = "acr_identity_type must be null or SystemAssigned."
  }
}

variable "acr_network_rule_bypass_option" {
  description = "Whether trusted Azure services can bypass ACR network rules."
  type        = string
  default     = "AzureServices"

  validation {
    condition     = contains(["AzureServices", "None"], var.acr_network_rule_bypass_option)
    error_message = "acr_network_rule_bypass_option must be either AzureServices or None."
  }
}

variable "tags" {
  description = "Tags applied to taggable resources in the production foundation environment."
  type        = map(string)

  validation {
    condition = (
      contains(keys(var.tags), "project") &&
      contains(keys(var.tags), "environment") &&
      contains(keys(var.tags), "owner")
    )
    error_message = "tags must include at least: project, environment, and owner."
  }
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace for the production foundation environment."
  type        = string

  validation {
    condition     = trimspace(var.log_analytics_workspace_name) != ""
    error_message = "log_analytics_workspace_name must not be empty."
  }
}

variable "log_analytics_workspace_sku" {
  description = "SKU for the Log Analytics workspace."
  type        = string
  default     = "PerGB2018"

  validation {
    condition     = contains(["PerGB2018", "CapacityReservation"], var.log_analytics_workspace_sku)
    error_message = "log_analytics_workspace_sku must be either PerGB2018 or CapacityReservation."
  }
}

variable "log_analytics_retention_in_days" {
  description = "Retention period in days for the Log Analytics workspace."
  type        = number
  default     = 30

  validation {
    condition     = var.log_analytics_retention_in_days >= 30 && var.log_analytics_retention_in_days <= 730
    error_message = "log_analytics_retention_in_days must be between 30 and 730."
  }
}

variable "monitor_workspace_name" {
  description = "Name of the Azure Monitor workspace for managed Prometheus."
  type        = string

  validation {
    condition     = trimspace(var.monitor_workspace_name) != ""
    error_message = "monitor_workspace_name must not be empty."
  }
}