# Virtual Network and Subnet Configuration Guide

## Overview

The Terraform package now supports deploying multiple Virtual Networks (VNets) with multiple subnets per VNet, and allows you to specify which VNet and subnet each resource should be deployed to.

## Configuration Structure

### Virtual Networks with Multiple Subnets

You can configure multiple VNets, each with multiple subnets:

```json
{
  "modules": {
    "virtual_network": {
      "enabled": true,
      "count": 2,
      "config": [
        {
          "address_space": ["10.0.0.0/16"],
          "subnets": [
            {
              "name": "frontend",
              "address_prefix": "10.0.1.0/24"
            },
            {
              "name": "backend",
              "address_prefix": "10.0.2.0/24"
            },
            {
              "name": "dmz",
              "address_prefix": "10.0.3.0/24"
            }
          ]
        },
        {
          "address_space": ["172.16.0.0/16"],
          "subnets": [
            {
              "name": "database",
              "address_prefix": "172.16.1.0/24"
            },
            {
              "name": "management",
              "address_prefix": "172.16.2.0/24"
            }
          ]
        }
      ]
    }
  }
}
```

This creates:
- **VNet 0** (10.0.0.0/16) with subnets: frontend, backend, dmz
- **VNet 1** (172.16.0.0/16) with subnets: database, management

### Referencing VNets and Subnets in Resources

Resources can reference VNets and subnets using:
- `vnet_index`: The index of the VNet (0-based, matches the order in the config array)
- `subnet_name`: The name of the subnet within that VNet

#### Example: Virtual Machines

```json
{
  "modules": {
    "virtual_machine": {
      "enabled": true,
      "count": 3,
      "config": [
        {
          "vm_size": "Standard_B2s",
          "vnet_index": 0,
          "subnet_name": "frontend",
          "public_ip_enabled": true,
          ...
        },
        {
          "vm_size": "Standard_B2s",
          "vnet_index": 0,
          "subnet_name": "backend",
          "public_ip_enabled": false,
          ...
        },
        {
          "vm_size": "Standard_D2s_v3",
          "vnet_index": 1,
          "subnet_name": "database",
          "public_ip_enabled": false,
          ...
        }
      ]
    }
  }
}
```

This creates:
- **VM 0**: Standard_B2s in VNet 0, subnet "frontend" (with public IP)
- **VM 1**: Standard_B2s in VNet 0, subnet "backend" (no public IP)
- **VM 2**: Standard_D2s_v3 in VNet 1, subnet "database" (no public IP)

## Configuration Options

### Virtual Network Config

- `address_space`: Array of CIDR blocks for the VNet (e.g., `["10.0.0.0/16"]`)
- `subnets`: Array of subnet objects, each with:
  - `name`: Unique name for the subnet within the VNet
  - `address_prefix`: CIDR block for the subnet (e.g., `"10.0.1.0/24"`)

### Resource Config (for VMs and other network-aware resources)

- `vnet_index`: (Optional) Index of the VNet to use (0-based)
- `subnet_name`: (Optional) Name of the subnet within the specified VNet
- `subnet_id`: (Optional) Direct subnet ID (alternative to vnet_index/subnet_name)

**Priority**: If both `vnet_index`/`subnet_name` and `subnet_id` are provided, `vnet_index`/`subnet_name` takes precedence.

## Examples

### Example 1: Simple Setup

```json
{
  "virtual_network": {
    "enabled": true,
    "count": 1,
    "config": {
      "address_space": ["10.0.0.0/16"],
      "subnets": [
        { "name": "default", "address_prefix": "10.0.1.0/24" }
      ]
    }
  },
  "virtual_machine": {
    "enabled": true,
    "count": 1,
    "config": {
      "vnet_index": 0,
      "subnet_name": "default",
      ...
    }
  }
}
```

### Example 2: Multi-Tier Architecture

```json
{
  "virtual_network": {
    "enabled": true,
    "count": 1,
    "config": {
      "address_space": ["10.0.0.0/16"],
      "subnets": [
        { "name": "web", "address_prefix": "10.0.1.0/24" },
        { "name": "app", "address_prefix": "10.0.2.0/24" },
        { "name": "db", "address_prefix": "10.0.3.0/24" }
      ]
    }
  },
  "virtual_machine": {
    "enabled": true,
    "count": 3,
    "config": [
      { "vnet_index": 0, "subnet_name": "web", ... },
      { "vnet_index": 0, "subnet_name": "app", ... },
      { "vnet_index": 0, "subnet_name": "db", ... }
    ]
  }
}
```

### Example 3: Multi-VNet Setup

```json
{
  "virtual_network": {
    "enabled": true,
    "count": 2,
    "config": [
      {
        "address_space": ["10.0.0.0/16"],
        "subnets": [
          { "name": "production", "address_prefix": "10.0.1.0/24" }
        ]
      },
      {
        "address_space": ["172.16.0.0/16"],
        "subnets": [
          { "name": "development", "address_prefix": "172.16.1.0/24" }
        ]
      }
    ]
  },
  "virtual_machine": {
    "enabled": true,
    "count": 2,
    "config": [
      { "vnet_index": 0, "subnet_name": "production", ... },
      { "vnet_index": 1, "subnet_name": "development", ... }
    ]
  }
}
```

## Outputs

After deployment, you can view all VNets and their subnets:

```bash
terraform output virtual_networks
```

This will show:
- VNet IDs and names
- All subnets with their IDs and names for each VNet

## Notes

- **VNet Index**: Starts at 0 and corresponds to the order in the config array
- **Subnet Names**: Must be unique within each VNet, but can be reused across different VNets
- **Address Spaces**: Ensure VNet address spaces don't overlap
- **Subnet Address Prefixes**: Must be within the VNet's address space
- **Dependencies**: Resources that reference VNets/subnets will automatically wait for VNet creation

