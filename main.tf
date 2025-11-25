terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Read the modules configuration file
locals {
  config = jsondecode(file(var.modules_config_file))
  
  # Extract module configurations
  storage_account_config         = local.config.modules.storage_account
  app_service_config             = local.config.modules.app_service
  virtual_network_config         = local.config.modules.virtual_network
  key_vault_config               = local.config.modules.key_vault
  app_service_plan_config        = local.config.modules.app_service_plan
  container_registry_config      = local.config.modules.container_registry
  kubernetes_cluster_config      = local.config.modules.kubernetes_cluster
  sql_server_config              = local.config.modules.sql_server
  function_app_config            = local.config.modules.function_app
  log_analytics_workspace_config = local.config.modules.log_analytics_workspace
  virtual_machine_config         = local.config.modules.virtual_machine
  postgresql_flexible_server_config = local.config.modules.postgresql_flexible_server
  mysql_flexible_server_config      = local.config.modules.mysql_flexible_server
  cosmosdb_config                  = local.config.modules.cosmosdb
  azure_firewall_config            = local.config.modules.azure_firewall
  application_gateway_config       = local.config.modules.application_gateway
  bastion_config                   = local.config.modules.bastion
  load_balancer_config             = local.config.modules.load_balancer
  network_security_group_config    = local.config.modules.network_security_group
  private_dns_zone_config          = local.config.modules.private_dns_zone
  private_dns_zone_link_config     = local.config.modules.private_dns_zone_link
  private_endpoint_config          = local.config.modules.private_endpoint
  public_ip_config                 = local.config.modules.public_ip
  vnet_peering_config              = local.config.modules.vnet_peering
  vpn_gateway_config               = local.config.modules.vpn_gateway
  container_app_config             = local.config.modules.container_app
  recovery_vault_config            = local.config.modules.recovery_vault
  event_hubs_config                = local.config.modules.event_hubs
  redis_cache_config               = try(local.config.modules.redis_cache, { enabled = false, count = 0, config = {} })
  aks_backup_config                = try(local.config.modules.aks_backup, { enabled = false, count = 0, config = {} })
  vm_backup_config                 = try(local.config.modules.vm_backup, { enabled = false, count = 0, config = {} })
  managed_disk_config              = try(local.config.modules.managed_disk, { enabled = false, count = 0, config = {} })
  dns_zone_config                 = try(local.config.modules.dns_zone, { enabled = false, count = 0, config = {} })
  
  # Service Suffix Mapping Table (fallback defaults)
  # Maps module names to Azure service suffixes for naming conventions
  # These are used as fallback if service_suffix is not provided in config
  service_suffixes_default = {
    resource_group            = "rg"
    storage_account           = "sa"
    virtual_network           = "vnet"
    app_service               = "app"
    app_service_plan          = "asp"
    key_vault                 = "kv"
    container_registry        = "acr"
    kubernetes_cluster        = "aks"
    aks_backup                = "aksbk"
    sql_server                = "sql"
    function_app              = "func"
    function_app_storage      = "stvm"
    log_analytics_workspace   = "law"
    virtual_machine           = "vm"
    vm_os_disk                = "osdisk"
    vm_data_disk              = "disk"
    network_interface         = "nic"
    managed_disk              = "disk"
    postgresql_flexible_server = "psql"
    mysql_flexible_server      = "mysql"
    cosmosdb                  = "cosmos"
    azure_firewall            = "afw"
    application_gateway       = "agw"
    bastion                   = "bas"
    load_balancer             = "lb"
    network_security_group    = "nsg"
    private_dns_zone          = "dns"
    private_dns_zone_link     = "dns-link"
    private_endpoint          = "pe"
    public_ip                 = "pip"
    vnet_peering              = "peer"
    vpn_gateway               = "vpngw"
    container_app             = "ca"
    recovery_vault            = "rsv"
    vm_backup                 = "rsv"
    event_hubs                = "eh"
    redis_cache               = "redis"
    dns_zone                  = "dns"
  }

  # Get service suffix from config or use default
  get_service_suffix = {
    resource_group            = try(local.config.modules.resource_group.service_suffix, local.service_suffixes_default.resource_group)
    storage_account           = try(local.storage_account_config.service_suffix, local.service_suffixes_default.storage_account)
    virtual_network           = try(local.virtual_network_config.service_suffix, local.service_suffixes_default.virtual_network)
    app_service               = try(local.app_service_config.service_suffix, local.service_suffixes_default.app_service)
    app_service_plan          = try(local.app_service_plan_config.service_suffix, local.service_suffixes_default.app_service_plan)
    key_vault                 = try(local.key_vault_config.service_suffix, local.service_suffixes_default.key_vault)
    container_registry        = try(local.container_registry_config.service_suffix, local.service_suffixes_default.container_registry)
    kubernetes_cluster        = try(local.kubernetes_cluster_config.service_suffix, local.service_suffixes_default.kubernetes_cluster)
    aks_backup                = try(local.aks_backup_config.service_suffix, local.service_suffixes_default.aks_backup)
    aks_backup_storage        = try(local.aks_backup_config.service_suffix, "sa")
    sql_server                = try(local.sql_server_config.service_suffix, local.service_suffixes_default.sql_server)
    function_app              = try(local.function_app_config.service_suffix, local.service_suffixes_default.function_app)
    function_app_storage      = try(local.function_app_config.service_suffix, local.service_suffixes_default.function_app_storage)
    log_analytics_workspace   = try(local.log_analytics_workspace_config.service_suffix, local.service_suffixes_default.log_analytics_workspace)
    virtual_machine           = try(local.virtual_machine_config.service_suffix, local.service_suffixes_default.virtual_machine)
    vm_os_disk                = try(local.virtual_machine_config.service_suffix, "osdisk")
    vm_data_disk              = try(local.virtual_machine_config.service_suffix, "disk")
    network_interface         = try(local.virtual_machine_config.service_suffix, "nic")
    managed_disk              = try(local.managed_disk_config.service_suffix, local.service_suffixes_default.managed_disk)
    postgresql_flexible_server = try(local.postgresql_flexible_server_config.service_suffix, local.service_suffixes_default.postgresql_flexible_server)
    mysql_flexible_server      = try(local.mysql_flexible_server_config.service_suffix, local.service_suffixes_default.mysql_flexible_server)
    cosmosdb                  = try(local.cosmosdb_config.service_suffix, local.service_suffixes_default.cosmosdb)
    azure_firewall            = try(local.azure_firewall_config.service_suffix, local.service_suffixes_default.azure_firewall)
    application_gateway       = try(local.application_gateway_config.service_suffix, local.service_suffixes_default.application_gateway)
    bastion                   = try(local.bastion_config.service_suffix, local.service_suffixes_default.bastion)
    load_balancer             = try(local.load_balancer_config.service_suffix, local.service_suffixes_default.load_balancer)
    network_security_group    = try(local.network_security_group_config.service_suffix, local.service_suffixes_default.network_security_group)
    private_dns_zone          = try(local.private_dns_zone_config.service_suffix, local.service_suffixes_default.private_dns_zone)
    private_dns_zone_link     = try(local.private_dns_zone_link_config.service_suffix, local.service_suffixes_default.private_dns_zone_link)
    private_endpoint          = try(local.private_endpoint_config.service_suffix, local.service_suffixes_default.private_endpoint)
    public_ip                 = try(local.public_ip_config.service_suffix, local.service_suffixes_default.public_ip)
    vnet_peering              = try(local.vnet_peering_config.service_suffix, local.service_suffixes_default.vnet_peering)
    vpn_gateway               = try(local.vpn_gateway_config.service_suffix, local.service_suffixes_default.vpn_gateway)
    container_app             = try(local.container_app_config.service_suffix, local.service_suffixes_default.container_app)
    recovery_vault            = try(local.recovery_vault_config.service_suffix, local.service_suffixes_default.recovery_vault)
    vm_backup                 = try(local.vm_backup_config.service_suffix, local.service_suffixes_default.vm_backup)
    recovery_services_vault   = try(local.vm_backup_config.service_suffix, "rsv")
    event_hubs                = try(local.event_hubs_config.service_suffix, local.service_suffixes_default.event_hubs)
    redis_cache               = try(local.redis_cache_config.service_suffix, local.service_suffixes_default.redis_cache)
    dns_zone                  = try(local.dns_zone_config.service_suffix, local.service_suffixes_default.dns_zone)
  }

  # Naming Convention Helper Functions
  # These functions generate resource names based on: [part1]-[part2]-[part3]-[part4]-[service_suffix]-[count]
  # If naming_parts are not provided in config, falls back to: [name_prefix]-[environment]-[service_suffix]-[count]
  
  # Function to get naming parts from config for a specific module and index
  get_naming_parts = {
    storage_account = {
      for idx in range(100) : idx => try(
        local.storage_account_config.naming_parts[idx],
        try(local.storage_account_config.naming_parts, null),
        null
      )
    }
    virtual_network = {
      for idx in range(100) : idx => try(
        local.virtual_network_config.naming_parts[idx],
        try(local.virtual_network_config.naming_parts, null),
        null
      )
    }
    app_service = {
      for idx in range(100) : idx => try(
        local.app_service_config.naming_parts[idx],
        try(local.app_service_config.naming_parts, null),
        null
      )
    }
    app_service_plan = {
      for idx in range(100) : idx => try(
        local.app_service_plan_config.naming_parts[idx],
        try(local.app_service_plan_config.naming_parts, null),
        null
      )
    }
    key_vault = {
      for idx in range(100) : idx => try(
        local.key_vault_config.naming_parts[idx],
        try(local.key_vault_config.naming_parts, null),
        null
      )
    }
    container_registry = {
      for idx in range(100) : idx => try(
        local.container_registry_config.naming_parts[idx],
        try(local.container_registry_config.naming_parts, null),
        null
      )
    }
    kubernetes_cluster = {
      for idx in range(100) : idx => try(
        local.kubernetes_cluster_config.naming_parts[idx],
        try(local.kubernetes_cluster_config.naming_parts, null),
        null
      )
    }
    aks_backup = {
      for idx in range(100) : idx => try(
        local.aks_backup_config.naming_parts[idx],
        try(local.aks_backup_config.naming_parts, null),
        null
      )
    }
    aks_backup_storage = {
      for idx in range(100) : idx => try(
        local.aks_backup_config.naming_parts[idx],
        try(local.aks_backup_config.naming_parts, null),
        null
      )
    }
    sql_server = {
      for idx in range(100) : idx => try(
        local.sql_server_config.naming_parts[idx],
        try(local.sql_server_config.naming_parts, null),
        null
      )
    }
    function_app = {
      for idx in range(100) : idx => try(
        local.function_app_config.naming_parts[idx],
        try(local.function_app_config.naming_parts, null),
        null
      )
    }
    log_analytics_workspace = {
      for idx in range(100) : idx => try(
        local.log_analytics_workspace_config.naming_parts[idx],
        try(local.log_analytics_workspace_config.naming_parts, null),
        null
      )
    }
    virtual_machine = {
      for idx in range(100) : idx => try(
        local.virtual_machine_config.naming_parts[idx],
        try(local.virtual_machine_config.naming_parts, null),
        null
      )
    }
    postgresql_flexible_server = {
      for idx in range(100) : idx => try(
        local.postgresql_flexible_server_config.naming_parts[idx],
        try(local.postgresql_flexible_server_config.naming_parts, null),
        null
      )
    }
    mysql_flexible_server = {
      for idx in range(100) : idx => try(
        local.mysql_flexible_server_config.naming_parts[idx],
        try(local.mysql_flexible_server_config.naming_parts, null),
        null
      )
    }
    cosmosdb = {
      for idx in range(100) : idx => try(
        local.cosmosdb_config.naming_parts[idx],
        try(local.cosmosdb_config.naming_parts, null),
        null
      )
    }
    azure_firewall = {
      for idx in range(100) : idx => try(
        local.azure_firewall_config.naming_parts[idx],
        try(local.azure_firewall_config.naming_parts, null),
        null
      )
    }
    application_gateway = {
      for idx in range(100) : idx => try(
        local.application_gateway_config.naming_parts[idx],
        try(local.application_gateway_config.naming_parts, null),
        null
      )
    }
    bastion = {
      for idx in range(100) : idx => try(
        local.bastion_config.naming_parts[idx],
        try(local.bastion_config.naming_parts, null),
        null
      )
    }
    load_balancer = {
      for idx in range(100) : idx => try(
        local.load_balancer_config.naming_parts[idx],
        try(local.load_balancer_config.naming_parts, null),
        null
      )
    }
    network_security_group = {
      for idx in range(100) : idx => try(
        local.network_security_group_config.naming_parts[idx],
        try(local.network_security_group_config.naming_parts, null),
        null
      )
    }
    private_dns_zone = {
      for idx in range(100) : idx => try(
        local.private_dns_zone_config.naming_parts[idx],
        try(local.private_dns_zone_config.naming_parts, null),
        null
      )
    }
    private_dns_zone_link = {
      for idx in range(100) : idx => try(
        local.private_dns_zone_link_config.naming_parts[idx],
        try(local.private_dns_zone_link_config.naming_parts, null),
        null
      )
    }
    private_endpoint = {
      for idx in range(100) : idx => try(
        local.private_endpoint_config.naming_parts[idx],
        try(local.private_endpoint_config.naming_parts, null),
        null
      )
    }
    public_ip = {
      for idx in range(100) : idx => try(
        local.public_ip_config.naming_parts[idx],
        try(local.public_ip_config.naming_parts, null),
        null
      )
    }
    vnet_peering = {
      for idx in range(100) : idx => try(
        local.vnet_peering_config.naming_parts[idx],
        try(local.vnet_peering_config.naming_parts, null),
        null
      )
    }
    vpn_gateway = {
      for idx in range(100) : idx => try(
        local.vpn_gateway_config.naming_parts[idx],
        try(local.vpn_gateway_config.naming_parts, null),
        null
      )
    }
    container_app = {
      for idx in range(100) : idx => try(
        local.container_app_config.naming_parts[idx],
        try(local.container_app_config.naming_parts, null),
        null
      )
    }
    recovery_vault = {
      for idx in range(100) : idx => try(
        local.recovery_vault_config.naming_parts[idx],
        try(local.recovery_vault_config.naming_parts, null),
        null
      )
    }
    vm_backup = {
      for idx in range(100) : idx => try(
        local.vm_backup_config.naming_parts[idx],
        try(local.vm_backup_config.naming_parts, null),
        null
      )
    }
    event_hubs = {
      for idx in range(100) : idx => try(
        local.event_hubs_config.naming_parts[idx],
        try(local.event_hubs_config.naming_parts, null),
        null
      )
    }
    redis_cache = {
      for idx in range(100) : idx => try(
        local.redis_cache_config.naming_parts[idx],
        try(local.redis_cache_config.naming_parts, null),
        null
      )
    }
    managed_disk = {
      for idx in range(100) : idx => try(
        local.managed_disk_config.naming_parts[idx],
        try(local.managed_disk_config.naming_parts, null),
        null
      )
    }
    dns_zone = {
      for idx in range(100) : idx => try(
        local.dns_zone_config.naming_parts[idx],
        try(local.dns_zone_config.naming_parts, null),
        null
      )
    }
    # Resource group - use special config or derive from first VM/VNet
    resource_group = {
      for idx in range(100) : idx => try(
        local.config.modules.resource_group.naming_parts[idx],
        try(local.config.modules.resource_group.naming_parts, null),
        null
      )
    }
    # Function app storage - use function_app naming parts
    function_app_storage = {
      for idx in range(100) : idx => try(
        local.function_app_config.naming_parts[idx],
        try(local.function_app_config.naming_parts, null),
        null
      )
    }
    # VM OS disk - use virtual_machine naming parts
    vm_os_disk = {
      for idx in range(100) : idx => try(
        local.virtual_machine_config.naming_parts[idx],
        try(local.virtual_machine_config.naming_parts, null),
        null
      )
    }
    # VM data disk - use virtual_machine naming parts
    vm_data_disk = {
      for idx in range(100) : idx => try(
        local.virtual_machine_config.naming_parts[idx],
        try(local.virtual_machine_config.naming_parts, null),
        null
      )
    }
    # Network interface - use virtual_machine naming parts
    network_interface = {
      for idx in range(100) : idx => try(
        local.virtual_machine_config.naming_parts[idx],
        try(local.virtual_machine_config.naming_parts, null),
        null
      )
    }
    # Recovery services vault - use vm_backup naming parts
    recovery_services_vault = {
      for idx in range(100) : idx => try(
        local.vm_backup_config.naming_parts[idx],
        try(local.vm_backup_config.naming_parts, null),
        null
      )
    }
  }

  # Generate resource names: [part1]-[part2]-[part3]-[part4][part5]
  # Where part4 is the service suffix (from config or default) and part5 is the count (starting from 01, no hyphen before count)
  # Special handling for resources that require alphanumeric-only names (storage_account, container_registry, function_app_storage)
  # For aks_backup_storage, use the same naming_parts as aks_backup but override part4 to use "sa" suffix
  generate_name_base = {
    for module_type, suffix in local.get_service_suffix : module_type => {
      for idx in range(100) : idx => lower(
        "${join("-", 
          compact([
            try(local.get_naming_parts[module_type][idx].part1, var.name_prefix),
            try(local.get_naming_parts[module_type][idx].part2, var.environment),
            try(local.get_naming_parts[module_type][idx].part3, ""),
            module_type == "aks_backup_storage" ? suffix : (try(local.get_naming_parts[module_type][idx].part4, "") != "" ? try(local.get_naming_parts[module_type][idx].part4, "") : suffix)
          ])
        )}${format("%02d", idx + 1)}"
      )
    }
  }
  
  # Apply special formatting for resources that need alphanumeric-only names
  generate_name = {
    for module_type, suffix in local.get_service_suffix : module_type => {
      for idx in range(100) : idx => 
        module_type == "storage_account" ? substr(replace(local.generate_name_base[module_type][idx], "-", ""), 0, 24) : (
          contains(["container_registry", "function_app_storage"], module_type) ? substr(replace(local.generate_name_base[module_type][idx], "-", ""), 0, 50) : (
            contains(["key_vault", "aks_backup_storage"], module_type) ? substr(replace(local.generate_name_base[module_type][idx], "-", ""), 0, 24) : local.generate_name_base[module_type][idx]
          )
        )
    }
  }
  
  # Common tags
  common_tags = merge(
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )
  
  # Create a lookup map for VNets and subnets
  # Format: vnet_lookup["vnet_index"]["subnet_name"] = subnet_id
  vnet_lookup = {
    for vnet_idx, vnet in module.virtual_network : vnet_idx => {
      vnet_id   = vnet.virtual_network_id
      vnet_name = vnet.virtual_network_name
      subnets   = vnet.subnets
    }
  }
  
  # Helper function to get subnet ID by VNet index and subnet name
  # This creates a nested map: get_subnet_id[vnet_index][subnet_name] = subnet_id
  get_subnet_id = length(module.virtual_network) > 0 ? {
    for vnet_idx in range(length(module.virtual_network)) : vnet_idx => {
      for subnet_name, subnet_info in try(module.virtual_network[vnet_idx].subnets, {}) : subnet_name => subnet_info.id
    }
  } : {}
  
  # Compute configs for each module instance to avoid "config" resource type errors
  # This prevents Terraform from interpreting "config" as a resource type
  app_service_configs = local.app_service_config.enabled ? [
    for i in range(local.app_service_config.count) : try(
      local.app_service_config.config[i],
      local.app_service_config.config
    )
  ] : []
  
  kubernetes_cluster_configs = local.kubernetes_cluster_config.enabled ? [
    for i in range(local.kubernetes_cluster_config.count) : try(
      local.kubernetes_cluster_config.config[i],
      local.kubernetes_cluster_config.config
    )
  ] : []
  
  sql_server_configs = local.sql_server_config.enabled ? [
    for i in range(local.sql_server_config.count) : try(
      local.sql_server_config.config[i],
      local.sql_server_config.config
    )
  ] : []
  
  function_app_configs = local.function_app_config.enabled ? [
    for i in range(local.function_app_config.count) : try(
      local.function_app_config.config[i],
      local.function_app_config.config
    )
  ] : []
  
  virtual_machine_configs = local.virtual_machine_config.enabled ? [
    for i in range(local.virtual_machine_config.count) : try(
      local.virtual_machine_config.config[i],
      local.virtual_machine_config.config
    )
  ] : []
  
  postgresql_flexible_server_configs = local.postgresql_flexible_server_config.enabled ? [
    for i in range(local.postgresql_flexible_server_config.count) : try(
      local.postgresql_flexible_server_config.config[i],
      local.postgresql_flexible_server_config.config
    )
  ] : []
  
  mysql_flexible_server_configs = local.mysql_flexible_server_config.enabled ? [
    for i in range(local.mysql_flexible_server_config.count) : try(
      local.mysql_flexible_server_config.config[i],
      local.mysql_flexible_server_config.config
    )
  ] : []
  
  cosmosdb_configs = local.cosmosdb_config.enabled ? [
    for i in range(local.cosmosdb_config.count) : try(
      local.cosmosdb_config.config[i],
      local.cosmosdb_config.config
    )
  ] : []
  
  azure_firewall_configs = local.azure_firewall_config.enabled ? [
    for i in range(local.azure_firewall_config.count) : try(
      local.azure_firewall_config.config[i],
      local.azure_firewall_config.config
    )
  ] : []
  
  application_gateway_configs = local.application_gateway_config.enabled ? [
    for i in range(local.application_gateway_config.count) : try(
      local.application_gateway_config.config[i],
      local.application_gateway_config.config
    )
  ] : []
  
  bastion_configs = local.bastion_config.enabled ? [
    for i in range(local.bastion_config.count) : try(
      local.bastion_config.config[i],
      local.bastion_config.config
    )
  ] : []
  
  load_balancer_configs = local.load_balancer_config.enabled ? [
    for i in range(local.load_balancer_config.count) : try(
      local.load_balancer_config.config[i],
      local.load_balancer_config.config
    )
  ] : []
  
  private_dns_zone_link_configs = local.private_dns_zone_link_config.enabled ? [
    for i in range(local.private_dns_zone_link_config.count) : try(
      local.private_dns_zone_link_config.config[i],
      local.private_dns_zone_link_config.config
    )
  ] : []
  
  private_endpoint_configs = local.private_endpoint_config.enabled ? [
    for i in range(local.private_endpoint_config.count) : try(
      local.private_endpoint_config.config[i],
      local.private_endpoint_config.config
    )
  ] : []
  
  vnet_peering_configs = local.vnet_peering_config.enabled ? [
    for i in range(local.vnet_peering_config.count) : try(
      local.vnet_peering_config.config[i],
      local.vnet_peering_config.config
    )
  ] : []
  
  vpn_gateway_configs = local.vpn_gateway_config.enabled ? [
    for i in range(local.vpn_gateway_config.count) : try(
      local.vpn_gateway_config.config[i],
      local.vpn_gateway_config.config
    )
  ] : []
  
  container_app_configs = local.container_app_config.enabled ? [
    for i in range(local.container_app_config.count) : try(
      local.container_app_config.config[i],
      local.container_app_config.config
    )
  ] : []
  
  redis_cache_configs = local.redis_cache_config.enabled ? [
    for i in range(local.redis_cache_config.count) : try(
      local.redis_cache_config.config[i],
      local.redis_cache_config.config
    )
  ] : []
  
  managed_disk_configs = local.managed_disk_config.enabled ? [
    for i in range(local.managed_disk_config.count) : try(
      local.managed_disk_config.config[i],
      local.managed_disk_config.config
    )
  ] : []
  
  dns_zone_configs = local.dns_zone_config.enabled ? [
    for i in range(local.dns_zone_config.count) : try(
      local.dns_zone_config.config[i],
      local.dns_zone_config.config
    )
  ] : []

  aks_backup_configs = local.aks_backup_config.enabled ? [
    for i in range(local.aks_backup_config.count) : try(
      local.aks_backup_config.config[i],
      local.aks_backup_config.config
    )
  ] : []

  aks_backup_cluster_indexes = local.aks_backup_config.enabled ? [
    for cfg in local.aks_backup_configs : try(cfg.kubernetes_cluster_index, 0)
  ] : []

  vm_backup_configs = local.vm_backup_config.enabled ? [
    for i in range(local.vm_backup_config.count) : try(
      local.vm_backup_config.config[i],
      local.vm_backup_config.config
    )
  ] : []

  vm_backup_vm_indexes = local.vm_backup_config.enabled ? [
    for cfg in local.vm_backup_configs : try(cfg.virtual_machine_index, 0)
  ] : []
  
  # Resource group name - use naming convention if available, otherwise use provided variable
  resource_group_name_used = try(
    local.config.modules.resource_group.naming_parts != null ? 
      local.generate_name.resource_group[0] : null,
    var.resource_group_name
  )
  
  # Resource group references (either created or existing)
  resource_group_name     = var.create_resource_group ? azurerm_resource_group.main[0].name : (try(data.azurerm_resource_group.existing[0].name, local.resource_group_name_used))
  resource_group_location = var.create_resource_group ? azurerm_resource_group.main[0].location : (try(data.azurerm_resource_group.existing[0].location, var.location))
  
  # Collect all services that need private endpoints (configuration only, not module references yet)
  # This will be used to create automatic private endpoints after modules are created
  services_needing_pe_config = merge(
    # Storage Accounts - Create separate private endpoints for blob and file
    local.storage_account_config.enabled ? merge([
      for idx in range(local.storage_account_config.count) :
      {
        "storage_account_${idx}_blob" = {
          service_type  = "storage_account"
          instance_idx  = idx
          subresources = ["blob"]
          dns_zones     = ["privatelink.blob.core.windows.net"]
          vnet_index    = try(local.storage_account_config.config[idx].private_endpoint_vnet_index, try(local.storage_account_config.config.private_endpoint_vnet_index, null))
          subnet_name   = try(local.storage_account_config.config[idx].private_endpoint_subnet_name, try(local.storage_account_config.config.private_endpoint_subnet_name, null))
        },
        "storage_account_${idx}_file" = {
          service_type  = "storage_account"
          instance_idx  = idx
          subresources = ["file"]
          dns_zones     = ["privatelink.file.core.windows.net"]
          vnet_index    = try(local.storage_account_config.config[idx].private_endpoint_vnet_index, try(local.storage_account_config.config.private_endpoint_vnet_index, null))
          subnet_name   = try(local.storage_account_config.config[idx].private_endpoint_subnet_name, try(local.storage_account_config.config.private_endpoint_subnet_name, null))
        }
      } if try(local.storage_account_config.config[idx].enable_private_endpoint, try(local.storage_account_config.config.enable_private_endpoint, false))
    ]...) : {},
    # Key Vaults
    local.key_vault_config.enabled ? {
      for idx in range(local.key_vault_config.count) :
      "key_vault_${idx}" => {
        service_type  = "key_vault"
        instance_idx  = idx
        subresources = ["vault"]
        dns_zones     = ["privatelink.vaultcore.azure.net"]
        vnet_index    = try(local.key_vault_config.config[idx].private_endpoint_vnet_index, try(local.key_vault_config.config.private_endpoint_vnet_index, null))
        subnet_name   = try(local.key_vault_config.config[idx].private_endpoint_subnet_name, try(local.key_vault_config.config.private_endpoint_subnet_name, null))
      } if try(local.key_vault_config.config[idx].enable_private_endpoint, try(local.key_vault_config.config.enable_private_endpoint, false))
    } : {},
    # SQL Servers
    local.sql_server_config.enabled ? {
      for idx in range(local.sql_server_config.count) :
      "sql_server_${idx}" => {
        service_type  = "sql_server"
        instance_idx  = idx
        subresources = ["sqlServer"]
        dns_zones     = ["privatelink.database.windows.net"]
        vnet_index    = try(local.sql_server_config.config[idx].private_endpoint_vnet_index, try(local.sql_server_config.config.private_endpoint_vnet_index, null))
        subnet_name   = try(local.sql_server_config.config[idx].private_endpoint_subnet_name, try(local.sql_server_config.config.private_endpoint_subnet_name, null))
      } if try(local.sql_server_config.config[idx].enable_private_endpoint, try(local.sql_server_config.config.enable_private_endpoint, false))
    } : {},
    # Cosmos DB
    local.cosmosdb_config.enabled ? {
      for idx in range(local.cosmosdb_config.count) :
      "cosmosdb_${idx}" => {
        service_type  = "cosmosdb"
        instance_idx  = idx
        subresources = ["Sql"]
        dns_zones     = ["privatelink.documents.azure.com"]
        vnet_index    = try(local.cosmosdb_config.config[idx].private_endpoint_vnet_index, try(local.cosmosdb_config.config.private_endpoint_vnet_index, null))
        subnet_name   = try(local.cosmosdb_config.config[idx].private_endpoint_subnet_name, try(local.cosmosdb_config.config.private_endpoint_subnet_name, null))
      } if try(local.cosmosdb_config.config[idx].enable_private_endpoint, try(local.cosmosdb_config.config.enable_private_endpoint, false))
    } : {},
    # Container Registry
    local.container_registry_config.enabled ? {
      for idx in range(local.container_registry_config.count) :
      "container_registry_${idx}" => {
        service_type  = "container_registry"
        instance_idx  = idx
        subresources = ["registry"]
        dns_zones     = ["privatelink.azurecr.io"]
        vnet_index    = try(local.container_registry_config.config[idx].private_endpoint_vnet_index, try(local.container_registry_config.config.private_endpoint_vnet_index, null))
        subnet_name   = try(local.container_registry_config.config[idx].private_endpoint_subnet_name, try(local.container_registry_config.config.private_endpoint_subnet_name, null))
      } if try(local.container_registry_config.config[idx].enable_private_endpoint, try(local.container_registry_config.config.enable_private_endpoint, false))
    } : {},
    # Container App
    local.container_app_config.enabled ? {
      for idx in range(local.container_app_config.count) :
      "container_app_${idx}" => {
        service_type  = "container_app"
        instance_idx  = idx
        subresources = ["ingress"]
        dns_zones     = ["privatelink.azurecontainerapps.io"]
        vnet_index    = try(local.container_app_config.config[idx].private_endpoint_vnet_index, try(local.container_app_config.config.private_endpoint_vnet_index, null))
        subnet_name   = try(local.container_app_config.config[idx].private_endpoint_subnet_name, try(local.container_app_config.config.private_endpoint_subnet_name, null))
      } if try(local.container_app_config.config[idx].enable_private_endpoint, try(local.container_app_config.config.enable_private_endpoint, false))
    } : {},
    # Event Hubs
    local.event_hubs_config.enabled ? {
      for idx in range(local.event_hubs_config.count) :
      "event_hubs_${idx}" => {
        service_type  = "event_hubs"
        instance_idx  = idx
        subresources = ["namespace"]
        dns_zones     = ["privatelink.servicebus.windows.net"]
        vnet_index    = try(local.event_hubs_config.config[idx].private_endpoint_vnet_index, try(local.event_hubs_config.config.private_endpoint_vnet_index, null))
        subnet_name   = try(local.event_hubs_config.config[idx].private_endpoint_subnet_name, try(local.event_hubs_config.config.private_endpoint_subnet_name, null))
      } if try(local.event_hubs_config.config[idx].enable_private_endpoint, try(local.event_hubs_config.config.enable_private_endpoint, false))
    } : {},
    # Redis Cache
    local.redis_cache_config.enabled ? {
      for idx in range(local.redis_cache_config.count) :
      "redis_cache_${idx}" => {
        service_type  = "redis_cache"
        instance_idx  = idx
        subresources = ["redisCache"]
        dns_zones     = ["privatelink.redis.cache.windows.net"]
        vnet_index    = try(local.redis_cache_config.config[idx].private_endpoint_vnet_index, try(local.redis_cache_config.config.private_endpoint_vnet_index, null))
        subnet_name   = try(local.redis_cache_config.config[idx].private_endpoint_subnet_name, try(local.redis_cache_config.config.private_endpoint_subnet_name, null))
      } if try(local.redis_cache_config.config[idx].enable_private_endpoint, try(local.redis_cache_config.config.enable_private_endpoint, false))
    } : {}
  )
  
  # Flatten services needing private endpoints into a list
  # Calculate unique index for each service based on its position
  auto_private_endpoints_list = [
    for idx, key in keys(local.services_needing_pe_config) : {
      key          = key
      service_type  = local.services_needing_pe_config[key].service_type
      instance_idx  = local.services_needing_pe_config[key].instance_idx
      subresources = local.services_needing_pe_config[key].subresources
      dns_zones    = local.services_needing_pe_config[key].dns_zones
      vnet_index   = local.services_needing_pe_config[key].vnet_index
      subnet_name  = local.services_needing_pe_config[key].subnet_name
      pe_index     = idx  # Unique index based on position in the map
    }
  ]
  
  # Get unique DNS zones needed for automatic private endpoints
  auto_pe_dns_zones = distinct(flatten([
    for service in local.auto_private_endpoints_list : service.dns_zones
  ]))
}

