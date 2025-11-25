resource "azurerm_public_ip" "gateway" {
  name                = "${var.name_prefix}-${var.environment}-vpn-pip-${format("%02d", var.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.config.public_ip_allocation_method
  sku                 = var.config.public_ip_sku

  tags = var.tags
}

resource "azurerm_virtual_network_gateway" "main" {
  name                = "${var.name_prefix}-${var.environment}-vpn-${format("%02d", var.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name

  type     = var.config.gateway_type
  vpn_type = var.config.vpn_type
  sku      = var.config.sku

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.gateway.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.subnet_id
  }

  tags = var.tags
}

