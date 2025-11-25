resource "azurerm_public_ip" "main" {
  name                = var.resource_name != "" ? var.resource_name : "${var.name_prefix}-${var.environment}-pip-${format("%02d", var.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.config.allocation_method
  sku                 = var.config.sku
  domain_name_label   = var.config.domain_name_label
  reverse_fqdn        = var.config.reverse_fqdn

  tags = var.tags
}

