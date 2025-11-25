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

variable "app_service_plan_id" {
  description = "ID of the app service plan (optional, will create one if not provided)"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Subnet ID for VNet integration (optional)"
  type        = string
  default     = null
}

variable "config" {
  description = "Configuration object for the app service"
  type = object({
    linux_fx_version        = string
    always_on               = bool
    http2_enabled           = bool
    min_tls_version         = string
    app_service_plan_index   = optional(number)
    vnet_index              = optional(number)
    subnet_name             = optional(string)
    subnet_id               = optional(string)
  })
}

variable "app_service_plan_config" {
  description = "Configuration object for the app service plan (used when creating one)"
  type = object({
    kind     = string
    reserved = bool
    sku_tier = string
    sku_size = string
  })
  default = {
    kind     = "Linux"
    reserved = true
    sku_tier = "Basic"
    sku_size = "B1"
  }
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

