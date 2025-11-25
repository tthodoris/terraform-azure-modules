resource "azurerm_public_ip" "lb" {
  count = var.config.public_ip_enabled ? 1 : 0

  name                = "${var.name_prefix}-${var.environment}-lb-pip-${format("%02d", var.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.config.public_ip_allocation_method
  sku                 = var.config.public_ip_sku

  tags = var.tags
}

resource "azurerm_lb" "main" {
  name                = "${var.name_prefix}-${var.environment}-lb-${format("%02d", var.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.config.sku

  frontend_ip_configuration {
    name                          = "frontend-ip"
    public_ip_address_id         = var.config.public_ip_enabled && length(azurerm_public_ip.lb) > 0 ? azurerm_public_ip.lb[0].id : null
    private_ip_address_allocation = var.config.public_ip_enabled ? "Dynamic" : "Static"
    private_ip_address           = var.config.public_ip_enabled ? null : var.config.private_ip_address
    subnet_id                    = var.config.public_ip_enabled ? null : var.subnet_id
  }

  tags = var.tags
}

