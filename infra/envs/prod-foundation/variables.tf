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
}

variable "subnets" {
  description = "Map of subnet definitions for the production foundation virtual network."
  type = map(object({
    name             = string
    address_prefixes = list(string)
    nsg_name         = string
  }))
}

variable "acr_name" {
  description = "Globally unique name of the Azure Container Registry."
  type        = string
}

variable "acr_sku" {
  description = "SKU for the Azure Container Registry."
  type        = string
  default     = "Standard"
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
}

variable "acr_network_rule_bypass_option" {
  description = "Whether trusted Azure services can bypass ACR network rules."
  type        = string
  default     = "AzureServices"
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace."
  type        = string
}

variable "log_analytics_workspace_sku" {
  description = "SKU for the Log Analytics workspace."
  type        = string
  default     = "PerGB2018"
}

variable "log_analytics_retention_in_days" {
  description = "Retention period in days for the Log Analytics workspace."
  type        = number
  default     = 30
}

variable "monitor_workspace_name" {
  description = "Name of the Azure Monitor workspace."
  type        = string
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster."
  type        = string
}

variable "aks_dns_prefix" {
  description = "DNS prefix for the AKS cluster."
  type        = string
}

variable "aks_kubernetes_version" {
  description = "AKS Kubernetes version. Null allows Azure to choose the default supported version."
  type        = string
  default     = null
}

variable "aks_sku_tier" {
  description = "AKS SKU tier."
  type        = string
  default     = "Free"
}

variable "aks_system_node_pool" {
  description = "AKS system node pool configuration."
  type = object({
    name            = string
    vm_size         = string
    node_count      = number
    min_count       = number
    max_count       = number
    os_disk_size_gb = number
    os_disk_type    = string
  })
}

variable "aks_user_node_pool" {
  description = "AKS user node pool configuration."
  type = object({
    name            = string
    vm_size         = string
    node_count      = number
    min_count       = number
    max_count       = number
    os_disk_size_gb = number
    os_disk_type    = string
  })
}

variable "aks_service_cidr" {
  description = "AKS service CIDR."
  type        = string
  default     = "10.78.0.0/16"
}

variable "aks_dns_service_ip" {
  description = "AKS DNS service IP."
  type        = string
  default     = "10.78.0.10"
}

variable "aks_outbound_type" {
  description = "AKS outbound type."
  type        = string
  default     = "loadBalancer"
}

variable "aks_oidc_issuer_enabled" {
  description = "Enable AKS OIDC issuer."
  type        = bool
  default     = true
}

variable "aks_workload_identity_enabled" {
  description = "Enable AKS Workload Identity."
  type        = bool
  default     = true
}

variable "aks_enable_acr_pull_role_assignment" {
  description = "Assign AcrPull to the AKS kubelet identity."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to taggable resources in the production foundation environment."
  type        = map(string)
}