output "event_hub_namespace_id" {
  description = "ID of the Event Hub Namespace"
  value       = azurerm_eventhub_namespace.main.id
}

output "event_hub_namespace_name" {
  description = "Name of the Event Hub Namespace"
  value       = azurerm_eventhub_namespace.main.name
}

output "event_hub_namespace_default_primary_connection_string" {
  description = "Primary connection string for the Event Hub Namespace"
  value       = azurerm_eventhub_namespace.main.default_primary_connection_string
  sensitive   = true
}

output "event_hubs" {
  description = "Map of event hub names to event hub IDs"
  value = {
    for name, hub in azurerm_eventhub.main : name => {
      id   = hub.id
      name = hub.name
    }
  }
}

