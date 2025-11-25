output "virtual_network_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "virtual_network_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "subnets" {
  description = "Map of subnet names to subnet IDs"
  value = {
    for name, subnet in azurerm_subnet.main : name => {
      id   = subnet.id
      name = subnet.name
    }
  }
}

output "subnet_ids" {
  description = "List of all subnet IDs (for backward compatibility)"
  value       = [for subnet in azurerm_subnet.main : subnet.id]
}

output "subnet_names" {
  description = "List of all subnet names"
  value       = [for subnet in azurerm_subnet.main : subnet.name]
}

