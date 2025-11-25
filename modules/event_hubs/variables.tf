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

variable "config" {
  description = "Configuration object for Event Hubs"
  type = object({
    sku                     = string
    capacity                = number
    auto_inflate_enabled    = bool
    maximum_throughput_units = optional(number)
    enable_private_endpoint  = optional(bool, false)
    private_endpoint_subnet_name = optional(string)  # Subnet name for private endpoint
    private_endpoint_vnet_index = optional(number)  # VNet index for private endpoint
    event_hubs = list(object({
      name              = string
      partition_count   = number
      message_retention = number
    }))
  })
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

