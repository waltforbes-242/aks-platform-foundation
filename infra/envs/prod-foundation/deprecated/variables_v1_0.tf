variable "resource_group_name" {
  description = "Name of the resource group for the production foundation environment."
  type        = string
}

variable "location" {
  description = "Azure region for the production foundation environment."
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network for the production foundation environment."
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the production foundation virtual network."
  type        = list(string)
}

variable "subnets" {
  description = "Map of subnet definitions for the production foundation virtual network."
  type = map(object({
    name             = string
    address_prefixes = list(string)
    nsg_name         = string
  }))
}

variable "tags" {
  description = "Tags applied to taggable resources in the production foundation environment."
  type        = map(string)
}