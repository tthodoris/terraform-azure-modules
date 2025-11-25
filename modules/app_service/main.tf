resource "azurerm_app_service" "main" {
  name                = "${var.name_prefix}-${var.environment}-app-${format("%02d", var.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = var.app_service_plan_id != null ? var.app_service_plan_id : azurerm_app_service_plan.main[0].id

  site_config {
    linux_fx_version = var.config.linux_fx_version
    always_on        = var.config.always_on
    http2_enabled     = var.config.http2_enabled
    min_tls_version   = var.config.min_tls_version
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
  }

  tags = var.tags
}

# VNet Integration (if subnet_id is provided)
resource "azurerm_app_service_virtual_network_swift_connection" "main" {
  count = var.subnet_id != null ? 1 : 0

  app_service_id = azurerm_app_service.main.id
  subnet_id     = var.subnet_id
}

resource "azurerm_app_service_plan" "main" {
  count = var.app_service_plan_id == null ? 1 : 0

  name                = "${var.name_prefix}-${var.environment}-asp-${format("%02d", var.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = var.app_service_plan_config.kind
  reserved            = var.app_service_plan_config.reserved

  sku {
    tier = var.app_service_plan_config.sku_tier
    size = var.app_service_plan_config.sku_size
  }

  tags = var.tags
}

