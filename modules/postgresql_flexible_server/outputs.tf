output "postgresql_flexible_server_id" {
  description = "ID of the PostgreSQL flexible server"
  value       = azurerm_postgresql_flexible_server.main.id
}

output "postgresql_flexible_server_name" {
  description = "Name of the PostgreSQL flexible server"
  value       = azurerm_postgresql_flexible_server.main.name
}

output "postgresql_flexible_server_fqdn" {
  description = "FQDN of the PostgreSQL flexible server"
  value       = azurerm_postgresql_flexible_server.main.fqdn
}

output "databases" {
  description = "Map of database names to database IDs"
  value = {
    for name, db in azurerm_postgresql_flexible_server_database.main : name => {
      id   = db.id
      name = db.name
    }
  }
}

