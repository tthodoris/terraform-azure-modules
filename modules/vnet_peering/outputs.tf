output "vnet_peering_id" {
  description = "ID of the VNet Peering"
  value       = azurerm_virtual_network_peering.main.id
}

output "vnet_peering_name" {
  description = "Name of the VNet Peering"
  value       = azurerm_virtual_network_peering.main.name
}

