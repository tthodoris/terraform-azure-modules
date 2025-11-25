output "load_balancer_id" {
  description = "ID of the Load Balancer"
  value       = azurerm_lb.main.id
}

output "load_balancer_name" {
  description = "Name of the Load Balancer"
  value       = azurerm_lb.main.name
}

output "public_ip_address" {
  description = "Public IP address of the load balancer"
  value       = var.config.public_ip_enabled && length(azurerm_public_ip.lb) > 0 ? azurerm_public_ip.lb[0].ip_address : null
}

