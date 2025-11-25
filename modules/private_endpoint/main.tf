resource "azurerm_private_endpoint" "main" {
  name                = var.resource_name != "" ? var.resource_name : "${var.name_prefix}-${var.environment}-pe-${format("%02d", var.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.name_prefix}-${var.environment}-psc-${format("%02d", var.index + 1)}"
    private_connection_resource_id = var.config.target_resource_id
    is_manual_connection         = var.config.is_manual_connection
    subresource_names              = var.config.subresource_names
  }

  dynamic "private_dns_zone_group" {
    for_each = (var.config.private_dns_zone_ids != null && length(var.config.private_dns_zone_ids) > 0) || length(var.private_dns_zone_ids) > 0 ? [1] : []
    content {
      name                 = "${var.name_prefix}-${var.environment}-dns-group-${format("%02d", var.index + 1)}"
      private_dns_zone_ids = length(var.private_dns_zone_ids) > 0 ? var.private_dns_zone_ids : var.config.private_dns_zone_ids
    }
  }

  tags = var.tags
}

