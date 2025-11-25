output "app_service_plan_id" {
  description = "ID of the app service plan"
  value       = azurerm_app_service_plan.main.id
}

output "app_service_plan_name" {
  description = "Name of the app service plan"
  value       = azurerm_app_service_plan.main.name
}

