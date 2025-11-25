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

variable "private_dns_zone_name" {
  description = "Name of the Private DNS Zone"
  type        = string
}

variable "private_dns_zone_resource_group_name" {
  description = "Resource group name where the Private DNS Zone exists (required for linking to existing zones in different resource groups)"
  type        = string
  default     = null
}

variable "virtual_network_id" {
  description = "ID of the Virtual Network to link"
  type        = string
}

variable "config" {
  description = "Configuration object for Private DNS Zone Link"
  type = object({
    registration_enabled = bool
    vnet_index          = optional(number)
    dns_zone_index      = optional(number)
  })
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

