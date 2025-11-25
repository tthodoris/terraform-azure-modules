data "azurerm_client_config" "current" {}

locals {
  backup_extension_name  = coalesce(try(var.config.backup_extension_name, null), "azure-aks-backup")
  backup_extension_type  = coalesce(try(var.config.backup_extension_type, null), "microsoft.dataprotection.kubernetes")
  backup_release_train   = coalesce(try(var.config.release_train, null), "stable")
  backup_vault_name      = coalesce(try(var.config.backup_vault_name, null), var.resource_name != "" ? var.resource_name : "${var.name_prefix}-${var.environment}-aks-backup-${format("%02d", var.index + 1)}")
  backup_policy_name     = coalesce(try(var.config.backup_policy_name, null), var.resource_name != "" ? "${var.resource_name}-policy" : "${var.name_prefix}-${var.environment}-aks-policy-${format("%02d", var.index + 1)}")
  backup_instance_name   = coalesce(try(var.config.backup_instance_name, null), var.resource_name != "" ? "${var.resource_name}-instance" : "${var.name_prefix}-${var.environment}-aks-instance-${format("%02d", var.index + 1)}")
  snapshot_rg_name       = coalesce(try(var.config.snapshot_resource_group_name, null), "${var.name_prefix}-${var.environment}-aks-snap-${format("%02d", var.index + 1)}")
  snapshot_rg_location_requested = coalesce(try(var.config.snapshot_resource_group_location, null), var.location)
  create_snapshot_rg     = coalesce(try(var.config.create_snapshot_resource_group, null), true)
  datastore_type         = coalesce(try(var.config.datastore_type, null), "OperationalStore")
  redundancy             = coalesce(try(var.config.redundancy, null), "LocallyRedundant")
  retention_duration     = coalesce(try(var.config.default_retention_duration, null), "P7D")
  retention_data_store   = coalesce(try(var.config.default_retention_data_store_type, null), "OperationalStore")
  backup_intervals       = try(var.config.backup_repeating_time_intervals, ["R/2024-01-01T00:00:00Z/PT24H"])
  container_name         = lower(coalesce(try(var.config.storage_container_name, null), "aksbackup"))
  storage_account_name_base = var.storage_account_name != "" ? var.storage_account_name : lower(trimspace("${var.name_prefix}${var.environment}aksbk${format("%02d", var.index + 1)}"))
  storage_account_name_processed = substr(
    replace(
      replace(
        replace(
          replace(local.storage_account_name_base, "-", ""),
          "_",
          ""
        ),
        ".",
        ""
      ),
      " ",
      ""
    ),
    0,
    24
  )
  storage_account_name_override = try(var.config.storage_account_name, null)
}

locals {
  effective_storage_account_name = coalesce(local.storage_account_name_override, local.storage_account_name_processed)
}

resource "azurerm_resource_group" "snapshot" {
  count    = local.create_snapshot_rg ? 1 : 0
  name     = local.snapshot_rg_name
  location = local.snapshot_rg_location_requested
  tags     = var.tags
}

data "azurerm_resource_group" "snapshot" {
  count = local.create_snapshot_rg ? 0 : 1
  name  = local.snapshot_rg_name
}

locals {
  snapshot_rg_id        = local.create_snapshot_rg ? azurerm_resource_group.snapshot[0].id : data.azurerm_resource_group.snapshot[0].id
  snapshot_rg_location  = local.create_snapshot_rg ? azurerm_resource_group.snapshot[0].location : data.azurerm_resource_group.snapshot[0].location
  snapshot_rg_name_used = local.snapshot_rg_name
}

resource "azurerm_data_protection_backup_vault" "this" {
  name                = local.backup_vault_name
  resource_group_name = var.resource_group_name
  location            = var.location
  datastore_type      = local.datastore_type
  redundancy          = local.redundancy

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_data_protection_backup_policy_kubernetes_cluster" "this" {
  name                = local.backup_policy_name
  resource_group_name = var.resource_group_name
  vault_name          = azurerm_data_protection_backup_vault.this.name

  backup_repeating_time_intervals = local.backup_intervals

  default_retention_rule {
    life_cycle {
      duration        = local.retention_duration
      data_store_type = local.retention_data_store
    }
  }

  depends_on = [azurerm_data_protection_backup_vault.this]
}