# Data source for existing resource group (when create_resource_group = false)
data "azurerm_resource_group" "existing" {
  count = var.create_resource_group ? 0 : 1
  name  = local.resource_group_name_used
}

# Resource Group (created when create_resource_group = true)
resource "azurerm_resource_group" "main" {
  count    = var.create_resource_group ? 1 : 0
  name     = local.resource_group_name_used
  location = var.location
  tags     = local.common_tags
}

# Storage Account Module
module "storage_account" {
  source = "./modules/storage_account"
  count  = local.storage_account_config.enabled ? local.storage_account_config.count : 0
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  resource_name       = local.generate_name.storage_account[count.index]
  # Support both single config object and array of configs for per-instance configuration
  config = try(
    local.storage_account_config.config[count.index],
    local.storage_account_config.config
  )
  tags = local.common_tags
}

# Virtual Network Module
module "virtual_network" {
  source = "./modules/virtual_network"
  count  = local.virtual_network_config.enabled ? local.virtual_network_config.count : 0
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  resource_name       = local.generate_name.virtual_network[count.index]
  # Support both single config object and array of configs for per-instance configuration
  config = try(
    # Try to access as array first (for per-instance configs)
    local.virtual_network_config.config[count.index],
    # Fall back to single config object (for uniform configs)
    local.virtual_network_config.config
  )
  tags = local.common_tags
}

