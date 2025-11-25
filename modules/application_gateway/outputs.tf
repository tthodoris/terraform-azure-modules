output "application_gateway_id" {
  description = "ID of the Application Gateway"
  value       = azurerm_application_gateway.main.id
}

output "application_gateway_name" {
  description = "Name of the Application Gateway"
  value       = azurerm_application_gateway.main.name
}

output "public_ip_address" {
  description = "Public IP address of the gateway"
  value       = var.config.public_ip_enabled && length(azurerm_public_ip.gateway) > 0 ? azurerm_public_ip.gateway[0].ip_address : null
}

