resource "azurerm_kubernetes_cluster" "main" {
  name                = var.resource_name != "" ? var.resource_name : "${var.name_prefix}-${var.environment}-aks-${format("%02d", var.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.resource_name != "" ? substr(replace(var.resource_name, "-", ""), 0, min(54, length(replace(var.resource_name, "-", "")))) : "${var.name_prefix}${var.environment}aks${format("%02d", var.index + 1)}"
  kubernetes_version  = var.config.kubernetes_version
  sku_tier            = try(var.config.sku_tier, "Free")

  default_node_pool {
    name            = var.config.node_pool_name
    node_count      = var.config.enable_auto_scaling ? null : var.config.node_count
    vm_size         = var.config.vm_size
    os_disk_size_gb = var.config.os_disk_size_gb
    min_count       = var.config.enable_auto_scaling ? var.config.min_count : null
    max_count       = var.config.enable_auto_scaling ? var.config.max_count : null
    vnet_subnet_id  = var.subnet_id
    zones           = try(var.config.zones, null)
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin      = var.config.network_plugin
    network_policy      = try(var.config.network_policy, null)
    network_plugin_mode = try(var.config.network_plugin_mode, null)
    pod_cidr            = try(var.config.pod_cidr, null)
    service_cidr        = try(var.config.service_cidr, null)
    dns_service_ip      = try(var.config.dns_service_ip, null)
  }

  # Private cluster configuration
  private_cluster_enabled = try(var.config.private_cluster_enabled, false)
  private_dns_zone_id     = try(var.config.private_dns_zone_id, null)

  # Container logs configuration (OMS Agent)
  dynamic "oms_agent" {
    for_each = try(var.config.enable_container_logs, false) && var.log_analytics_workspace_id != null ? [1] : []
    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  # Ingress Application Gateway (AGIC) addon configuration
  dynamic "ingress_application_gateway" {
    for_each = try(var.config.enable_ingress_appgw, false) ? [1] : []
    content {
      gateway_id   = try(var.config.ingress_appgw_gateway_id, null)
      gateway_name = try(var.config.ingress_appgw_gateway_name, null)
      subnet_cidr  = try(var.config.ingress_appgw_subnet_cidr, null)
      subnet_id    = try(var.config.ingress_appgw_subnet_id, null)
    }
  }

  tags = var.tags
}

# Additional Node Pools
resource "azurerm_kubernetes_cluster_node_pool" "additional" {
  for_each = {
    for idx, pool in var.config.additional_node_pools : pool.name => {
      index      = idx
      pool_config = pool
    }
  }

  name                  = each.value.pool_config.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  node_count            = each.value.pool_config.enable_auto_scaling ? null : each.value.pool_config.node_count
  vm_size               = each.value.pool_config.vm_size
  os_disk_size_gb       = each.value.pool_config.os_disk_size_gb
  min_count             = each.value.pool_config.enable_auto_scaling ? each.value.pool_config.min_count : null
  max_count             = each.value.pool_config.enable_auto_scaling ? each.value.pool_config.max_count : null
  mode                  = each.value.pool_config.mode
  node_labels           = try(each.value.pool_config.node_labels, null)
  node_taints           = try(each.value.pool_config.node_taints, null)
  zones                 = try(each.value.pool_config.zones, null)

  # Resolve subnet_id for this node pool
  vnet_subnet_id = try(
    try(
      each.value.pool_config.vnet_index != null && each.value.pool_config.subnet_name != null && length(var.subnet_lookup) > 0 ? 
        try(var.subnet_lookup[each.value.pool_config.vnet_index][each.value.pool_config.subnet_name], null) : null,
      null
    ),
    try(each.value.pool_config.subnet_id, null)
  )

  tags = var.tags
}

