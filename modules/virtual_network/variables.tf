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
  description = "Configuration object for the virtual network"
  type = object({
    address_space = list(string)
    subnets = list(object({
      name           = string
      address_prefix = string
      delegation     = optional(string)  # e.g., "Microsoft.DBforMySQL/flexibleServers"
    }))
  })
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

