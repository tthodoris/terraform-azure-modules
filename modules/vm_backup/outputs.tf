output "recovery_vault_id" {
  description = "ID of the Recovery Services Vault"
  value       = azurerm_recovery_services_vault.this.id
}

output "recovery_vault_name" {
  description = "Name of the Recovery Services Vault"
  value       = azurerm_recovery_services_vault.this.name
}

output "backup_policy_id" {
  description = "ID of the VM backup policy"
  value       = azurerm_backup_policy_vm.this.id
}

output "backup_protected_vm_id" {
  description = "ID of the backup protected VM"
  value       = azurerm_backup_protected_vm.this.id
}

