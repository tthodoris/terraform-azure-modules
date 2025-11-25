output "azure_firewall_id" {
  description = "ID of the Azure Firewall"
  value       = azurerm_firewall.main.id
}

output "azure_firewall_name" {
  description = "Name of the Azure Firewall"
  value       = azurerm_firewall.main.name
}

output "public_ip_address" {
  description = "Public IP address of the firewall"
  value       = var.config.public_ip_enabled && length(azurerm_public_ip.firewall) > 0 ? azurerm_public_ip.firewall[0].ip_address : null
}

