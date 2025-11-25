resource "azurerm_public_ip" "gateway" {
  count = var.config.public_ip_enabled ? 1 : 0

  name                = "${var.name_prefix}-${var.environment}-agw-pip-${format("%02d", var.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.config.public_ip_allocation_method
  sku                 = var.config.public_ip_sku

  tags = var.tags
}

resource "azurerm_application_gateway" "main" {
  name                = var.resource_name != "" ? var.resource_name : "${var.name_prefix}-${var.environment}-agw-${format("%02d", var.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name     = var.config.sku_name
    tier     = var.config.sku_tier
    capacity = var.config.capacity
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = "http"
    port = 80
  }

  frontend_ip_configuration {
    name                          = "frontend-ip"
    public_ip_address_id         = var.config.public_ip_enabled && length(azurerm_public_ip.gateway) > 0 ? azurerm_public_ip.gateway[0].id : null
    private_ip_address_allocation = var.config.public_ip_enabled ? "Dynamic" : "Static"
    private_ip_address           = var.config.public_ip_enabled ? null : var.config.private_ip_address
    subnet_id                    = var.config.public_ip_enabled ? null : var.subnet_id
  }

  backend_address_pool {
    name = "backend-pool"
  }

  backend_http_settings {
    name                  = "http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip"
    frontend_port_name             = "http"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "routing-rule"
    rule_type                  = "Basic"
    priority                   = 100
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name  = "http-settings"
  }

  # WAF Configuration (required for WAF_v2 SKU)
  dynamic "waf_configuration" {
    for_each = var.config.sku_tier == "WAF_v2" ? [1] : []
    content {
      enabled                  = true
      firewall_mode            = "Detection"
      rule_set_type            = "OWASP"
      rule_set_version         = "3.2"
      max_request_body_size_kb = 128
      file_upload_limit_mb     = 100
      request_body_check       = true
    }
  }

  tags = var.tags
}

