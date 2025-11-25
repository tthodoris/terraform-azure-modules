resource "azurerm_storage_account" "main" {
  name                     = var.resource_name != "" ? var.resource_name : "${var.name_prefix}${var.environment}sa${format("%02d", var.index + 1)}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.config.account_tier
  account_replication_type = var.config.account_replication_type
  account_kind             = var.config.account_kind
  access_tier              = var.config.access_tier
  
  # Capacity options
  large_file_share_enabled = try(var.config.large_file_share_enabled, false)
  
  # Disable public access when private endpoint is enabled
  public_network_access_enabled = try(var.config.enable_private_endpoint, false) ? false : true
  allow_nested_items_to_be_public = try(var.config.enable_private_endpoint, false) ? false : true
  
  tags = var.tags
}

