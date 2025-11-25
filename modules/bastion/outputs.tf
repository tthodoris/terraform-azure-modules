output "bastion_id" {
  description = "ID of the Bastion host"
  value       = azurerm_bastion_host.main.id
}

output "bastion_name" {
  description = "Name of the Bastion host"
  value       = azurerm_bastion_host.main.name
}

output "bastion_dns_name" {
  description = "FQDN of the Bastion host"
  value       = azurerm_bastion_host.main.dns_name
}

