# Azure Subscription Configuration
subscription_id     = "xxxxxxxxx"
resource_group_name = "RGXXXXX"
location            = "XXXXeurope"

# Resource Group Configuration
# Set create_resource_group = false to use an existing resource group
# When using an existing RG, location is optional (will use the RG's location)
create_resource_group = false

# Environment Configuration
environment = "dev"
name_prefix = "vmdb"

# Additional Tags
tags = {
  Project     = "VM-MySQL-Deployment"
  Owner       = "DevOps TT"
  CostCenter  = "Engineering"
  Environment = "Development"
  CreationDate = "2024-06-15"
}

# Modules configuration file (default: modules-config.json)
modules_config_file = "modules-config-rg03.json"