# App Service Plan Module
module "app_service_plan" {
  source = "./modules/app_service_plan"
  count  = local.app_service_plan_config.enabled ? local.app_service_plan_config.count : 0
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  # Support both single config object and array of configs for per-instance configuration
  config = try(
    local.app_service_plan_config.config[count.index],
    local.app_service_plan_config.config
  )
  tags = local.common_tags
}

# App Service Module
module "app_service" {
  source = "./modules/app_service"
  count  = local.app_service_config.enabled ? local.app_service_config.count : 0
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  
  # Support both single config object and array of configs for per-instance configuration
  config = local.app_service_configs[count.index]
  
  app_service_plan_id = try(
    local.app_service_configs[count.index].app_service_plan_index != null && length(module.app_service_plan) > local.app_service_configs[count.index].app_service_plan_index ?
      module.app_service_plan[local.app_service_configs[count.index].app_service_plan_index].app_service_plan_id : null,
    local.app_service_plan_config.enabled && length(module.app_service_plan) > 0 ? module.app_service_plan[0].app_service_plan_id : null
  )
  
  # Resolve subnet_id from VNet/subnet reference if provided
  subnet_id = try(
    try(
      local.app_service_configs[count.index].vnet_index != null && local.app_service_configs[count.index].subnet_name != null && length(local.get_subnet_id) > 0 ? 
        local.get_subnet_id[local.app_service_configs[count.index].vnet_index][local.app_service_configs[count.index].subnet_name] : null,
      null
    ),
    try(local.app_service_configs[count.index].subnet_id, null)
  )
  
