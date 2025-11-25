data "azurerm_client_config" "current" {}

locals {
  recovery_vault_name = coalesce(try(var.config.recovery_vault_name, null), var.recovery_vault_name != "" ? var.recovery_vault_name : "${var.name_prefix}-${var.environment}-rsv-${format("%02d", var.index + 1)}")
  backup_policy_name  = coalesce(try(var.config.backup_policy_name, null), var.resource_name != "" ? "${var.resource_name}-policy" : "${var.name_prefix}-${var.environment}-vm-policy-${format("%02d", var.index + 1)}")
  sku                 = coalesce(try(var.config.sku, null), "Standard")
  soft_delete_enabled = coalesce(try(var.config.soft_delete_enabled, null), true)
  
  # Backup policy settings
  timezone                    = coalesce(try(var.config.timezone, null), "UTC")
  backup_frequency            = coalesce(try(var.config.backup_frequency, null), "Daily")
  backup_time                = coalesce(try(var.config.backup_time, null), "23:00")
  instant_restore_retention_days = coalesce(try(var.config.instant_restore_retention_days, null), 2)
  
  # Retention settings
  daily_retention_count   = coalesce(try(var.config.daily_retention_count, null), 7)
  weekly_retention_count  = coalesce(try(var.config.weekly_retention_count, null), 4)
  monthly_retention_count = coalesce(try(var.config.monthly_retention_count, null), 12)
  yearly_retention_count  = coalesce(try(var.config.yearly_retention_count, null), 1)
  
  weekly_retention_weekdays = length(coalesce(try(var.config.weekly_retention_weekdays, []), [])) > 0 ? coalesce(try(var.config.weekly_retention_weekdays, []), []) : ["Sunday"]
  monthly_retention_weeks    = length(coalesce(try(var.config.monthly_retention_weeks, []), [])) > 0 ? coalesce(try(var.config.monthly_retention_weeks, []), []) : ["First"]
  monthly_retention_weekdays = length(coalesce(try(var.config.monthly_retention_weekdays, []), [])) > 0 ? coalesce(try(var.config.monthly_retention_weekdays, []), []) : ["Sunday"]
  yearly_retention_weeks     = length(coalesce(try(var.config.yearly_retention_weeks, []), [])) > 0 ? coalesce(try(var.config.yearly_retention_weeks, []), []) : ["First"]
  yearly_retention_weekdays  = length(coalesce(try(var.config.yearly_retention_weekdays, []), [])) > 0 ? coalesce(try(var.config.yearly_retention_weekdays, []), []) : ["Sunday"]
  yearly_retention_months    = length(coalesce(try(var.config.yearly_retention_months, []), [])) > 0 ? coalesce(try(var.config.yearly_retention_months, []), []) : ["January"]
}

# Recovery Services Vault
resource "azurerm_recovery_services_vault" "this" {
  name                = local.recovery_vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = local.sku
  soft_delete_enabled = local.soft_delete_enabled

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Backup Policy for VM
resource "azurerm_backup_policy_vm" "this" {
  name                = local.backup_policy_name
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.this.name

  timezone = local.timezone

  backup {
    frequency = local.backup_frequency
    time      = local.backup_time
  }

  retention_daily {
    count = local.daily_retention_count
  }

  retention_weekly {
    count    = local.weekly_retention_count
    weekdays = local.weekly_retention_weekdays
  }

  retention_monthly {
    count    = local.monthly_retention_count
    weeks    = local.monthly_retention_weeks
    weekdays = local.monthly_retention_weekdays
  }

  retention_yearly {
    count    = local.yearly_retention_count
    weeks    = local.yearly_retention_weeks
    weekdays = local.yearly_retention_weekdays
    months   = local.yearly_retention_months
  }

  instant_restore_retention_days = local.instant_restore_retention_days

  depends_on = [azurerm_recovery_services_vault.this]
}

# Enable backup protection for the VM
resource "azurerm_backup_protected_vm" "this" {
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.this.name
  source_vm_id        = var.virtual_machine_id
  backup_policy_id   = azurerm_backup_policy_vm.this.id

  depends_on = [
    azurerm_recovery_services_vault.this,
    azurerm_backup_policy_vm.this
  ]
}

