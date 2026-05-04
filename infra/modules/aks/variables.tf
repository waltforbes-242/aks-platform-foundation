variable "cluster_name" {
  description = "Name of the AKS cluster."
  type        = string

  validation {
    condition     = trimspace(var.cluster_name) != ""
    error_message = "cluster_name must not be empty."
  }
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster."
  type        = string

  validation {
    condition     = trimspace(var.dns_prefix) != ""
    error_message = "dns_prefix must not be empty."
  }
}

variable "location" {
  description = "Azure region for the AKS cluster."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing the AKS cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "AKS Kubernetes version. Null allows Azure to choose the default supported version."
  type        = string
  default     = null
}

variable "sku_tier" {
  description = "AKS SKU tier."
  type        = string
  default     = "Free"

  validation {
    condition     = contains(["Free", "Standard", "Premium"], var.sku_tier)
    error_message = "sku_tier must be Free, Standard, or Premium."
  }
}

variable "system_node_pool" {
  description = "System node pool configuration."
  type = object({
    name            = string
    vm_size         = string
    subnet_id       = string
    node_count      = number
    min_count       = number
    max_count       = number
    os_disk_size_gb = number
    os_disk_type    = string
  })

  validation {
    condition     = var.system_node_pool.min_count <= var.system_node_pool.node_count && var.system_node_pool.node_count <= var.system_node_pool.max_count
    error_message = "system_node_pool.node_count must be between min_count and max_count."
  }
}

variable "user_node_pool" {
  description = "User node pool configuration."
  type = object({
    name            = string
    vm_size         = string
    subnet_id       = string
    node_count      = number
    min_count       = number
    max_count       = number
    os_disk_size_gb = number
    os_disk_type    = string
  })

  validation {
    condition     = var.user_node_pool.min_count <= var.user_node_pool.node_count && var.user_node_pool.node_count <= var.user_node_pool.max_count
    error_message = "user_node_pool.node_count must be between min_count and max_count."
  }
}

variable "service_cidr" {
  description = "Kubernetes service CIDR."
  type        = string
  default     = "10.78.0.0/16"
}

variable "dns_service_ip" {
  description = "Kubernetes DNS service IP."
  type        = string
  default     = "10.78.0.10"
}

variable "outbound_type" {
  description = "AKS outbound type."
  type        = string
  default     = "loadBalancer"

  validation {
    condition     = contains(["loadBalancer", "managedNATGateway", "userAssignedNATGateway", "userDefinedRouting"], var.outbound_type)
    error_message = "outbound_type must be a supported AKS outbound type."
  }
}

variable "oidc_issuer_enabled" {
  description = "Enable OIDC issuer for AKS."
  type        = bool
  default     = true
}

variable "workload_identity_enabled" {
  description = "Enable Microsoft Entra Workload Identity."
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace."
  type        = string
}

variable "azure_monitor_workspace_id" {
  description = "Resource ID of the Azure Monitor workspace for managed Prometheus."
  type        = string
}

variable "acr_id" {
  description = "Resource ID of the Azure Container Registry."
  type        = string
}

variable "enable_acr_pull_role_assignment" {
  description = "Whether to assign AcrPull to the AKS kubelet identity."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to AKS resources."
  type        = map(string)
  default     = {}
}