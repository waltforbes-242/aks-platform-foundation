variable "resource_group_name" {
  description = "Name of the resource group containing the monitoring resources."
  type        = string

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name must not be empty."
  }
}

variable "location" {
  description = "Azure region for the monitoring resources."
  type        = string

  validation {
    condition     = trimspace(var.location) != ""
    error_message = "location must not be empty."
  }
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace."
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
  description = "Retention in days for the Log Analytics workspace."
  type        = number
  default     = 30

  validation {
    condition     = var.log_analytics_retention_in_days >= 30 && var.log_analytics_retention_in_days <= 730
    error_message = "log_analytics_retention_in_days must be between 30 and 730."
  }
}

variable "monitor_workspace_name" {
  description = "Name of the Azure Monitor workspace used for managed Prometheus."
  type        = string

  validation {
    condition     = trimspace(var.monitor_workspace_name) != ""
    error_message = "monitor_workspace_name must not be empty."
  }
}

variable "tags" {
  description = "Tags to apply to monitoring resources."
  type        = map(string)
  default     = {}
}