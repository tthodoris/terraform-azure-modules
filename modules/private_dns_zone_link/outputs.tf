output "private_dns_zone_link_id" {
  description = "ID of the Private DNS Zone Link"
  value       = azurerm_private_dns_zone_virtual_network_link.main.id
}

output "private_dns_zone_link_name" {
  description = "Name of the Private DNS Zone Link"
  value       = azurerm_private_dns_zone_virtual_network_link.main.name
}