  app_service_plan_config = try(
    local.app_service_plan_config.config[try(local.app_service_configs[count.index].app_service_plan_index, 0)],
    local.app_service_plan_config.config
  )
  tags = local.common_tags
  
  depends_on = [module.app_service_plan, module.virtual_network]
}

# Key Vault Module
module "key_vault" {
  source = "./modules/key_vault"
  count  = local.key_vault_config.enabled ? local.key_vault_config.count : 0
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  resource_name       = local.generate_name.key_vault[count.index]
  # Support both single config object and array of configs for per-instance configuration
  config = try(
    local.key_vault_config.config[count.index],
    local.key_vault_config.config
  )
  tags = local.common_tags
}

# Container Registry Module
module "container_registry" {
  source = "./modules/container_registry"
  count  = local.container_registry_config.enabled ? local.container_registry_config.count : 0
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  resource_name       = local.generate_name.container_registry[count.index]
  # Support both single config object and array of configs for per-instance configuration
  config = try(
    local.container_registry_config.config[count.index],
    local.container_registry_config.config
  )
  tags = local.common_tags
}

# Kubernetes Cluster Module
# Auto-create Log Analytics workspaces for AKS clusters with container logs enabled
resource "azurerm_log_analytics_workspace" "aks_container_logs" {
  for_each = {
    for idx in range(local.kubernetes_cluster_config.enabled ? local.kubernetes_cluster_config.count : 0) :
    idx => local.kubernetes_cluster_configs[idx]
    if try(local.kubernetes_cluster_configs[idx].enable_container_logs, false) && 
       try(local.kubernetes_cluster_configs[idx].log_analytics_workspace_id, null) == null
  }

  name                = "${var.name_prefix}-${var.environment}-aks-law-${format("%02d", each.key)}"
  location            = var.location
  resource_group_name = local.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = local.common_tags
}

