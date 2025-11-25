output "resource_group_name" {
  description = "Name of the resource group"
  value       = local.resource_group_name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = local.resource_group_location
}

output "storage_accounts" {
  description = "Storage account outputs"
  value = {
    for idx, sa in module.storage_account : idx => {
      id   = sa.storage_account_id
      name = sa.storage_account_name
    }
  }
}

output "virtual_networks" {
  description = "Virtual network outputs"
  value = {
    for idx, vnet in module.virtual_network : idx => {
      id      = vnet.virtual_network_id
      name    = vnet.virtual_network_name
      subnets = vnet.subnets
    }
  }
}

output "app_service_plans" {
  description = "App Service Plan outputs"
  value = {
    for idx, asp in module.app_service_plan : idx => {
      id   = asp.app_service_plan_id
      name = asp.app_service_plan_name
    }
  }
}

output "app_services" {
  description = "App Service outputs"
  value = {
    for idx, app in module.app_service : idx => {
      id   = app.app_service_id
      name = app.app_service_name
      url  = app.app_service_url
    }
  }
}

output "key_vaults" {
  description = "Key Vault outputs"
  value = {
    for idx, kv in module.key_vault : idx => {
      id   = kv.key_vault_id
      name = kv.key_vault_name
      uri  = kv.key_vault_uri
    }
  }
}

output "container_registries" {
  description = "Container Registry outputs"
  value = {
    for idx, acr in module.container_registry : idx => {
      id   = acr.container_registry_id
      name = acr.container_registry_name
      login_server = acr.container_registry_login_server
    }
  }
}

output "kubernetes_clusters" {
  description = "Kubernetes Cluster outputs"
  value = {
    for idx, aks in module.kubernetes_cluster : idx => {
      id         = aks.kubernetes_cluster_id
      name       = aks.kubernetes_cluster_name
      fqdn       = aks.kubernetes_cluster_fqdn
      node_pools = aks.node_pools
    }
  }
}

output "aks_backup" {
  description = "AKS Backup outputs"
  value = {
    for idx, backup in module.aks_backup : idx => {
      backup_vault_id               = backup.backup_vault_id
      backup_policy_id              = backup.backup_policy_id
      backup_instance_id            = backup.backup_instance_id
      snapshot_resource_group_name  = backup.snapshot_resource_group_name
      storage_account_name          = backup.storage_account_name
    }
  }
}

output "sql_servers" {
  description = "SQL Server outputs"
  value = {
    for idx, sql in module.sql_server : idx => {
      id   = sql.sql_server_id
      name = sql.sql_server_name
      fqdn = sql.sql_server_fqdn
    }
  }
}

output "function_apps" {
  description = "Function App outputs"
  value = {
    for idx, func in module.function_app : idx => {
      id   = func.function_app_id
      name = func.function_app_name
      url  = func.function_app_url
    }
  }
}

output "log_analytics_workspaces" {
  description = "Log Analytics Workspace outputs"
  value = {
    for idx, law in module.log_analytics_workspace : idx => {
      id   = law.log_analytics_workspace_id
      name = law.log_analytics_workspace_name
    }
  }
}

output "virtual_machines" {
  description = "Virtual Machine outputs"
  value = {
    for idx, vm in module.virtual_machine : idx => {
      id            = vm.virtual_machine_id
      name          = vm.virtual_machine_name
      private_ip    = vm.virtual_machine_private_ip
      public_ip     = vm.virtual_machine_public_ip
      managed_disks = vm.managed_disks
    }
  }
}

output "postgresql_flexible_servers" {
  description = "PostgreSQL Flexible Server outputs"
  value = {
    for idx, psql in module.postgresql_flexible_server : idx => {
      id   = psql.postgresql_flexible_server_id
      name = psql.postgresql_flexible_server_name
      fqdn = psql.postgresql_flexible_server_fqdn
      databases = psql.databases
    }
  }
}

output "mysql_flexible_servers" {
  description = "MySQL Flexible Server outputs"
  value = {
    for idx, mysql in module.mysql_flexible_server : idx => {
      id   = mysql.mysql_flexible_server_id
      name = mysql.mysql_flexible_server_name
      fqdn = mysql.mysql_flexible_server_fqdn
      databases = mysql.databases
    }
  }
}

output "cosmosdb_accounts" {
  description = "Cosmos DB account outputs"
  value = {
    for idx, cosmos in module.cosmosdb : idx => {
      id       = cosmos.cosmosdb_account_id
      name     = cosmos.cosmosdb_account_name
      endpoint = cosmos.cosmosdb_account_endpoint
      databases = cosmos.databases
      containers = cosmos.containers
    }
  }
}

