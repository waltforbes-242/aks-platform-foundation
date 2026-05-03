variable "name" {
  description = "Globally unique name of the Azure Container Registry."
  type        = string

  validation {
    condition     = trimspace(var.name) != ""
    error_message = "name must not be empty."
  }

  validation {
    condition     = can(regex("^[a-z0-9]{5,50}$", var.name))
    error_message = "name must be 5-50 lowercase alphanumeric characters, suitable for an Azure Container Registry name."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group containing the ACR."
  type        = string

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name must not be empty."
  }
}

variable "location" {
  description = "Azure region for the ACR."
  type        = string

  validation {
    condition     = trimspace(var.location) != ""
    error_message = "location must not be empty."
  }
}

variable "sku" {
  description = "ACR SKU."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "sku must be one of: Basic, Standard, Premium."
  }
}

variable "admin_enabled" {
  description = "Whether the ACR admin user is enabled."
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled for the ACR."
  type        = bool
  default     = true
}

variable "identity_type" {
  description = "Managed identity type for the ACR. Use null for no managed identity."
  type        = string
  default     = null

  validation {
    condition     = var.identity_type == null || contains(["SystemAssigned"], var.identity_type)
    error_message = "identity_type must be null or SystemAssigned."
  }
}

variable "network_rule_bypass_option" {
  description = "Whether trusted Azure services can bypass network rules."
  type        = string
  default     = "AzureServices"

  validation {
    condition     = contains(["AzureServices", "None"], var.network_rule_bypass_option)
    error_message = "network_rule_bypass_option must be either AzureServices or None."
  }
}

variable "tags" {
  description = "Tags to apply to the ACR."
  type        = map(string)
  default     = {}
}