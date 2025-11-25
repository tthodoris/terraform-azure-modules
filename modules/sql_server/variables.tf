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
  description = "Subnet ID for VNet rule (optional)"
  type        = string
  default     = null
}

variable "config" {
  description = "Configuration object for the SQL server"
  type = object({
    version                      = string
    administrator_login          = string
    administrator_login_password = string
    database_name                = optional(string)
    database_collation           = string
    database_license_type        = string
    database_max_size_gb         = number
    database_sku_name            = string
    database_zone_redundant      = bool
    # Note: backup_storage_redundancy is not supported in current azurerm provider version
    # This may need to be configured manually via Azure Portal or requires a newer provider version
    vnet_index                   = optional(number)
    subnet_name                  = optional(string)
    subnet_id                    = optional(string)
    enable_private_endpoint      = optional(bool, false)
    private_endpoint_subnet_name = optional(string)  # Subnet name for private endpoint
    private_endpoint_vnet_index  = optional(number)  # VNet index for private endpoint
  })
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