output "azure_firewalls" {
  description = "Azure Firewall outputs"
  value = {
    for idx, fw in module.azure_firewall : idx => {
      id      = fw.azure_firewall_id
      name    = fw.azure_firewall_name
      public_ip = fw.public_ip_address
    }
  }
}

output "application_gateways" {
  description = "Application Gateway outputs"
  value = {
    for idx, agw in module.application_gateway : idx => {
      id      = agw.application_gateway_id
      name    = agw.application_gateway_name
      public_ip = agw.public_ip_address
    }
  }
}

output "bastions" {
  description = "Bastion outputs"
  value = {
    for idx, bastion in module.bastion : idx => {
      id      = bastion.bastion_id
      name    = bastion.bastion_name
      dns_name = bastion.bastion_dns_name
    }
  }
}

output "load_balancers" {
  description = "Load Balancer outputs"
  value = {
    for idx, lb in module.load_balancer : idx => {
      id      = lb.load_balancer_id
      name    = lb.load_balancer_name
      public_ip = lb.public_ip_address
    }
  }
}

output "network_security_groups" {
  description = "Network Security Group outputs"
  value = {
    for idx, nsg in module.network_security_group : idx => {
      id   = nsg.network_security_group_id
      name = nsg.network_security_group_name
    }
  }
}

output "private_dns_zones" {
  description = "Private DNS Zone outputs"
  value = {
    for idx, zone in module.private_dns_zone : idx => {
      id   = zone.private_dns_zone_id
      name = zone.private_dns_zone_name
    }
  }
}

output "private_dns_zone_links" {
  description = "Private DNS Zone Link outputs"
  value = {
    for idx, link in module.private_dns_zone_link : idx => {
      id   = link.private_dns_zone_link_id
      name = link.private_dns_zone_link_name
    }
  }
}

output "private_endpoints" {
  description = "Private Endpoint outputs"
  value = {
    for idx, pe in module.private_endpoint : idx => {
      id        = pe.private_endpoint_id
      name      = pe.private_endpoint_name
      private_ip = pe.private_endpoint_private_ip
    }
  }
}

output "public_ips" {
  description = "Public IP outputs"
  value = {
    for idx, pip in module.public_ip : idx => {
      id      = pip.public_ip_id
      name    = pip.public_ip_name
      address = pip.public_ip_address
      fqdn    = pip.public_ip_fqdn
    }
  }
}

output "vnet_peerings" {
  description = "VNet Peering outputs"
  value = {
    for idx, peering in module.vnet_peering : idx => {
      id   = peering.vnet_peering_id
      name = peering.vnet_peering_name
    }
  }
}

output "vpn_gateways" {
  description = "VPN Gateway outputs"
  value = {
    for idx, vpn in module.vpn_gateway : idx => {
      id       = vpn.vpn_gateway_id
      name     = vpn.vpn_gateway_name
      public_ip = vpn.vpn_gateway_public_ip
    }
  }
}

output "container_apps" {
  description = "Container App outputs"
  value = {
    for idx, ca in module.container_app : idx => {
      id      = ca.container_app_id
      name    = ca.container_app_name
      fqdn    = ca.container_app_fqdn
      environment_id = ca.container_app_environment_id
    }
  }
}

output "recovery_vaults" {
  description = "Recovery Vault outputs"
  value = {
    for idx, rv in module.recovery_vault : idx => {
      id   = rv.recovery_vault_id
      name = rv.recovery_vault_name
    }
  }
}

output "event_hubs" {
  description = "Event Hubs outputs"
  value = {
    for idx, eh in module.event_hubs : idx => {
      namespace_id   = eh.event_hub_namespace_id
      namespace_name = eh.event_hub_namespace_name
      hubs           = eh.event_hubs
    }
  }
}

output "redis_cache" {
  description = "Redis Cache outputs"
  value = {
    for idx, redis in module.redis_cache : idx => {
      redis_cache_id       = redis.redis_cache_id
      redis_cache_name     = redis.redis_cache_name
      redis_cache_hostname = redis.redis_cache_hostname
      redis_cache_port     = redis.redis_cache_port
      redis_cache_ssl_port = redis.redis_cache_ssl_port
    }
  }
}

output "vm_backup" {
  description = "VM Backup outputs"
  value = {
    for idx, backup in module.vm_backup : idx => {
      recovery_vault_id      = backup.recovery_vault_id
      recovery_vault_name   = backup.recovery_vault_name
      backup_policy_id      = backup.backup_policy_id
      backup_protected_vm_id = backup.backup_protected_vm_id
    }
  }
}

