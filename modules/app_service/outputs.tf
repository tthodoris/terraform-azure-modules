output "app_service_id" {
  description = "ID of the app service"
  value       = azurerm_app_service.main.id
}

output "app_service_name" {
  description = "Name of the app service"
  value       = azurerm_app_service.main.name
}

output "app_service_url" {
  description = "Default hostname of the app service"
  value       = azurerm_app_service.main.default_site_hostname
}