module "kubernetes_cluster" {
  source = "./modules/kubernetes_cluster"
  count  = local.kubernetes_cluster_config.enabled ? local.kubernetes_cluster_config.count : 0
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  resource_name       = local.generate_name.kubernetes_cluster[count.index]
  
  # Support both single config object and array of configs for per-instance configuration
  # Resolve Application Gateway reference for ingress-appgw addon if enabled
  config = merge(
    local.kubernetes_cluster_configs[count.index],
    # Resolve gateway_id from gateway_index if gateway_id and gateway_name are not provided
    # Prefer gateway_id over gateway_name for better reliability
    try(local.kubernetes_cluster_configs[count.index].enable_ingress_appgw, false) && 
       try(local.kubernetes_cluster_configs[count.index].ingress_appgw_gateway_id, null) == null &&
       try(local.kubernetes_cluster_configs[count.index].ingress_appgw_gateway_name, null) == null &&
       try(local.kubernetes_cluster_configs[count.index].ingress_appgw_gateway_index, null) != null &&
       length(module.application_gateway) > local.kubernetes_cluster_configs[count.index].ingress_appgw_gateway_index ? {
      ingress_appgw_gateway_id = module.application_gateway[local.kubernetes_cluster_configs[count.index].ingress_appgw_gateway_index].application_gateway_id
    } : {},
    # Resolve subnet_id from vnet_index/subnet_name if subnet_id and subnet_cidr are not provided
    try(local.kubernetes_cluster_configs[count.index].enable_ingress_appgw, false) && 
       try(local.kubernetes_cluster_configs[count.index].ingress_appgw_subnet_id, null) == null &&
       try(local.kubernetes_cluster_configs[count.index].ingress_appgw_subnet_cidr, null) == null &&
       try(local.kubernetes_cluster_configs[count.index].ingress_appgw_subnet_vnet_index, null) != null &&
       try(local.kubernetes_cluster_configs[count.index].ingress_appgw_subnet_name, null) != null &&
       length(local.get_subnet_id) > 0 ? {
      ingress_appgw_subnet_id = try(
        local.get_subnet_id[local.kubernetes_cluster_configs[count.index].ingress_appgw_subnet_vnet_index][local.kubernetes_cluster_configs[count.index].ingress_appgw_subnet_name],
        null
      )
    } : {}
  )
  
  # Resolve subnet_id from VNet/subnet reference if provided
  subnet_id = try(
    try(
      local.kubernetes_cluster_configs[count.index].vnet_index != null && local.kubernetes_cluster_configs[count.index].subnet_name != null && length(local.get_subnet_id) > 0 ? 
        local.get_subnet_id[local.kubernetes_cluster_configs[count.index].vnet_index][local.kubernetes_cluster_configs[count.index].subnet_name] : null,
      null
    ),
    try(local.kubernetes_cluster_configs[count.index].subnet_id, null)
  )
  
  # Pass subnet lookup map for additional node pools
  subnet_lookup = local.get_subnet_id
  
  # Resolve Log Analytics workspace ID for container logs
  # Use provided workspace ID, or use auto-created workspace, or null if not enabled
  log_analytics_workspace_id = try(
    # If a workspace ID is explicitly provided, use it
    local.kubernetes_cluster_configs[count.index].log_analytics_workspace_id,
    # Otherwise, if container logs are enabled and no explicit ID provided, use the auto-created workspace
    try(local.kubernetes_cluster_configs[count.index].enable_container_logs, false) && 
       try(local.kubernetes_cluster_configs[count.index].log_analytics_workspace_id, null) == null ? 
      try(azurerm_log_analytics_workspace.aks_container_logs[count.index].id, null) : null
  )
  
  tags   = local.common_tags
  
  depends_on = [
    module.virtual_network,
    azurerm_log_analytics_workspace.aks_container_logs,
    module.application_gateway
  ]
}

module "aks_backup" {
  source = "./modules/aks_backup"
  count  = local.aks_backup_config.enabled ? local.aks_backup_config.count : 0

  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  resource_name       = local.generate_name.aks_backup[count.index]
  storage_account_name = local.generate_name.aks_backup_storage[count.index]

  config = local.aks_backup_configs[count.index]

  kubernetes_cluster_id = module.kubernetes_cluster[local.aks_backup_cluster_indexes[count.index]].kubernetes_cluster_id
  kubernetes_cluster_identity_principal_id = module.kubernetes_cluster[local.aks_backup_cluster_indexes[count.index]].kubernetes_cluster_identity_principal_id

  tags = local.common_tags

  depends_on = [module.kubernetes_cluster]
}

# SQL Server Module
module "sql_server" {
  source = "./modules/sql_server"
  count  = local.sql_server_config.enabled ? local.sql_server_config.count : 0
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  resource_name       = local.generate_name.sql_server[count.index]
  
  # Support both single config object and array of configs for per-instance configuration
  config = local.sql_server_configs[count.index]
  
  # Resolve subnet_id from VNet/subnet reference if provided (for VNet rules)
  subnet_id = try(
    try(
      local.sql_server_configs[count.index].vnet_index != null && local.sql_server_configs[count.index].subnet_name != null && length(local.get_subnet_id) > 0 ? 
        local.get_subnet_id[local.sql_server_configs[count.index].vnet_index][local.sql_server_configs[count.index].subnet_name] : null,
      null
    ),
    try(local.sql_server_configs[count.index].subnet_id, null)
  )
  tags   = local.common_tags
  
  depends_on = [module.virtual_network]
}

# Function App Module
module "function_app" {
  source = "./modules/function_app"
  count  = local.function_app_config.enabled ? local.function_app_config.count : 0
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  resource_name       = local.generate_name.function_app[count.index]
  storage_account_name = local.generate_name.function_app_storage[count.index]
  
