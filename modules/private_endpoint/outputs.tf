output "private_endpoint_id" {
  description = "ID of the Private Endpoint"
  value       = azurerm_private_endpoint.main.id
}

output "private_endpoint_name" {
  description = "Name of the Private Endpoint"
  value       = azurerm_private_endpoint.main.name
}

output "private_endpoint_private_ip" {
  description = "Private IP address of the endpoint (use network_interface to get IP details)"
  value       = length(azurerm_private_endpoint.main.network_interface) > 0 ? azurerm_private_endpoint.main.network_interface[0].id : null
}

