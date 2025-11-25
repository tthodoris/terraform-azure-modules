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
  description = "Pre-generated resource name from naming convention (for backup vault)"
  type        = string
  default     = ""
}

variable "storage_account_name" {
  description = "Pre-generated storage account name from naming convention"
  type        = string
  default     = ""
}

variable "config" {
  description = "Configuration for AKS backup"
  type = object({
    kubernetes_cluster_index         = optional(number)
    backup_extension_name            = optional(string)
    backup_extension_type            = optional(string)
    release_train                    = optional(string)
    storage_account_name             = optional(string)
    storage_container_name           = optional(string)
    snapshot_resource_group_name     = optional(string)
    snapshot_resource_group_location = optional(string)
    create_snapshot_resource_group   = optional(bool)
    backup_vault_name                = optional(string)
    datastore_type                   = optional(string)
    redundancy                       = optional(string)
    backup_policy_name               = optional(string)
    backup_repeating_time_intervals  = optional(list(string))
    default_retention_duration       = optional(string)
    default_retention_data_store_type = optional(string)
    backup_instance_name             = optional(string)
    trusted_access_binding_name      = optional(string)
    trusted_access_roles             = optional(list(string))
    volume_snapshot_enabled          = optional(bool)
    cluster_scoped_resources_enabled = optional(bool)
    included_namespaces              = optional(list(string))
    excluded_namespaces              = optional(list(string))
    included_resource_types          = optional(list(string))
    excluded_resource_types          = optional(list(string))
    label_selectors                  = optional(list(string))
  })
}

variable "kubernetes_cluster_id" {
  description = "Target AKS cluster ID"
  type        = string
}

variable "kubernetes_cluster_identity_principal_id" {
  description = "Principal ID of the AKS managed identity"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

