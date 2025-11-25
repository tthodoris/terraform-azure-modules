# Data source for existing DNS zone (when use_existing_zone is true)
data "azurerm_private_dns_zone" "existing" {
  count = var.config.use_existing_zone ? 1 : 0

  name                = coalesce(var.config.existing_zone_name, var.config.zone_name)
  resource_group_name = var.config.existing_zone_resource_group_name != null ? var.config.existing_zone_resource_group_name : var.resource_group_name
}

# Create new DNS zone (when use_existing_zone is false)
resource "azurerm_private_dns_zone" "main" {
  count = var.config.use_existing_zone ? 0 : 1

  name                = var.config.zone_name
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Outputs
locals {
  private_dns_zone_id       = var.config.use_existing_zone ? data.azurerm_private_dns_zone.existing[0].id : azurerm_private_dns_zone.main[0].id
  private_dns_zone_name     = var.config.use_existing_zone ? data.azurerm_private_dns_zone.existing[0].name : azurerm_private_dns_zone.main[0].name
  private_dns_zone_rg_name  = var.config.use_existing_zone ? data.azurerm_private_dns_zone.existing[0].resource_group_name : var.resource_group_name
}