  # Support both single config object and array of configs for per-instance configuration
  config = local.function_app_configs[count.index]
  
  app_service_plan_id = try(
    local.function_app_configs[count.index].app_service_plan_index != null && length(module.app_service_plan) > local.function_app_configs[count.index].app_service_plan_index ?
      module.app_service_plan[local.function_app_configs[count.index].app_service_plan_index].app_service_plan_id : null,
    local.app_service_plan_config.enabled && length(module.app_service_plan) > 0 ? module.app_service_plan[0].app_service_plan_id : null
  )
  
  storage_account_id = try(
    local.function_app_configs[count.index].storage_account_index != null && length(module.storage_account) > local.function_app_configs[count.index].storage_account_index ?
      module.storage_account[local.function_app_configs[count.index].storage_account_index].storage_account_id : null,
    local.storage_account_config.enabled && length(module.storage_account) > 0 ? module.storage_account[0].storage_account_id : null
  )
  
  # Resolve subnet_id from VNet/subnet reference if provided
  subnet_id = try(
    try(
      local.function_app_configs[count.index].vnet_index != null && local.function_app_configs[count.index].subnet_name != null && length(local.get_subnet_id) > 0 ? 
        local.get_subnet_id[local.function_app_configs[count.index].vnet_index][local.function_app_configs[count.index].subnet_name] : null,
      null
    ),
    try(local.function_app_configs[count.index].subnet_id, null)
  )
  tags   = local.common_tags
  
  depends_on = [module.app_service_plan, module.storage_account, module.virtual_network]
}

# Log Analytics Workspace Module
module "log_analytics_workspace" {
  source = "./modules/log_analytics_workspace"
  count  = local.log_analytics_workspace_config.enabled ? local.log_analytics_workspace_config.count : 0
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  resource_name       = local.generate_name.log_analytics_workspace[count.index]
  # Support both single config object and array of configs for per-instance configuration
  config = try(
    local.log_analytics_workspace_config.config[count.index],
    local.log_analytics_workspace_config.config
  )
  tags = local.common_tags
}

# Virtual Machine Module
module "virtual_machine" {
  source = "./modules/virtual_machine"
  count  = local.virtual_machine_config.enabled ? local.virtual_machine_config.count : 0
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  resource_name       = local.generate_name.virtual_machine[count.index]
  os_disk_name        = local.generate_name.vm_os_disk[count.index]
  data_disk_name_base = local.generate_name.vm_data_disk[count.index]
  nic_name             = local.generate_name.network_interface[count.index]
  
  # Support both single config object and array of configs for per-instance configuration
  # If config is an array, use the index; otherwise use the single config object for all instances
  config = local.virtual_machine_configs[count.index]
  
  # Resolve subnet_id from VNet/subnet reference if provided
  subnet_id = try(
    # If vnet_index and subnet_name are provided, look up the subnet
    try(
      local.virtual_machine_configs[count.index].vnet_index != null && local.virtual_machine_configs[count.index].subnet_name != null && length(local.get_subnet_id) > 0 ? 
        local.get_subnet_id[local.virtual_machine_configs[count.index].vnet_index][local.virtual_machine_configs[count.index].subnet_name] : null,
      null
    ),
    # Otherwise use subnet_id directly if provided
    try(local.virtual_machine_configs[count.index].subnet_id, null)
  )
  tags   = local.common_tags
  
  depends_on = [module.virtual_network]
}

# Managed Disk Module
module "managed_disk" {
  source = "./modules/managed_disk"
  count  = local.managed_disk_config.enabled ? local.managed_disk_config.count : 0
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  resource_name       = local.generate_name.managed_disk[count.index]
  
  # Support both single config object and array of configs for per-instance configuration
  config = try(
    local.managed_disk_configs[count.index],
    local.managed_disk_config.config
  )
  tags = local.common_tags
}

# DNS Zone Module
module "dns_zone" {
  source = "./modules/dns_zone"
  count  = local.dns_zone_config.enabled ? local.dns_zone_config.count : 0
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  resource_name       = local.generate_name.dns_zone[count.index]
  
  # Support both single config object and array of configs for per-instance configuration
  config = try(
    local.dns_zone_configs[count.index],
    local.dns_zone_config.config
  )
  tags = local.common_tags
}

# VM Backup Module
module "vm_backup" {
  source = "./modules/vm_backup"
  count  = local.vm_backup_config.enabled ? local.vm_backup_config.count : 0

  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  resource_name       = local.generate_name.vm_backup[count.index]
  recovery_vault_name = local.generate_name.recovery_services_vault[count.index]

  config = local.vm_backup_configs[count.index]

  virtual_machine_id = module.virtual_machine[local.vm_backup_vm_indexes[count.index]].virtual_machine_id

  tags = local.common_tags

  depends_on = [module.virtual_machine]
}

# PostgreSQL Flexible Server Module
module "postgresql_flexible_server" {
  source = "./modules/postgresql_flexible_server"
  count  = local.postgresql_flexible_server_config.enabled ? local.postgresql_flexible_server_config.count : 0
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  resource_name       = local.generate_name.postgresql_flexible_server[count.index]
  
  # Support both single config object and array of configs for per-instance configuration
  config = local.postgresql_flexible_server_configs[count.index]
  
  # Resolve subnet_id from VNet/subnet reference if provided
  subnet_id = try(
    try(
      local.postgresql_flexible_server_configs[count.index].vnet_index != null && local.postgresql_flexible_server_configs[count.index].subnet_name != null && length(local.get_subnet_id) > 0 ? 
        local.get_subnet_id[local.postgresql_flexible_server_configs[count.index].vnet_index][local.postgresql_flexible_server_configs[count.index].subnet_name] : null,
      null
    ),
    try(local.postgresql_flexible_server_configs[count.index].subnet_id, null)
  )
  
  # Resolve private_dns_zone_id if using VNet integration
  # When subnet_id is provided, private_dns_zone_id is required
  # Can be specified by: 1) direct ID, 2) dns_zone_index, 3) auto-detect by zone name pattern
  private_dns_zone_id = try(
    local.postgresql_flexible_server_configs[count.index].private_dns_zone_id,
    try(
      # If dns_zone_index is specified, use that index
      local.postgresql_flexible_server_configs[count.index].dns_zone_index != null && length(module.private_dns_zone) > local.postgresql_flexible_server_configs[count.index].dns_zone_index ?
        module.private_dns_zone[local.postgresql_flexible_server_configs[count.index].dns_zone_index].private_dns_zone_id : null,
      # Otherwise, try to find PostgreSQL DNS zone by name pattern
      length(module.private_dns_zone) > 0 && try(
        local.postgresql_flexible_server_configs[count.index].vnet_index != null && local.postgresql_flexible_server_configs[count.index].subnet_name != null,
        false
      ) ? (
        # Find DNS zone with "postgres" in the name, or use first available
        length([for i, zone in module.private_dns_zone : i if length(regexall("postgres", zone.private_dns_zone_name)) > 0]) > 0 ?
          module.private_dns_zone[[for i, zone in module.private_dns_zone : i if length(regexall("postgres", zone.private_dns_zone_name)) > 0][0]].private_dns_zone_id :
          module.private_dns_zone[0].private_dns_zone_id
      ) : null
    )
  )
  
  tags   = local.common_tags
  
  depends_on = [module.virtual_network, module.private_dns_zone, module.private_dns_zone_link]
}

# MySQL Flexible Server Module
module "mysql_flexible_server" {
  source = "./modules/mysql_flexible_server"
  count  = local.mysql_flexible_server_config.enabled ? local.mysql_flexible_server_config.count : 0
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  
  # Support both single config object and array of configs for per-instance configuration
  config = local.mysql_flexible_server_configs[count.index]
  
  # Resolve subnet_id from VNet/subnet reference if provided
  subnet_id = try(
    try(
      local.mysql_flexible_server_configs[count.index].vnet_index != null && local.mysql_flexible_server_configs[count.index].subnet_name != null && length(local.get_subnet_id) > 0 ? 
        local.get_subnet_id[local.mysql_flexible_server_configs[count.index].vnet_index][local.mysql_flexible_server_configs[count.index].subnet_name] : null,
      null
    ),
    try(local.mysql_flexible_server_configs[count.index].subnet_id, null)
  )
  
