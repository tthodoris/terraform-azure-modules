resource "azurerm_log_analytics_workspace" "main" {
  name                = var.resource_name != "" ? var.resource_name : "${var.name_prefix}-${var.environment}-law-${format("%02d", var.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.config.sku
  retention_in_days   = var.config.retention_in_days
  tags                = var.tags
}

