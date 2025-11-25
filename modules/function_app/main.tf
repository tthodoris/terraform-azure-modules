resource "azurerm_storage_account" "function" {
  count = var.storage_account_id == null ? 1 : 0

  name                     = var.storage_account_name != "" ? var.storage_account_name : "${var.name_prefix}${var.environment}funcsa${format("%02d", var.index + 1)}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.config.storage_account_tier
  account_replication_type = var.config.storage_account_replication_type
  tags                     = var.tags
}

resource "azurerm_app_service_plan" "function" {
  count = var.app_service_plan_id == null ? 1 : 0

  name                = "${var.name_prefix}-${var.environment}-func-asp-${format("%02d", var.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = var.config.app_service_plan_kind
  reserved            = var.config.app_service_plan_reserved

  sku {
    tier = var.config.app_service_plan_sku_tier
    size = var.config.app_service_plan_sku_size
  }

  tags = var.tags
}

resource "azurerm_function_app" "main" {
  name                       = var.resource_name != "" ? var.resource_name : "${var.name_prefix}-${var.environment}-func-${format("%02d", var.index + 1)}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  app_service_plan_id        = var.app_service_plan_id != null ? var.app_service_plan_id : azurerm_app_service_plan.function[0].id
  storage_account_name       = var.storage_account_id != null ? split("/", var.storage_account_id)[8] : azurerm_storage_account.function[0].name
  storage_account_access_key = var.storage_account_id != null ? null : azurerm_storage_account.function[0].primary_access_key
  version                    = var.config.function_app_version

  tags = var.tags
}

# VNet Integration (if subnet_id is provided)
resource "azurerm_app_service_virtual_network_swift_connection" "main" {
  count = var.subnet_id != null ? 1 : 0

  app_service_id = azurerm_function_app.main.id
  subnet_id      = var.subnet_id
}

