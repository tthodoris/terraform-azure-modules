resource "azurerm_eventhub_namespace" "main" {
  name                = "${var.name_prefix}${var.environment}ehns${format("%02d", var.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.config.sku
  capacity            = var.config.capacity
  auto_inflate_enabled = var.config.auto_inflate_enabled
  maximum_throughput_units = var.config.maximum_throughput_units
  
  # Disable public network access when private endpoint is enabled
  public_network_access_enabled = try(var.config.enable_private_endpoint, false) ? false : true

  tags = var.tags
}

resource "azurerm_eventhub" "main" {
  for_each = {
    for hub in var.config.event_hubs : hub.name => hub
  }

  name                = each.value.name
  namespace_name      = azurerm_eventhub_namespace.main.name
  resource_group_name = var.resource_group_name
  partition_count     = each.value.partition_count
  message_retention   = each.value.message_retention
}

