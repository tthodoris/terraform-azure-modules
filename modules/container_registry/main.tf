resource "azurerm_container_registry" "main" {
  name                = var.resource_name != "" ? var.resource_name : "${var.name_prefix}${var.environment}acr${format("%02d", var.index + 1)}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.config.sku
  admin_enabled       = var.config.admin_enabled
  
  # Public network access control
  # If private endpoint is enabled, automatically disable public access
  # Otherwise, use explicit setting or default to true
  public_network_access_enabled = try(var.config.enable_private_endpoint, false) ? false : try(var.config.public_network_access_enabled, true)
  
  tags = var.tags

  dynamic "georeplications" {
    for_each = try(var.config.georeplication_locations, [])
    content {
      location = georeplications.value
    }
  }
}

