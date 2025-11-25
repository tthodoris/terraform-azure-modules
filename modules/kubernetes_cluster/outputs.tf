output "kubernetes_cluster_id" {
  description = "ID of the Kubernetes cluster"
  value       = azurerm_kubernetes_cluster.main.id
}

output "kubernetes_cluster_name" {
  description = "Name of the Kubernetes cluster"
  value       = azurerm_kubernetes_cluster.main.name
}

output "kubernetes_cluster_fqdn" {
  description = "FQDN of the Kubernetes cluster"
  value       = azurerm_kubernetes_cluster.main.fqdn
}

output "kube_config" {
  description = "Kube config for the cluster"
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}

output "kubernetes_cluster_identity_principal_id" {
  description = "Principal ID of the AKS managed identity"
  value       = try(azurerm_kubernetes_cluster.main.identity[0].principal_id, null)
}

output "node_pools" {
  description = "Map of additional node pools"
  value = {
    for name, pool in azurerm_kubernetes_cluster_node_pool.additional : name => {
      id         = pool.id
      name       = pool.name
      node_count = pool.node_count
      vm_size    = pool.vm_size
    }
  }
}

