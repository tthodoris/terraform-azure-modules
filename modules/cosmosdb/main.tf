resource "azurerm_cosmosdb_account" "main" {
  name                = "${var.name_prefix}${var.environment}cosmos${format("%02d", var.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = var.config.offer_type
  kind                = var.config.kind

  consistency_policy {
    consistency_level       = var.config.consistency_level
    max_interval_in_seconds = try(var.config.max_interval_in_seconds, null)
    max_staleness_prefix    = try(var.config.max_staleness_prefix, null)
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  dynamic "capabilities" {
    for_each = var.config.capabilities
    content {
      name = capabilities.value
    }
  }

  is_virtual_network_filter_enabled = var.config.is_virtual_network_filter_enabled && length(var.subnet_ids) > 0

  dynamic "virtual_network_rule" {
    for_each = var.subnet_ids
    content {
      id = virtual_network_rule.value
    }
  }

  # Disable public network access when private endpoint is enabled
  public_network_access_enabled = try(var.config.enable_private_endpoint, false) ? false : true
  
  # Note: enable_automatic_failover and enable_multiple_write_locations are configured via capabilities in azurerm v4.0

  tags = var.tags
}

resource "azurerm_cosmosdb_sql_database" "main" {
  for_each = {
    for db in var.config.databases : db.name => db
  }

  name                = each.value.name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  throughput          = each.value.throughput
}

resource "azurerm_cosmosdb_sql_container" "main" {
  for_each = {
    for container in var.config.containers : "${container.database_name}.${container.name}" => container
  }

  name                = each.value.name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  database_name       = each.value.database_name
  partition_key_paths = [each.value.partition_key_path]
  throughput          = each.value.throughput

  indexing_policy {
    indexing_mode = each.value.indexing_mode
  }
}

