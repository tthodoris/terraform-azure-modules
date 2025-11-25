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
  description = "Subnet ID for the VPN Gateway (GatewaySubnet required)"
  type        = string
}

variable "config" {
  description = "Configuration object for VPN Gateway"
  type = object({
    gateway_type                = string
    vpn_type                    = string
    sku                         = string
    public_ip_allocation_method  = string
    public_ip_sku               = string
    vnet_index                  = optional(number)
    subnet_name                 = optional(string)
    subnet_id                   = optional(string)
  })
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

