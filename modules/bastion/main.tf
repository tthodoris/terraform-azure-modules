resource "azurerm_public_ip" "bastion" {
  name                = "${var.name_prefix}-${var.environment}-bastion-pip-${format("%02d", var.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.config.public_ip_allocation_method
  sku                 = var.config.public_ip_sku

  tags = var.tags
}

resource "azurerm_bastion_host" "main" {
  name                = "${var.name_prefix}-${var.environment}-bastion-${format("%02d", var.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }

  tags = var.tags
}

