variable "resource_group_name" {
  description = "Name of the resource group that contains the VNet, subnets, and NSGs."
  type        = string

  validation {
    condition     = trim(var.resource_group_name) != ""
    error_message = "resource_group_name must not be empty."
  }
}

variable "location" {
  description = "Azure region for the network resources."
  type        = string

  validation {
    condition     = trim(var.location) != ""
    error_message = "location must not be empty."
  }
}

variable "vnet_name" {
  description = "Name of the virtual network."
  type        = string

  validation {
    condition     = trim(var.vnet_name) != ""
    error_message = "vnet_name must not be empty."
  }
}

variable "vnet_address_space" {
  description = "Address space for the virtual network."
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

  validation {
    condition     = length(distinct(var.vnet_address_space)) == length(var.vnet_address_space)
    error_message = "vnet_address_space must not contain duplicate CIDR blocks."
  }
}

variable "subnets" {
  description = "Map of subnet definitions to create in the VNet."
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
      for subnet in values(var.subnets) :
      trim(subnet.name) != ""
    ])
    error_message = "Each subnet.name must not be empty."
  }

  validation {
    condition = alltrue([
      for subnet in values(var.subnets) :
      trim(subnet.nsg_name) != ""
    ])
    error_message = "Each subnet.nsg_name must not be empty."
  }

  validation {
    condition = alltrue([
      for subnet in values(var.subnets) :
      length(subnet.address_prefixes) > 0
    ])
    error_message = "Each subnet must define at least one address prefix."
  }

  validation {
    condition = alltrue(flatten([
      for subnet in values(var.subnets) : [
        for cidr in subnet.address_prefixes : can(cidrhost(cidr, 0))
      ]
    ]))
    error_message = "Every subnet address prefix must be a valid CIDR block."
  }

  validation {
    condition = length(distinct([
      for subnet in values(var.subnets) : subnet.name
    ])) == length(values(var.subnets))
    error_message = "Each subnet.name must be unique."
  }

  validation {
    condition = length(distinct([
      for subnet in values(var.subnets) : subnet.nsg_name
    ])) == length(values(var.subnets))
    error_message = "Each subnet.nsg_name must be unique."
  }

  validation {
    condition = length(distinct(flatten([
      for subnet in values(var.subnets) : subnet.address_prefixes
      ]))) == length(flatten([
      for subnet in values(var.subnets) : subnet.address_prefixes
    ]))
    error_message = "Subnet address prefixes must be unique across all subnets in this module."
  }
}

variable "tags" {
  description = "Tags to apply to taggable resources."
  type        = map(string)
  default     = {}
}