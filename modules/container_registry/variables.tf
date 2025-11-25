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

variable "resource_name" {
  description = "Pre-generated resource name from naming convention"
  type        = string
  default     = ""
}

variable "config" {
  description = "Configuration object for the container registry"
  type = object({
    sku                      = string
    admin_enabled            = bool
    georeplication_locations = optional(list(string), [])  # Empty list for Basic SKU (georeplication not supported)
    public_network_access_enabled = optional(bool, true)  # Enable/disable public network access (default: true)
    enable_private_endpoint  = optional(bool, false)  # Enable private endpoint (automatically disables public access)
    private_endpoint_subnet_name = optional(string)  # Subnet name for private endpoint
    private_endpoint_vnet_index = optional(number)  # VNet index for private endpoint
  })
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

