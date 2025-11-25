resource "azurerm_managed_disk" "main" {
  name                 = var.resource_name != "" ? var.resource_name : "${var.name_prefix}-${var.environment}-disk${format("%02d", var.index + 1)}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = var.config.storage_account_type
  create_option        = try(var.config.create_option, "Empty")
  disk_size_gb         = var.config.disk_size_gb

  # Optional attributes
  disk_encryption_set_id              = try(var.config.disk_encryption_set_id, null)
  disk_iops_read_write                = try(var.config.disk_iops_read_write, null)
  disk_mbps_read_write                = try(var.config.disk_mbps_read_write, null)
  disk_iops_read_only                 = try(var.config.disk_iops_read_only, null)
  disk_mbps_read_only                 = try(var.config.disk_mbps_read_only, null)
  max_shares                          = try(var.config.max_shares, null)
  network_access_policy               = try(var.config.network_access_policy, null)
  public_network_access_enabled       = try(var.config.public_network_access_enabled, false)
  secure_vm_disk_encryption_set_id     = try(var.config.secure_vm_disk_encryption_set_id, null)
  security_type                       = try(var.config.security_type, null)
  source_resource_id                  = try(var.config.source_resource_id, null)
  source_uri                          = try(var.config.source_uri, null)
  storage_account_id                  = try(var.config.storage_account_id, null)
  tier                                = try(var.config.tier, null)
  trusted_launch_enabled              = try(var.config.trusted_launch_enabled, false)
  zone                                = try(var.config.zone, null)

  tags = var.tags
}

