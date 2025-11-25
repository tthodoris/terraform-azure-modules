variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
}

variable "create_resource_group" {
  description = "Whether to create a new resource group or use an existing one"
  type        = bool
  default     = true
}

variable "location" {
  description = "Azure region for resources (required when creating resource group, optional when using existing)"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "modules_config_file" {
  description = "Path to the modules configuration JSON file"
  type        = string
  default     = "modules-config.json"
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "tf"
}

