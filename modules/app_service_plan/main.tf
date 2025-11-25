resource "azurerm_app_service_plan" "main" {
  name                = "${var.name_prefix}-${var.environment}-asp-${format("%02d", var.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = var.config.kind
  reserved            = var.config.reserved

  sku {
    tier = var.config.sku_tier
    size = var.config.sku_size
  }

  tags = var.tags
}

