variable "resource_group_name" {
  description = "Name of the resource group for the production foundation environment."
  type        = string

  validation {
    condition     = trim(var.resource_group_name) != ""
    error_message = "resource_group_name must not be empty."
  }
}

variable "location" {
  description = "Azure region for the production foundation environment."
  type        = string

  validation {
    condition     = trim(var.location) != ""
    error_message = "location must not be empty."
  }
}

variable "vnet_name" {
  description = "Name of the virtual network for the production foundation environment."
  type        = string

  validation {
    condition     = trim(var.vnet_name) != ""
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
      for subnet in values(var.subnets) : trim(subnet.name) != ""
    ])
    error_message = "Each subnet.name must not be empty."
  }

  validation {
    condition = alltrue([
      for subnet in values(var.subnets) : trim(subnet.nsg_name) != ""
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