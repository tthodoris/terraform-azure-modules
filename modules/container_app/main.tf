resource "azurerm_log_analytics_workspace" "container_app" {
  count = var.config.log_analytics_workspace_id == null ? 1 : 0

  name                = "${var.name_prefix}-${var.environment}-ca-law-${format("%02d", var.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.tags
}

resource "azurerm_container_app_environment" "main" {
  name                       = "${var.name_prefix}-${var.environment}-cae-${format("%02d", var.index + 1)}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = var.config.log_analytics_workspace_id != null ? var.config.log_analytics_workspace_id : azurerm_log_analytics_workspace.container_app[0].id

  infrastructure_subnet_id = var.subnet_id

  tags = var.tags
}

resource "azurerm_container_app" "main" {
  name                         = "${var.name_prefix}-${var.environment}-ca-${format("%02d", var.index + 1)}"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = var.resource_group_name
  revision_mode                = var.config.revision_mode

  template {
    min_replicas = var.config.min_replicas
    max_replicas = var.config.max_replicas

    container {
      name   = var.config.container_name
      image  = var.config.container_image
      cpu    = var.config.container_cpu
      memory = var.config.container_memory

      dynamic "env" {
        for_each = var.config.environment_variables
        content {
          name  = env.key
          value = env.value
        }
      }
    }
  }

  ingress {
    external_enabled = var.config.external_ingress_enabled
    target_port     = var.config.target_port
    transport       = var.config.transport
    
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  tags = var.tags
}