  # Resolve private_dns_zone_id if using VNet integration
  # When subnet_id is provided, private_dns_zone_id is required
  # Can be specified by: 1) direct ID, 2) dns_zone_index, 3) auto-detect by zone name pattern
  private_dns_zone_id = try(
    local.mysql_flexible_server_configs[count.index].private_dns_zone_id,
    try(
      # If dns_zone_index is specified, use that index
      local.mysql_flexible_server_configs[count.index].dns_zone_index != null && length(module.private_dns_zone) > local.mysql_flexible_server_configs[count.index].dns_zone_index ?
        module.private_dns_zone[local.mysql_flexible_server_configs[count.index].dns_zone_index].private_dns_zone_id : null,
      # Otherwise, try to find MySQL DNS zone by name pattern
      length(module.private_dns_zone) > 0 && try(
        local.mysql_flexible_server_configs[count.index].vnet_index != null && local.mysql_flexible_server_configs[count.index].subnet_name != null,
        false
      ) ? (
        # Find DNS zone with "mysql" in the name, or use first available
        length([for i, zone in module.private_dns_zone : i if length(regexall("mysql", zone.private_dns_zone_name)) > 0]) > 0 ?
          module.private_dns_zone[[for i, zone in module.private_dns_zone : i if length(regexall("mysql", zone.private_dns_zone_name)) > 0][0]].private_dns_zone_id :
          module.private_dns_zone[0].private_dns_zone_id
      ) : null
    )
  )
  
  tags   = local.common_tags
  
  depends_on = [module.virtual_network, module.private_dns_zone, module.private_dns_zone_link]
}

# Cosmos DB Module
module "cosmosdb" {
  source = "./modules/cosmosdb"
  count  = local.cosmosdb_config.enabled ? local.cosmosdb_config.count : 0
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  
  # Support both single config object and array of configs for per-instance configuration
  config = local.cosmosdb_configs[count.index]
  
  # Resolve subnet_ids from VNet/subnet references if provided
  subnet_ids = try(
    try(
      local.cosmosdb_configs[count.index].vnet_indexes != null && local.cosmosdb_configs[count.index].subnet_names != null && length(local.get_subnet_id) > 0 ? 
        [for i in range(length(local.cosmosdb_configs[count.index].vnet_indexes)) : 
          local.get_subnet_id[local.cosmosdb_configs[count.index].vnet_indexes[i]][local.cosmosdb_configs[count.index].subnet_names[i]]
        ] : [],
      []
    ),
    try(local.cosmosdb_configs[count.index].subnet_ids, [])
  )
  tags   = local.common_tags
  
  depends_on = [module.virtual_network]
}

# Azure Firewall Module
module "azure_firewall" {
  source = "./modules/azure_firewall"
  count  = local.azure_firewall_config.enabled ? local.azure_firewall_config.count : 0
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  
  config = local.azure_firewall_configs[count.index]
  
  subnet_id = try(
    try(
      local.azure_firewall_configs[count.index].vnet_index != null && local.azure_firewall_configs[count.index].subnet_name != null && length(local.get_subnet_id) > 0 ? 
        local.get_subnet_id[local.azure_firewall_configs[count.index].vnet_index][local.azure_firewall_configs[count.index].subnet_name] : null,
      null
    ),
    try(local.azure_firewall_configs[count.index].subnet_id, null)
  )
  tags   = local.common_tags
  
  depends_on = [module.virtual_network]
}

# Application Gateway Module
module "application_gateway" {
  source = "./modules/application_gateway"
  count  = local.application_gateway_config.enabled ? local.application_gateway_config.count : 0
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  resource_name       = local.generate_name.application_gateway[count.index]
  
  config = local.application_gateway_configs[count.index]
  
  subnet_id = try(
    try(
      local.application_gateway_configs[count.index].vnet_index != null && local.application_gateway_configs[count.index].subnet_name != null && length(local.get_subnet_id) > 0 ? 
        local.get_subnet_id[local.application_gateway_configs[count.index].vnet_index][local.application_gateway_configs[count.index].subnet_name] : null,
      null
    ),
    try(local.application_gateway_configs[count.index].subnet_id, null)
  )
  tags   = local.common_tags
  
  depends_on = [module.virtual_network]
}

# Bastion Module
module "bastion" {
  source = "./modules/bastion"
  count  = local.bastion_config.enabled ? local.bastion_config.count : 0
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  
  config = local.bastion_configs[count.index]
  
  subnet_id = try(
    try(
      local.bastion_configs[count.index].vnet_index != null && local.bastion_configs[count.index].subnet_name != null && length(local.get_subnet_id) > 0 ? 
        local.get_subnet_id[local.bastion_configs[count.index].vnet_index][local.bastion_configs[count.index].subnet_name] : null,
      null
    ),
    try(local.bastion_configs[count.index].subnet_id, null)
  )
  tags   = local.common_tags
  
  depends_on = [module.virtual_network]
}

# Load Balancer Module
module "load_balancer" {
  source = "./modules/load_balancer"
  count  = local.load_balancer_config.enabled ? local.load_balancer_config.count : 0
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  
  config = local.load_balancer_configs[count.index]
  
  subnet_id = try(
    try(
      local.load_balancer_configs[count.index].vnet_index != null && local.load_balancer_configs[count.index].subnet_name != null && length(local.get_subnet_id) > 0 ? 
        local.get_subnet_id[local.load_balancer_configs[count.index].vnet_index][local.load_balancer_configs[count.index].subnet_name] : null,
      null
    ),
    try(local.load_balancer_configs[count.index].subnet_id, null)
  )
  tags   = local.common_tags
  
  depends_on = [module.virtual_network]
}

# Network Security Group Module
module "network_security_group" {
  source = "./modules/network_security_group"
  count  = local.network_security_group_config.enabled ? local.network_security_group_config.count : 0
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  config              = try(
    local.network_security_group_config.config[count.index],
    local.network_security_group_config.config
  )
  tags = local.common_tags
}

# Private DNS Zone Module
module "private_dns_zone" {
  source = "./modules/private_dns_zone"
  count  = local.private_dns_zone_config.enabled ? local.private_dns_zone_config.count : 0
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  config              = try(
    local.private_dns_zone_config.config[count.index],
    local.private_dns_zone_config.config
  )
  tags = local.common_tags
}

# Private DNS Zone Link Module
module "private_dns_zone_link" {
  source = "./modules/private_dns_zone_link"
  count  = local.private_dns_zone_link_config.enabled ? local.private_dns_zone_link_config.count : 0
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  
  config = local.private_dns_zone_link_configs[count.index]
  
  private_dns_zone_name = try(
    local.private_dns_zone_link_configs[count.index].dns_zone_index != null && length(module.private_dns_zone) > local.private_dns_zone_link_configs[count.index].dns_zone_index ?
      module.private_dns_zone[local.private_dns_zone_link_configs[count.index].dns_zone_index].private_dns_zone_name : null,
    local.private_dns_zone_link_configs[count.index].private_dns_zone_name
  )
  
  # Get resource group name from the DNS zone module if dns_zone_index is used
  # Otherwise, use the one specified in the link config (for zones not managed by private_dns_zone module)
  # If neither is provided, default to the deployment resource group
  private_dns_zone_resource_group_name = try(
    local.private_dns_zone_link_configs[count.index].dns_zone_index != null && length(module.private_dns_zone) > local.private_dns_zone_link_configs[count.index].dns_zone_index ?
      module.private_dns_zone[local.private_dns_zone_link_configs[count.index].dns_zone_index].private_dns_zone_resource_group_name : (
        try(local.private_dns_zone_link_configs[count.index].private_dns_zone_resource_group_name, null)
      ),
    null
  )
  
  virtual_network_id = try(
    local.private_dns_zone_link_configs[count.index].vnet_index != null && length(module.virtual_network) > local.private_dns_zone_link_configs[count.index].vnet_index ?
      module.virtual_network[local.private_dns_zone_link_configs[count.index].vnet_index].virtual_network_id : null,
    local.private_dns_zone_link_configs[count.index].virtual_network_id
  )
  tags   = local.common_tags
  
  depends_on = [module.private_dns_zone, module.virtual_network]
}

# Private Endpoint Module
module "private_endpoint" {
  source = "./modules/private_endpoint"
  count  = local.private_endpoint_config.enabled ? local.private_endpoint_config.count : 0
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  resource_name       = local.generate_name.private_endpoint[count.index]
  
  config = local.private_endpoint_configs[count.index]
  
  subnet_id = try(
    try(
      local.private_endpoint_configs[count.index].vnet_index != null && local.private_endpoint_configs[count.index].subnet_name != null && length(local.get_subnet_id) > 0 ? 
        local.get_subnet_id[local.private_endpoint_configs[count.index].vnet_index][local.private_endpoint_configs[count.index].subnet_name] : null,
      null
    ),
    try(local.private_endpoint_configs[count.index].subnet_id, null)
  )
  
