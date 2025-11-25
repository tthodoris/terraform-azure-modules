output "sql_server_id" {
  description = "ID of the SQL server"
  value       = azurerm_mssql_server.main.id
}

output "sql_server_name" {
  description = "Name of the SQL server"
  value       = azurerm_mssql_server.main.name
}

output "sql_server_fqdn" {
  description = "FQDN of the SQL server"
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "database_id" {
  description = "ID of the SQL database"
  value       = length(azurerm_mssql_database.main) > 0 ? azurerm_mssql_database.main[0].id : null
}

output "database_name" {
  description = "Name of the SQL database"
  value       = length(azurerm_mssql_database.main) > 0 ? azurerm_mssql_database.main[0].name : null
}

