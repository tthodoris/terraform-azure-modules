output "backup_vault_id" {
  description = "ID of the backup vault"
  value       = azurerm_data_protection_backup_vault.this.id
}

output "backup_policy_id" {
  description = "ID of the AKS backup policy"
  value       = azurerm_data_protection_backup_policy_kubernetes_cluster.this.id
}

output "backup_instance_id" {
  description = "ID of the AKS backup instance"
  value       = azurerm_data_protection_backup_instance_kubernetes_cluster.this.id
}

output "snapshot_resource_group_name" {
  description = "Snapshot resource group used for AKS backups"
  value       = local.snapshot_rg_name_used
}

output "storage_account_name" {
  description = "Storage account used by the backup extension"
  value       = azurerm_storage_account.backup.name
}

