variable "resource_group_name" {
  description = "Name of the resource group that contains the VNet, subnets, and NSGs."
  type        = string
}

variable "location" {
  description = "Azure region for the network resources."
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network."
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the virtual network."
  type        = list(string)
}

variable "subnets" {
  description = "Map of subnet definitions to create in the VNet."
  type = map(object({
    name             = string
    address_prefixes = list(string)
    nsg_name         = string
  }))
}

variable "tags" {
  description = "Tags to apply to taggable resources."
  type        = map(string)
}