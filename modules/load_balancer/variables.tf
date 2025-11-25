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

variable "subnet_id" {
  description = "Subnet ID for internal load balancer (optional)"
  type        = string
  default     = null
}

variable "config" {
  description = "Configuration object for Load Balancer"
  type = object({
    sku                        = string
    public_ip_enabled          = bool
    public_ip_allocation_method = string
    public_ip_sku              = string
    private_ip_address         = optional(string)
    vnet_index                 = optional(number)
    subnet_name                = optional(string)
    subnet_id                  = optional(string)
  })
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

