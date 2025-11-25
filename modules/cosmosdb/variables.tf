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

variable "subnet_ids" {
  description = "List of subnet IDs for VNet filtering (optional)"
  type        = list(string)
  default     = []
}

variable "config" {
  description = "Configuration object for Cosmos DB"
  type = object({
    offer_type                      = string
    kind                            = string
    consistency_level               = string
    max_interval_in_seconds         = optional(number)
    max_staleness_prefix            = optional(number)
    capabilities                    = list(string)
    is_virtual_network_filter_enabled = bool
    enable_automatic_failover       = optional(bool)  # Deprecated in azurerm v4.0, configured via capabilities
    enable_multiple_write_locations = optional(bool)  # Deprecated in azurerm v4.0, configured via capabilities
    vnet_indexes                    = optional(list(number))
    subnet_names                    = optional(list(string))
    subnet_ids                      = optional(list(string))
    enable_private_endpoint         = optional(bool, false)
    private_endpoint_subnet_name    = optional(string)  # Subnet name for private endpoint
    private_endpoint_vnet_index     = optional(number)  # VNet index for private endpoint
    databases = list(object({
      name      = string
      throughput = number
    }))
    containers = list(object({
      name             = string
      database_name    = string
      partition_key_path = string
      throughput       = number
      indexing_mode    = string
    }))
  })
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

