resource "azurerm_postgresql_flexible_server" "main" {
  name                   = var.resource_name != "" ? var.resource_name : "${var.name_prefix}-${var.environment}-psql-${format("%02d", var.index + 1)}"
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = var.config.version
  administrator_login    = var.config.administrator_login
  administrator_password = var.config.administrator_password
  zone                   = var.config.zone
  backup_retention_days  = var.config.backup_retention_days
  geo_redundant_backup_enabled = var.config.geo_redundant_backup_enabled

  sku_name   = var.config.sku_name
  storage_mb = var.config.storage_mb

  dynamic "maintenance_window" {
    for_each = var.config.maintenance_window != null ? [1] : []
    content {
      day_of_week  = var.config.maintenance_window.day_of_week
      start_hour   = var.config.maintenance_window.start_hour
      start_minute = var.config.maintenance_window.start_minute
    }
  }

  delegated_subnet_id = var.subnet_id
  private_dns_zone_id = var.private_dns_zone_id != null ? var.private_dns_zone_id : var.config.private_dns_zone_id
  
  # When using VNet integration, public network access must be disabled
  public_network_access_enabled = var.subnet_id != null ? false : true

  tags = var.tags
}

resource "azurerm_postgresql_flexible_server_database" "main" {
  for_each = {
    for db in var.config.databases : db.name => db
  }

  name      = each.value.name
  server_id = azurerm_postgresql_flexible_server.main.id
  charset   = each.value.charset
  collation = each.value.collation
}

