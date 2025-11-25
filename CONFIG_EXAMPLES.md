# Configuration Examples

## Per-Instance Configuration

You can configure different settings for each instance by using an **array of config objects** instead of a single config object.

## Using Existing Private DNS Zones

If a Private DNS Zone already exists in another resource group, you can link it to your VNet without creating a new zone.

### Example 1: Link to Existing DNS Zone (Managed by private_dns_zone module)

When the zone is referenced through the `private_dns_zone` module, the resource group is automatically retrieved from the module:

```json
{
  "modules": {
    "private_dns_zone": {
      "enabled": true,
      "count": 1,
      "config": [
        {
          "zone_name": "privatelink.postgres.database.azure.com",
          "use_existing_zone": true,
          "existing_zone_resource_group_name": "Existing-RG-Name",
          "existing_zone_name": "privatelink.postgres.database.azure.com"
        }
      ]
    },
    "private_dns_zone_link": {
      "enabled": true,
      "count": 1,
      "config": [
        {
          "registration_enabled": false,
          "vnet_index": 0,
          "dns_zone_index": 0
        }
      ]
    }
  }
}
```

**Note:** When using `dns_zone_index`, the resource group name is automatically retrieved from the `private_dns_zone` module - you don't need to specify it in the link config.

### Example 2: Link to Existing DNS Zone (NOT managed by private_dns_zone module)

If you want to link to a zone that's not managed by the `private_dns_zone` module at all, specify the zone name and resource group directly in the link config:

```json
{
  "modules": {
    "private_dns_zone": {
      "enabled": false
    },
    "private_dns_zone_link": {
      "enabled": true,
      "count": 1,
      "config": [
        {
          "registration_enabled": false,
          "vnet_index": 0,
          "private_dns_zone_name": "privatelink.postgres.database.azure.com",
          "private_dns_zone_resource_group_name": "Existing-RG-Name"
        }
      ]
    }
  }
}
```

**Note:** 
- When `use_existing_zone` is `true` in the `private_dns_zone` module, it uses a data source to reference the existing zone
- `existing_zone_resource_group_name` specifies the resource group where the zone exists
- `existing_zone_name` is optional - if not provided, `zone_name` will be used
- The link will be created in the same resource group as the DNS zone (not your deployment resource group)
- If using `dns_zone_index`, the resource group is automatically retrieved - no need to specify it in the link config

### Example: Virtual Machines with Different Sizes

To create 2 VMs with different VM sizes:

```json
{
  "modules": {
    "virtual_machine": {
      "enabled": true,
      "count": 2,
      "config": [
        {
          "vm_size": "Standard_B2s",
          "os_disk_type": "Premium_LRS",
          "os_disk_size_gb": 30,
          "admin_username": "azureuser",
          "disable_password_authentication": true,
          "publisher": "Canonical",
          "offer": "0001-com-ubuntu-server-jammy",
          "sku": "22_04-lts-gen2",
          "version": "latest",
          "public_ip_enabled": true,
          "public_ip_allocation_method": "Static",
          "public_ip_sku": "Standard"
        },
        {
          "vm_size": "Standard_D2s_v3",
          "os_disk_type": "Premium_LRS",
          "os_disk_size_gb": 50,
          "admin_username": "azureuser",
          "disable_password_authentication": true,
          "publisher": "Canonical",
          "offer": "0001-com-ubuntu-server-jammy",
          "sku": "22_04-lts-gen2",
          "version": "latest",
          "public_ip_enabled": true,
          "public_ip_allocation_method": "Static",
          "public_ip_sku": "Standard"
        }
      ]
    }
  }
}
```

This will create:
- VM 0: Standard_B2s with 30GB disk
- VM 1: Standard_D2s_v3 with 50GB disk

### Example: Uniform Configuration (Single Object)

For all instances to have the same configuration, use a **single config object**:

```json
{
  "modules": {
    "virtual_machine": {
      "enabled": true,
      "count": 3,
      "config": {
        "vm_size": "Standard_B2s",
        "os_disk_type": "Premium_LRS",
        "os_disk_size_gb": 30,
        "admin_username": "azureuser",
        "disable_password_authentication": true,
        "publisher": "Canonical",
        "offer": "0001-com-ubuntu-server-jammy",
        "sku": "22_04-lts-gen2",
        "version": "latest",
        "public_ip_enabled": true,
        "public_ip_allocation_method": "Static",
        "public_ip_sku": "Standard"
      }
    }
  }
}
```

This will create 3 identical VMs, all with Standard_B2s.

## Notes

- **Array format**: Use `config: [...]` for per-instance configuration
- **Object format**: Use `config: {...}` for uniform configuration (applies to all instances)
- The array length should match or exceed the `count` value
- If the array has fewer elements than `count`, the last element will be reused for remaining instances

## AKS Backup Example

Use the `aks_backup` module to enable Azure Backup for an AKS cluster that was deployed via the `kubernetes_cluster` module. Each backup instance targets an existing cluster (referenced by `kubernetes_cluster_index`) and creates the Azure Backup vault, policy, trusted access binding, backup extension, and backup instance automatically.

Minimal example:

```json
{
  "modules": {
    "kubernetes_cluster": {
      "enabled": true,
      "count": 1,
      "config": {
        "node_pool_name": "default",
        "node_count": 3,
        "vm_size": "Standard_D2s_v3",
        "os_disk_size_gb": 30,
        "enable_auto_scaling": false,
        "vnet_index": 0,
        "subnet_name": "aks-subnet"
      }
    },
    "aks_backup": {
      "enabled": true,
      "count": 1,
      "config": {
        "kubernetes_cluster_index": 0,
        "snapshot_resource_group_name": "myaks-snapshots",
        "snapshot_resource_group_location": "eastus",
        "backup_vault_name": "myaks-backup-vault",
        "backup_policy_name": "myaks-daily-policy",
        "backup_instance_name": "myaks-instance",
        "backup_repeating_time_intervals": [
          "R/2024-01-01T00:00:00Z/PT24H"
        ],
        "default_retention_duration": "P7D",
        "included_namespaces": ["prod"],
        "excluded_namespaces": ["kube-system"],
        "label_selectors": ["backup=true"],
        "trusted_access_roles": [
          "Microsoft.DataProtection/backupVaults/backup-operator"
        ]
      }
    }
  }
}
```

Key fields:

- `kubernetes_cluster_index`: Which AKS module instance to protect.
- `snapshot_resource_group_name`: Resource group for snapshots and the backup extension storage account (set `create_snapshot_resource_group` to `false` to reuse an existing RG).
- `backup_vault_name`, `backup_policy_name`, `backup_instance_name`: Friendly names for Azure Backup artifacts.
- `backup_repeating_time_intervals`: ISO8601 repeating interval defining the snapshot cadence (for example, hourly or daily).
- `default_retention_duration`: ISO8601 retention duration (for example `P7D` for seven days).
- `included_namespaces`, `excluded_namespaces`, `label_selectors`: Optional scoping controls for which cluster objects are included in backups.

