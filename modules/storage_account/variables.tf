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
  description = "Configuration object for the storage account"
  type = object({
    account_tier             = string
    account_replication_type = string
    account_kind             = string
    access_tier              = string
    large_file_share_enabled = optional(bool, false)  # Enable large file shares (up to 100 TiB per share)
    enable_private_endpoint  = optional(bool, false)
    private_endpoint_subnet_name = optional(string)  # Subnet name for private endpoint
    private_endpoint_vnet_index = optional(number)  # VNet index for private endpoint
  })
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

