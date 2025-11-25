resource "azurerm_public_ip" "firewall" {
  count = var.config.public_ip_enabled ? 1 : 0

  name                = "${var.name_prefix}-${var.environment}-fw-pip-${format("%02d", var.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.config.public_ip_allocation_method
  sku                 = var.config.public_ip_sku

  tags = var.tags
}

resource "azurerm_firewall" "main" {
  name                = "${var.name_prefix}-${var.environment}-fw-${format("%02d", var.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = var.config.sku_name
  sku_tier            = var.config.sku_tier

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.subnet_id
    public_ip_address_id = var.config.public_ip_enabled && length(azurerm_public_ip.firewall) > 0 ? azurerm_public_ip.firewall[0].id : null
  }

  tags = var.tags
}

