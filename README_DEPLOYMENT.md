# VM and MySQL Database Deployment Guide

This guide explains how to deploy a Virtual Machine (Standard_D2ds_v5) and MySQL Flexible Server on the same Virtual Network with different subnets.

## Configuration Overview

### Virtual Network
- **VNet Address Space**: `10.0.0.0/16`
- **VM Subnet**: `vm-subnet` with CIDR `10.0.1.0/28` (16 IP addresses, 14 usable)
- **MySQL Subnet**: `mysql-subnet` with CIDR `10.0.2.0/27` (32 IP addresses, 30 usable)

### Virtual Machine
- **Size**: Standard_D2ds_v5
- **OS**: Ubuntu Server 22.04 LTS
- **OS Disk**: Premium_LRS, 128 GB
- **Network**: Connected to `vm-subnet` (10.0.1.0/28)
- **Public IP**: Enabled (Static, Standard SKU)
- **Authentication**: SSH key-based (password authentication disabled)

### MySQL Flexible Server
- **Version**: 8.0.21
- **SKU**: GP_Standard_D2s_v3
- **Storage**: 32 GB with auto-grow enabled
- **Network**: Connected to `mysql-subnet` (10.0.2.0/27)
- **Database**: `appdb` (utf8mb4 charset, utf8mb4_unicode_ci collation)
- **Backup**: 7 days retention

## Prerequisites

1. **Azure CLI** installed and logged in:
   ```bash
   az login
   az account set --subscription "your-subscription-id"
   ```

2. **Terraform** installed (version >= 1.0)

3. **SSH Key Pair** for VM access (if using SSH key authentication)

## Deployment Steps

### 1. Update Configuration Files

#### Update `terraform.tfvars`:
- Replace `your-azure-subscription-id-here` with your actual Azure subscription ID
- Adjust `resource_group_name`, `location`, and other settings as needed

#### Update `modules-config.json`:
- Change the MySQL `administrator_password` from `ChangeMe123!` to a secure password
- The configuration is already set up for the deployment

### 2. Initialize Terraform

```bash
cd terraform-azure
terraform init
```

### 3. Review the Deployment Plan

```bash
terraform plan
```

This will show you what resources will be created:
- 1 Resource Group
- 1 Virtual Network with 2 subnets
- 1 Virtual Machine (Standard_D2ds_v5)
- 1 MySQL Flexible Server
- 1 Public IP for the VM
- 1 Network Interface for the VM

### 4. Deploy the Infrastructure

```bash
terraform apply
```

Type `yes` when prompted to confirm the deployment.

### 5. Access Your Resources

After deployment, you can get the VM's public IP from Terraform outputs:

```bash
terraform output virtual_machines
```

Or get the MySQL server details:

```bash
terraform output mysql_flexible_servers
```

### 6. Connect to the VM

Since password authentication is disabled, you'll need to use SSH keys. If you haven't configured SSH keys yet, you can:

1. Generate an SSH key pair:
   ```bash
   ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
   ```

2. Add the public key to the VM (you'll need to update the VM module to support this, or use Azure Portal)

Alternatively, you can temporarily enable password authentication in the `modules-config.json`:
- Set `"disable_password_authentication": false`
- Set `"admin_password": "YourSecurePassword"`

### 7. Connect to MySQL

The MySQL server is deployed in a private subnet. To connect:

1. **From the VM**: Since the VM is on the same VNet, you can connect directly:
   ```bash
   mysql -h <mysql-server-name>.mysql.database.azure.com -u mysqladmin -p
   ```

2. **From your local machine**: You'll need to:
   - Set up a VPN connection to the VNet, OR
   - Use Azure Bastion (if deployed), OR
   - Create a jump box VM with public IP

## Important Notes

1. **MySQL Password**: Change the default password in `modules-config.json` before deployment
2. **SSH Access**: The VM uses SSH key authentication by default. Make sure you have your SSH keys configured
3. **Network Security**: Consider adding Network Security Groups (NSG) to restrict access
4. **Costs**: Standard_D2ds_v5 and GP_Standard_D2s_v3 are production-grade SKUs. Monitor your costs
5. **Backup**: MySQL has 7-day backup retention configured. Adjust as needed

## Cleanup

To remove all resources:

```bash
terraform destroy
```

## Troubleshooting

### VM Connection Issues
- Verify the public IP is assigned: `terraform output virtual_machines`
- Check NSG rules if NSG is attached
- Verify SSH key is properly configured

### MySQL Connection Issues
- Verify the MySQL server is in the correct subnet
- Check VNet rules and firewall settings
- Ensure you're connecting from a resource in the same VNet or via VPN

### Terraform Errors
- Run `terraform init` again if provider issues occur
- Check that your Azure credentials are valid: `az account show`
- Verify the subscription ID in `terraform.tfvars` is correct

