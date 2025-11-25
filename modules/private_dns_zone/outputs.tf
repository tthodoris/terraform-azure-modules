output "private_dns_zone_id" {
  description = "ID of the Private DNS Zone"
  value       = local.private_dns_zone_id
}

output "private_dns_zone_name" {
  description = "Name of the Private DNS Zone"
  value       = local.private_dns_zone_name
}

output "private_dns_zone_resource_group_name" {
  description = "Resource group name where the Private DNS Zone exists"
  value       = local.private_dns_zone_rg_name
}

