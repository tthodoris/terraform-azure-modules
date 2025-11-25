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
  description = "Subnet ID for the private endpoint (required)"
  type        = string
}

variable "private_dns_zone_ids" {
  description = "List of Private DNS Zone IDs (optional, can be auto-resolved from config or module references)"
  type        = list(string)
  default     = []
}

variable "config" {
  description = "Configuration object for Private Endpoint"
  type = object({
    target_resource_id     = string
    is_manual_connection   = bool
    subresource_names      = list(string)
    private_dns_zone_ids   = optional(list(string))
    dns_zone_indexes       = optional(list(number))  # Indexes to reference private_dns_zone modules
    vnet_index             = optional(number)
    subnet_name            = optional(string)
    subnet_id              = optional(string)
  })
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

