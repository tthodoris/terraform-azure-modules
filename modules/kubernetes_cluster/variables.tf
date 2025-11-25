variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "index" {
  description = "Index for this instance"
  type        = number
}

variable "resource_name" {
  description = "Pre-generated resource name from naming convention"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Subnet ID for the default node pool (optional)"
  type        = string
  default     = null
}

variable "subnet_lookup" {
  description = "Map of subnet IDs by VNet index and subnet name: subnet_lookup[vnet_index][subnet_name] = subnet_id"
  type        = map(map(string))
  default     = {}
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for container logs (optional)"
  type        = string
  default     = null
}

variable "config" {
  description = "Configuration object for the Kubernetes cluster"
  type = object({
    kubernetes_version   = optional(string)
    node_pool_name       = string
    node_count           = number
    vm_size              = string
    os_disk_size_gb      = number
    enable_auto_scaling  = bool
    min_count            = optional(number)
    max_count            = optional(number)
    vnet_index           = optional(number)
    subnet_name          = optional(string)
    subnet_id            = optional(string)
    zones                = optional(list(string))  # Availability zones for default node pool, e.g., ["1", "2", "3"]
    # SKU configuration
    sku_tier             = optional(string, "Free")  # "Free" or "Paid" (Premium)
    # Network configuration
    network_plugin       = optional(string, "azure")  # "azure" (Azure CNI) or "kubenet"
    network_plugin_mode  = optional(string)  # "overlay" (required when using pod_cidr with azure plugin)
    network_policy       = optional(string)  # "calico" or "azure" (only for Azure CNI)
    pod_cidr             = optional(string)  # e.g., "172.25.0.0/16" (Pod CIDR for Azure CNI)
    service_cidr         = optional(string)  # e.g., "10.0.0.0/16"
    dns_service_ip       = optional(string)  # e.g., "10.0.0.10" (must be within service_cidr)
    docker_bridge_cidr   = optional(string)  # e.g., "172.17.0.1/16"
    # Private cluster configuration
    private_cluster_enabled = optional(bool, false)  # Enable private cluster mode
    private_dns_zone_id    = optional(string)  # Private DNS zone ID for private cluster (optional, Azure will create one if not specified)
    # Container logs configuration
    enable_container_logs = optional(bool, false)  # Enable container logs (creates Log Analytics workspace if true)
    log_analytics_workspace_id = optional(string)  # Existing Log Analytics workspace ID (optional, will create one if enable_container_logs is true and this is not provided)
    # Ingress Application Gateway (AGIC) addon configuration
    enable_ingress_appgw           = optional(bool, false)  # Enable ingress-appgw addon (Application Gateway Ingress Controller)
    ingress_appgw_gateway_id       = optional(string)  # Application Gateway ID (required if enable_ingress_appgw is true and gateway_name/gateway_index are not provided)
    ingress_appgw_gateway_name     = optional(string)  # Application Gateway name (required if enable_ingress_appgw is true and gateway_id/gateway_index are not provided)
    ingress_appgw_gateway_index   = optional(number)  # Application Gateway module index (alternative to gateway_id/gateway_name)
    ingress_appgw_subnet_cidr      = optional(string)  # Subnet CIDR for Application Gateway (required if enable_ingress_appgw is true and subnet_id/subnet references are not provided)
    ingress_appgw_subnet_id        = optional(string)  # Subnet ID for Application Gateway (alternative to subnet_cidr)
    ingress_appgw_subnet_vnet_index = optional(number)  # VNet index for Application Gateway subnet (used with subnet_name)
    ingress_appgw_subnet_name      = optional(string)  # Subnet name for Application Gateway (used with subnet_vnet_index)
    # Additional node pools configuration
    additional_node_pools = optional(list(object({
      name                = string
      node_count          = number
      vm_size             = string
      os_disk_size_gb     = number
      enable_auto_scaling = bool
      min_count           = optional(number)
      max_count           = optional(number)
      vnet_index          = optional(number)
      subnet_name         = optional(string)
      subnet_id           = optional(string)
      zones               = optional(list(string))  # Availability zones for this node pool, e.g., ["1", "2", "3"]
      mode                = optional(string, "User")  # User or System
      node_labels         = optional(map(string))
      node_taints         = optional(list(string))
    })), [])
  })
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

