output "cosmosdb_account_id" {
  description = "ID of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.id
}

output "cosmosdb_account_name" {
  description = "Name of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.name
}

output "cosmosdb_account_endpoint" {
  description = "Endpoint of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.endpoint
}

output "cosmosdb_account_primary_key" {
  description = "Primary key of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.primary_key
  sensitive   = true
}

output "databases" {
  description = "Map of database names to database IDs"
  value = {
    for name, db in azurerm_cosmosdb_sql_database.main : name => {
      id   = db.id
      name = db.name
    }
  }
}

output "containers" {
  description = "Map of container names to container IDs"
  value = {
    for key, container in azurerm_cosmosdb_sql_container.main : key => {
      id   = container.id
      name = container.name
    }
  }
}

