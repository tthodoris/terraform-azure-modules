resource "azurerm_redis_cache" "main" {
  name                = "${var.name_prefix}${var.environment}redis${format("%02d", var.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  capacity            = var.config.capacity
  family              = var.config.family
  sku_name            = var.config.sku_name
  non_ssl_port_enabled = var.config.enable_non_ssl_port
  minimum_tls_version = var.config.minimum_tls_version

  redis_configuration {
    maxmemory_reserved = var.config.maxmemory_reserved
    maxmemory_delta    = var.config.maxmemory_delta
    maxmemory_policy   = var.config.maxmemory_policy
  }

  subnet_id = var.subnet_id

  # Disable public network access when private endpoint is enabled
  public_network_access_enabled = try(var.config.enable_private_endpoint, false) ? false : true

  tags = var.tags
}

