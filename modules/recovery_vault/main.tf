resource "azurerm_recovery_services_vault" "main" {
  name                = "${var.name_prefix}-${var.environment}-rsv-${format("%02d", var.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.config.sku
  soft_delete_enabled = var.config.soft_delete_enabled

  tags = var.tags
}

