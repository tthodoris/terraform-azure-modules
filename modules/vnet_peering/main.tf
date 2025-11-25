resource "azurerm_virtual_network_peering" "main" {
  name                      = "${var.name_prefix}-${var.environment}-peering-${format("%02d", var.index + 1)}"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = var.local_virtual_network_name
  remote_virtual_network_id = var.config.remote_virtual_network_id
  allow_virtual_network_access = var.config.allow_virtual_network_access
  allow_forwarded_traffic    = var.config.allow_forwarded_traffic
  allow_gateway_transit     = var.config.allow_gateway_transit
  use_remote_gateways       = var.config.use_remote_gateways
}

