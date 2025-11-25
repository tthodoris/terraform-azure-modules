output "function_app_id" {
  description = "ID of the function app"
  value       = azurerm_function_app.main.id
}

output "function_app_name" {
  description = "Name of the function app"
  value       = azurerm_function_app.main.name
}

output "function_app_url" {
  description = "Default hostname of the function app"
  value       = azurerm_function_app.main.default_hostname
}

