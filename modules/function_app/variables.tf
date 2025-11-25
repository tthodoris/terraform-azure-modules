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

variable "storage_account_name" {
  description = "Pre-generated storage account name from naming convention"
  type        = string
  default     = ""
}

variable "app_service_plan_id" {
  description = "ID of the app service plan (optional, will create one if not provided)"
  type        = string
  default     = null
}

variable "storage_account_id" {
  description = "ID of the storage account (optional, will create one if not provided)"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Subnet ID for VNet integration (optional)"
  type        = string
  default     = null
}

variable "config" {
  description = "Configuration object for the function app"
  type = object({
    app_service_plan_kind            = string
    app_service_plan_reserved        = bool
    app_service_plan_sku_tier       = string
    app_service_plan_sku_size       = string
    function_app_version             = string
    storage_account_tier            = string
    storage_account_replication_type = string
    app_service_plan_index          = optional(number)
    storage_account_index           = optional(number)
    vnet_index                      = optional(number)
    subnet_name                     = optional(string)
    subnet_id                       = optional(string)
  })
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

