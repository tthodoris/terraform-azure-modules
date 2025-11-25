variable "resource_group_name" {
  description = "Primary resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "index" {
  description = "Module instance index"
  type        = number
}

variable "resource_name" {
  description = "Pre-generated resource name from naming convention"
  type        = string
  default     = ""
}

variable "recovery_vault_name" {
  description = "Pre-generated recovery services vault name from naming convention"
  type        = string
  default     = ""
}

variable "config" {
  description = "Configuration for VM backup"
  type = object({
    virtual_machine_index      = optional(number)
    recovery_vault_name        = optional(string)
    sku                       = optional(string)
    soft_delete_enabled        = optional(bool)
    backup_policy_name         = optional(string)
    timezone                  = optional(string)
    backup_frequency           = optional(string)
    backup_time               = optional(string)
    instant_restore_retention_days = optional(number)
    daily_retention_count     = optional(number)
    weekly_retention_count    = optional(number)
    monthly_retention_count   = optional(number)
    yearly_retention_count    = optional(number)
    weekly_retention_weekdays  = optional(list(string))
    monthly_retention_weeks    = optional(list(string))
    monthly_retention_weekdays = optional(list(string))
    yearly_retention_weeks     = optional(list(string))
    yearly_retention_weekdays  = optional(list(string))
    yearly_retention_months    = optional(list(string))
  })
}

variable "virtual_machine_id" {
  description = "Target VM ID"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

