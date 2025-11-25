resource "azurerm_mssql_server" "main" {
  name                         = var.resource_name != "" ? var.resource_name : "${var.name_prefix}-${var.environment}-sql-${format("%02d", var.index + 1)}"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = var.config.version
  administrator_login          = var.config.administrator_login
  administrator_login_password = var.config.administrator_login_password
  
  # Disable public network access when private endpoint is enabled
  public_network_access_enabled = try(var.config.enable_private_endpoint, false) ? false : true

  tags = var.tags
}

resource "azurerm_mssql_database" "main" {
  count = var.config.database_name != null ? 1 : 0

  name           = var.config.database_name != null ? var.config.database_name : "${var.name_prefix}${var.environment}db${format("%02d", var.index + 1)}"
  server_id      = azurerm_mssql_server.main.id
  collation      = var.config.database_collation
  license_type   = var.config.database_license_type
  max_size_gb    = var.config.database_max_size_gb
  sku_name       = var.config.database_sku_name
  zone_redundant = var.config.database_zone_redundant
  # Note: backup_storage_redundancy is not supported in current azurerm provider version
  # This may need to be configured manually via Azure Portal or requires a newer provider version

  tags = var.tags
}

# VNet Rule (if subnet_id is provided)
resource "azurerm_mssql_virtual_network_rule" "main" {
  count = var.subnet_id != null ? 1 : 0

  name      = "${var.name_prefix}-${var.environment}-vnet-rule-${format("%02d", var.index + 1)}"
  server_id = azurerm_mssql_server.main.id
  subnet_id = var.subnet_id
}

