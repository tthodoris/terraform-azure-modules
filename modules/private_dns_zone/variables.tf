variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region (not used for DNS zones but kept for consistency)"
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
  description = "Configuration object for Private DNS Zone"
  type = object({
    zone_name                      = string
    use_existing_zone             = optional(bool, false)
    existing_zone_resource_group_name = optional(string)
    existing_zone_name            = optional(string)
  })
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

