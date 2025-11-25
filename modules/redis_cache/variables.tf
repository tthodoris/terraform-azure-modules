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
  description = "Subnet ID for VNet integration (optional, required for Premium SKU)"
  type        = string
  default     = null
}

variable "config" {
  description = "Configuration object for Redis Cache"
  type = object({
    capacity              = number
    family                = string
    sku_name              = string
    enable_non_ssl_port   = bool
    minimum_tls_version   = string
    maxmemory_reserved    = optional(number)
    maxmemory_delta       = optional(number)
    maxmemory_policy      = optional(string)
    enable_private_endpoint = optional(bool, false)
    private_endpoint_subnet_name = optional(string)  # Subnet name for private endpoint
    private_endpoint_vnet_index  = optional(number)  # VNet index for private endpoint
    vnet_index            = optional(number)
    subnet_name           = optional(string)
  })
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