  # Resolve private_dns_zone_ids from module references if provided
  # Can reference DNS zones by index (dns_zone_indexes) or directly via private_dns_zone_ids
  private_dns_zone_ids = try(
    local.private_endpoint_configs[count.index].private_dns_zone_ids,
    try(
      local.private_endpoint_configs[count.index].dns_zone_indexes != null && length(module.private_dns_zone) > 0 ? [
        for idx in local.private_endpoint_configs[count.index].dns_zone_indexes : 
          module.private_dns_zone[idx].private_dns_zone_id
      ] : [],
      []
    )
  )
  
  tags   = local.common_tags
  
  depends_on = [module.virtual_network, module.private_dns_zone, module.private_dns_zone_link]
}

# Public IP Module
module "public_ip" {
  source = "./modules/public_ip"
  count  = local.public_ip_config.enabled ? local.public_ip_config.count : 0
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  resource_name       = local.generate_name.public_ip[count.index]
  config              = try(
    local.public_ip_config.config[count.index],
    local.public_ip_config.config
  )
  tags = local.common_tags
}

# VNet Peering Module
module "vnet_peering" {
  source = "./modules/vnet_peering"
  count  = local.vnet_peering_config.enabled ? local.vnet_peering_config.count : 0
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  
  config = local.vnet_peering_configs[count.index]
  
  local_virtual_network_name = try(
    local.vnet_peering_configs[count.index].local_vnet_index != null && length(module.virtual_network) > local.vnet_peering_configs[count.index].local_vnet_index ?
      module.virtual_network[local.vnet_peering_configs[count.index].local_vnet_index].virtual_network_name : null,
    local.vnet_peering_configs[count.index].local_virtual_network_name
  )
  tags   = local.common_tags
  
  depends_on = [module.virtual_network]
}

# VPN Gateway Module
module "vpn_gateway" {
  source = "./modules/vpn_gateway"
  count  = local.vpn_gateway_config.enabled ? local.vpn_gateway_config.count : 0
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  
  config = local.vpn_gateway_configs[count.index]
  
  subnet_id = try(
    try(
      local.vpn_gateway_configs[count.index].vnet_index != null && local.vpn_gateway_configs[count.index].subnet_name != null && length(local.get_subnet_id) > 0 ? 
        local.get_subnet_id[local.vpn_gateway_configs[count.index].vnet_index][local.vpn_gateway_configs[count.index].subnet_name] : null,
      null
    ),
    try(local.vpn_gateway_configs[count.index].subnet_id, null)
  )
  tags   = local.common_tags
  
  depends_on = [module.virtual_network]
}

# Container App Module
module "container_app" {
  source = "./modules/container_app"
  count  = local.container_app_config.enabled ? local.container_app_config.count : 0
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  
  config = local.container_app_configs[count.index]
  
  subnet_id = try(
    try(
      local.container_app_configs[count.index].vnet_index != null && local.container_app_configs[count.index].subnet_name != null && length(local.get_subnet_id) > 0 ? 
        local.get_subnet_id[local.container_app_configs[count.index].vnet_index][local.container_app_configs[count.index].subnet_name] : null,
      null
    ),
    try(local.container_app_configs[count.index].subnet_id, null)
  )
  tags   = local.common_tags
  
  depends_on = [module.virtual_network]
}

# Recovery Vault Module
module "recovery_vault" {
  source = "./modules/recovery_vault"
  count  = local.recovery_vault_config.enabled ? local.recovery_vault_config.count : 0
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  config              = try(
    local.recovery_vault_config.config[count.index],
    local.recovery_vault_config.config
  )
  tags = local.common_tags
}

# Event Hubs Module
module "event_hubs" {
  source = "./modules/event_hubs"
  count  = local.event_hubs_config.enabled ? local.event_hubs_config.count : 0
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  config              = try(
    local.event_hubs_config.config[count.index],
    local.event_hubs_config.config
  )
  tags = local.common_tags
}

# Redis Cache Module
module "redis_cache" {
  source = "./modules/redis_cache"
  count  = local.redis_cache_config.enabled ? local.redis_cache_config.count : 0
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = count.index
  
  config = local.redis_cache_configs[count.index]
  
  subnet_id = try(
    try(
      local.redis_cache_configs[count.index].vnet_index != null && local.redis_cache_configs[count.index].subnet_name != null && length(local.get_subnet_id) > 0 ? 
        local.get_subnet_id[local.redis_cache_configs[count.index].vnet_index][local.redis_cache_configs[count.index].subnet_name] : null,
      null
    ),
    try(local.redis_cache_configs[count.index].subnet_id, null)
  )
  tags   = local.common_tags
  
  depends_on = [module.virtual_network]
}

# Automatic Private DNS Zones for services with private endpoints
# Create DNS zones that are needed but not already created manually
module "auto_private_dns_zone" {
  source = "./modules/private_dns_zone"
  for_each = {
    for zone_name in local.auto_pe_dns_zones : zone_name => zone_name
    if !contains([for z in module.private_dns_zone : z.private_dns_zone_name], zone_name)
  }
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = 0  # Not used when using for_each
  
  config = {
    zone_name = each.value
  }
  
  tags = local.common_tags
}

# Automatic Private DNS Zone Links for auto-created DNS zones
# Link each auto-created DNS zone to the VNet(s) that need it
# Create links directly as resources since we're using for_each
resource "azurerm_private_dns_zone_virtual_network_link" "auto_pe" {
  for_each = {
    for combo in flatten([
      for zone_name in local.auto_pe_dns_zones : [
        for service in local.auto_private_endpoints_list : {
          zone_name  = zone_name
          vnet_index = service.vnet_index
          key        = "${zone_name}_${service.vnet_index}"
        } if service.vnet_index != null && contains(service.dns_zones, zone_name)
      ]
    ]) : combo.key => combo
    if !contains([for z in module.private_dns_zone : z.private_dns_zone_name], combo.zone_name)
  }
  
  name                  = "${var.name_prefix}-${var.environment}-auto-dns-link-${replace(each.value.zone_name, ".", "-")}-${each.value.vnet_index}"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = each.value.zone_name
  virtual_network_id    = length(module.virtual_network) > each.value.vnet_index ? module.virtual_network[each.value.vnet_index].virtual_network_id : null
  registration_enabled   = false
  
  tags = local.common_tags
  
  depends_on = [module.auto_private_dns_zone, module.virtual_network]
}

# Automatic Private Endpoints for services with enable_private_endpoint = true
module "auto_private_endpoint" {
  source = "./modules/private_endpoint"
  for_each = {
    for service in local.auto_private_endpoints_list : service.key => service
    if service.vnet_index != null && service.subnet_name != null
  }
  
  resource_group_name = local.resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  environment         = var.environment
  index               = each.value.pe_index  # Use unique index per service
  resource_name       = try(local.generate_name.private_endpoint[each.value.pe_index], "${var.name_prefix}-${var.environment}-pe-${format("%02d", each.value.pe_index + 1)}")
  
  config = {
    target_resource_id = each.value.service_type == "storage_account" ? module.storage_account[each.value.instance_idx].storage_account_id : (each.value.service_type == "key_vault" ? module.key_vault[each.value.instance_idx].key_vault_id : (each.value.service_type == "sql_server" ? module.sql_server[each.value.instance_idx].sql_server_id : (each.value.service_type == "cosmosdb" ? module.cosmosdb[each.value.instance_idx].cosmosdb_account_id : (each.value.service_type == "container_registry" ? module.container_registry[each.value.instance_idx].container_registry_id : (each.value.service_type == "container_app" ? module.container_app[each.value.instance_idx].container_app_environment_id : (each.value.service_type == "event_hubs" ? module.event_hubs[each.value.instance_idx].event_hub_namespace_id : (each.value.service_type == "redis_cache" ? module.redis_cache[each.value.instance_idx].redis_cache_id : null)))))))
    is_manual_connection = false
    subresource_names    = each.value.subresources
    vnet_index           = each.value.vnet_index
    subnet_name          = each.value.subnet_name
    subnet_id            = null
    private_dns_zone_ids  = null
    dns_zone_indexes      = null
  }
  
  subnet_id = try(
    local.get_subnet_id[each.value.vnet_index][each.value.subnet_name],
    null
  )
  
  # Resolve DNS zone IDs from auto-created or existing DNS zones
  private_dns_zone_ids = [
    for zone_name in each.value.dns_zones : 
      # Check if zone exists in manually created zones
      try(
        [for z in module.private_dns_zone : z.private_dns_zone_id if z.private_dns_zone_name == zone_name][0],
        # Otherwise use auto-created zone
        try(module.auto_private_dns_zone[zone_name].private_dns_zone_id, null)
      )
  ]
  
  tags = local.common_tags
  
  depends_on = [
    module.storage_account,
    module.key_vault,
    module.sql_server,
    module.cosmosdb,
    module.container_registry,
    module.container_app,
    module.event_hubs,
    module.redis_cache,
    module.auto_private_dns_zone,
    azurerm_private_dns_zone_virtual_network_link.auto_pe,
    module.virtual_network
  ]
}

