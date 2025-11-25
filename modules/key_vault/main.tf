data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                = var.resource_name != "" ? substr(replace(lower(var.resource_name), "-", ""), 0, 24) : "${var.name_prefix}${var.environment}kv${format("%02d", var.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = var.config.sku_name

  enabled_for_deployment          = var.config.enabled_for_deployment
  enabled_for_template_deployment = var.config.enabled_for_template_deployment
  enabled_for_disk_encryption     = var.config.enabled_for_disk_encryption
  purge_protection_enabled        = var.config.purge_protection_enabled
  
  # Public network access control
  # If private endpoint is enabled, automatically disable public access
  # Otherwise, use explicit setting or default to true
  public_network_access_enabled = try(var.config.enable_private_endpoint, false) ? false : try(var.config.public_network_access_enabled, true)

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
      "List",
      "Create",
      "Delete",
      "Update",
    ]

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
    ]
  }

  tags = var.tags
}

