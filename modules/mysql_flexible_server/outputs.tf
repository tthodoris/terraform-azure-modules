output "mysql_flexible_server_id" {
  description = "ID of the MySQL flexible server"
  value       = azurerm_mysql_flexible_server.main.id
}

output "mysql_flexible_server_name" {
  description = "Name of the MySQL flexible server"
  value       = azurerm_mysql_flexible_server.main.name
}

output "mysql_flexible_server_fqdn" {
  description = "FQDN of the MySQL flexible server"
  value       = azurerm_mysql_flexible_server.main.fqdn
}

output "databases" {
  description = "Map of database names to database IDs"
  value = {
    for name, db in azurerm_mysql_flexible_database.main : name => {
      id   = db.id
      name = db.name
    }
  }
}

