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

variable "subnet_id" {
  description = "Subnet ID for VNet integration (optional)"
  type        = string
  default     = null
}

variable "private_dns_zone_id" {
  description = "Private DNS Zone ID for VNet integration (optional, required when using subnet_id)"
  type        = string
  default     = null
}

variable "config" {
  description = "Configuration object for the PostgreSQL flexible server"
  type = object({
    version                      = string
    administrator_login          = string
    administrator_password       = string
    zone                         = optional(number)
    backup_retention_days        = number
    geo_redundant_backup_enabled = bool
    sku_name                     = string
    storage_mb                   = number
    maintenance_window = optional(object({
      day_of_week  = number
      start_hour   = number
      start_minute = number
    }))
    private_dns_zone_id = optional(string)
    dns_zone_index      = optional(number)  # Index to reference private_dns_zone module (alternative to private_dns_zone_id)
    vnet_index          = optional(number)
    subnet_name         = optional(string)
    subnet_id           = optional(string)
    databases = list(object({
      name      = string
      charset   = string
      collation = string
    }))
  })
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

