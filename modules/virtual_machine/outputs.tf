output "virtual_machine_id" {
  description = "ID of the virtual machine"
  value       = local.is_windows ? azurerm_windows_virtual_machine.main[0].id : azurerm_linux_virtual_machine.main[0].id
}

output "virtual_machine_name" {
  description = "Name of the virtual machine"
  value       = local.is_windows ? azurerm_windows_virtual_machine.main[0].name : azurerm_linux_virtual_machine.main[0].name
}

output "virtual_machine_private_ip" {
  description = "Private IP address of the virtual machine"
  value       = azurerm_network_interface.main.private_ip_address
}

output "virtual_machine_public_ip" {
  description = "Public IP address of the virtual machine"
  value       = var.config.public_ip_enabled && length(azurerm_public_ip.main) > 0 ? azurerm_public_ip.main[0].ip_address : null
}

output "network_interface_id" {
  description = "ID of the network interface"
  value       = azurerm_network_interface.main.id
}

output "managed_disks" {
  description = "Map of additional managed disks"
  value = {
    for name, disk in azurerm_managed_disk.additional : name => {
      id         = disk.id
      name       = disk.name
      disk_size_gb = disk.disk_size_gb
      storage_account_type = disk.storage_account_type
    }
  }
}

