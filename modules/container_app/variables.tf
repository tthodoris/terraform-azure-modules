variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "index" {
  description = "Index for this instance"
  type        = number
}

variable "subnet_id" {
  description = "Subnet ID for the Container App Environment (optional)"
  type        = string
  default     = null
}

variable "config" {
  description = "Configuration object for Container App"
  type = object({
    revision_mode              = string
    min_replicas               = number
    max_replicas               = number
    container_name             = string
    container_image            = string
    container_cpu              = number
    container_memory           = string
    environment_variables      = map(string)
    external_ingress_enabled    = bool
    target_port                = number
    transport                  = string
    log_analytics_workspace_id = optional(string)
    vnet_index                = optional(number)
    subnet_name               = optional(string)
    subnet_id                 = optional(string)
    enable_private_endpoint   = optional(bool, false)
    private_endpoint_subnet_name = optional(string)  # Subnet name for private endpoint
    private_endpoint_vnet_index = optional(number)  # VNet index for private endpoint
  })
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

