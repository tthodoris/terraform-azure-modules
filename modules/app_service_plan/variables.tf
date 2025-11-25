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
  description = "Configuration object for the app service plan"
  type = object({
    kind     = string
    reserved = bool
    sku_tier = string
    sku_size = string
  })
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

