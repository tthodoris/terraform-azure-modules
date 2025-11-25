resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  name                  = "${var.name_prefix}-${var.environment}-dns-link-${format("%02d", var.index + 1)}"
  # Use the DNS zone's resource group if provided (for existing zones in different RGs)
  # Otherwise use the deployment resource group (for zones created in this deployment)
  resource_group_name   = coalesce(var.private_dns_zone_resource_group_name, var.resource_group_name)
  private_dns_zone_name = var.private_dns_zone_name
  virtual_network_id    = var.virtual_network_id
  registration_enabled   = var.config.registration_enabled

  tags = var.tags
}

