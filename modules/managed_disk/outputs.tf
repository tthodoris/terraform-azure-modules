output "managed_disk_id" {
  description = "ID of the managed disk"
  value       = azurerm_managed_disk.main.id
}

output "managed_disk_name" {
  description = "Name of the managed disk"
  value       = azurerm_managed_disk.main.name
}

output "managed_disk_resource_group_name" {
  description = "Resource group name of the managed disk"
  value       = azurerm_managed_disk.main.resource_group_name
}

