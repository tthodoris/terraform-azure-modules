output "public_ip_id" {
  description = "ID of the Public IP"
  value       = azurerm_public_ip.main.id
}

output "public_ip_name" {
  description = "Name of the Public IP"
  value       = azurerm_public_ip.main.name
}

output "public_ip_address" {
  description = "IP address of the Public IP"
  value       = azurerm_public_ip.main.ip_address
}

output "public_ip_fqdn" {
  description = "FQDN of the Public IP"
  value       = azurerm_public_ip.main.fqdn
}