resource "azurerm_kubernetes_cluster_trusted_access_role_binding" "backup" {
  kubernetes_cluster_id = var.kubernetes_cluster_id
  name                  = coalesce(try(var.config.trusted_access_binding_name, null), "backuptrustedaccess-${format("%02d", var.index + 1)}")
  roles                 = try(var.config.trusted_access_roles, ["Microsoft.DataProtection/backupVaults/backup-operator"])
  source_resource_id    = azurerm_data_protection_backup_vault.this.id

  depends_on = [
    azurerm_data_protection_backup_vault.this
  ]
}

resource "azurerm_storage_account" "backup" {
  name                     = local.effective_storage_account_name
  resource_group_name      = local.snapshot_rg_name_used
  location                 = local.snapshot_rg_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_nested_items_to_be_public = false
  min_tls_version                = "TLS1_2"

  tags = var.tags

  depends_on = [azurerm_kubernetes_cluster_trusted_access_role_binding.backup]
}

resource "azurerm_storage_container" "backup" {
  name                  = local.container_name
  storage_account_name  = azurerm_storage_account.backup.name
  container_access_type = "private"

  depends_on = [azurerm_storage_account.backup]
}

resource "azurerm_kubernetes_cluster_extension" "backup" {
  name       = local.backup_extension_name
  cluster_id = var.kubernetes_cluster_id

  extension_type = local.backup_extension_type
  release_train  = local.backup_release_train

  configuration_settings = {
    "configuration.backupStorageLocation.bucket"                  = azurerm_storage_container.backup.name
    "configuration.backupStorageLocation.config.storageAccount"   = azurerm_storage_account.backup.name
    "configuration.backupStorageLocation.config.resourceGroup"    = local.snapshot_rg_name_used
    "configuration.backupStorageLocation.config.subscriptionId"   = data.azurerm_client_config.current.subscription_id
    "credentials.tenantId"                                       = data.azurerm_client_config.current.tenant_id
    "configuration.backupStorageLocation.config.useAAD"           = true
    "configuration.backupStorageLocation.config.storageAccountURI" = azurerm_storage_account.backup.primary_blob_endpoint
  }

  depends_on = [azurerm_storage_container.backup]
}

resource "azurerm_role_assignment" "extension_storage" {
  scope                = azurerm_storage_account.backup.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_kubernetes_cluster_extension.backup.aks_assigned_identity[0].principal_id

  depends_on = [azurerm_kubernetes_cluster_extension.backup]
}

resource "azurerm_role_assignment" "vault_read_cluster" {
  scope                = var.kubernetes_cluster_id
  role_definition_name = "Reader"
  principal_id         = azurerm_data_protection_backup_vault.this.identity[0].principal_id

  depends_on = [
    azurerm_data_protection_backup_vault.this
  ]
}

resource "azurerm_role_assignment" "vault_read_snapshot_rg" {
  scope                = local.snapshot_rg_id
  role_definition_name = "Reader"
  principal_id         = azurerm_data_protection_backup_vault.this.identity[0].principal_id

  depends_on = [
    azurerm_data_protection_backup_vault.this
  ]
}

resource "azurerm_role_assignment" "cluster_contributor_snapshot_rg" {
  scope                = local.snapshot_rg_id
  role_definition_name = "Contributor"
  principal_id         = var.kubernetes_cluster_identity_principal_id

  depends_on = [
    azurerm_data_protection_backup_vault.this
  ]
}

resource "azurerm_data_protection_backup_instance_kubernetes_cluster" "this" {
  name                         = local.backup_instance_name
  location                     = local.snapshot_rg_location
  vault_id                     = azurerm_data_protection_backup_vault.this.id
  kubernetes_cluster_id        = var.kubernetes_cluster_id
  snapshot_resource_group_name = local.snapshot_rg_name_used
  backup_policy_id             = azurerm_data_protection_backup_policy_kubernetes_cluster.this.id

  backup_datasource_parameters {
    excluded_namespaces              = try(var.config.excluded_namespaces, [])
    excluded_resource_types          = try(var.config.excluded_resource_types, [])
    cluster_scoped_resources_enabled = try(var.config.cluster_scoped_resources_enabled, true)
    included_namespaces              = try(var.config.included_namespaces, [])
    included_resource_types          = try(var.config.included_resource_types, [])
    label_selectors                  = try(var.config.label_selectors, [])
    volume_snapshot_enabled          = try(var.config.volume_snapshot_enabled, true)
  }

  depends_on = [
    azurerm_data_protection_backup_vault.this,
    azurerm_data_protection_backup_policy_kubernetes_cluster.this,
    azurerm_role_assignment.extension_storage,
    azurerm_role_assignment.vault_read_cluster,
    azurerm_role_assignment.vault_read_snapshot_rg,
    azurerm_role_assignment.cluster_contributor_snapshot_rg
  ]
}

