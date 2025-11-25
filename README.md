# Azure Terraform Deployment Package

This Terraform package provides a flexible, configuration-driven approach to deploy Azure resources. You can enable or disable modules and specify the count of resources for each module through a simple JSON configuration file.

## Features

- **Configuration-Driven**: Control which modules to deploy via a JSON configuration file
- **Flexible Counts**: Specify how many instances of each module to create
- **Modular Architecture**: Each Azure resource type is a separate, reusable module
- **Comprehensive Outputs**: All deployed resources are exposed as outputs

## Prerequisites

1. **Azure CLI** installed and configured
   ```bash
   az login
   az account set --subscription <your-subscription-id>
   ```

2. **Terraform** installed (version >= 1.0)
   - Download from [terraform.io](https://www.terraform.io/downloads)

3. **Azure Subscription** with appropriate permissions to create resources

## Project Structure

```
terraform-azure/
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output definitions
├── modules-config.json        # Configuration file for module enablement
├── terraform.tfvars.example  # Example variables file
├── README.md                  # This file
└── modules/                   # Individual Azure resource modules
    ├── storage_account/
    ├── app_service/
    ├── app_service_plan/
    ├── virtual_network/
    ├── key_vault/
    ├── container_registry/
    ├── kubernetes_cluster/
    ├── aks_backup/
    ├── sql_server/
    ├── function_app/
    └── log_analytics_workspace/
```

## Available Modules

| Module | Description |
|--------|-------------|
| `storage_account` | Azure Storage Account |
| `app_service` | Azure App Service (Web App) |
| `app_service_plan` | Azure App Service Plan |
| `virtual_network` | Azure Virtual Network with Subnet |
| `key_vault` | Azure Key Vault |
| `container_registry` | Azure Container Registry (ACR) |
| `kubernetes_cluster` | Azure Kubernetes Service (AKS) |
| `aks_backup` | Azure Backup vault, policy, and instance for AKS |
| `sql_server` | Azure SQL Server with Database |
| `function_app` | Azure Function App |
| `log_analytics_workspace` | Azure Log Analytics Workspace |

## Configuration

### Step 1: Configure Modules

Edit `modules-config.json` to enable/disable modules and set counts:

```json
{
  "modules": {
    "storage_account": {
      "enabled": true,
      "count": 2
    },
    "app_service": {
      "enabled": true,
      "count": 1
    },
    "virtual_network": {
      "enabled": true,
      "count": 1
    },
    "key_vault": {
      "enabled": true,
      "count": 1
    },
    "app_service_plan": {
      "enabled": true,
      "count": 1
    },
    "container_registry": {
      "enabled": false,
      "count": 0
    },
    "kubernetes_cluster": {
      "enabled": false,
      "count": 0
    },
    "sql_server": {
      "enabled": false,
      "count": 0
    },
    "function_app": {
      "enabled": false,
      "count": 0
    },
    "log_analytics_workspace": {
      "enabled": true,
      "count": 1
    }
  }
}
```

**Configuration Options:**
- `enabled`: Set to `true` to deploy the module, `false` to skip it
- `count`: Number of instances to create (0 if disabled)

### Step 2: Set Variables

Create a `terraform.tfvars` file (or copy from `terraform.tfvars.example`):

```hcl
subscription_id     = "your-azure-subscription-id"
resource_group_name = "my-resource-group"
location            = "East US"
environment         = "dev"
name_prefix         = "myapp"

tags = {
  Project     = "MyProject"
  Owner       = "DevOps Team"
  CostCenter  = "Engineering"
}
```

**Required Variables:**
- `subscription_id`: Your Azure subscription ID
- `resource_group_name`: Name for the resource group (will be created if it doesn't exist)

**Optional Variables:**
- `location`: Azure region (default: "East US")
- `environment`: Environment name (default: "dev")
- `name_prefix`: Prefix for resource names (default: "tf")
- `tags`: Additional tags to apply to all resources
- `modules_config_file`: Path to modules config file (default: "modules-config.json")

## Usage

### 1. Initialize Terraform

```bash
cd terraform-azure
terraform init
```

### 2. Review the Plan

```bash
terraform plan
```

This will show you what resources will be created based on your configuration.

### 3. Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted to confirm the deployment.

### 4. View Outputs

After deployment, view the outputs:

```bash
terraform output
```

## Examples

### Example 1: Deploy Only Storage Accounts

Edit `modules-config.json`:
```json
{
  "modules": {
    "storage_account": {
      "enabled": true,
      "count": 3
    },
    "app_service": { "enabled": false, "count": 0 },
    "virtual_network": { "enabled": false, "count": 0 },
    "key_vault": { "enabled": false, "count": 0 },
    "app_service_plan": { "enabled": false, "count": 0 },
    "container_registry": { "enabled": false, "count": 0 },
    "kubernetes_cluster": { "enabled": false, "count": 0 },
    "sql_server": { "enabled": false, "count": 0 },
    "function_app": { "enabled": false, "count": 0 },
    "log_analytics_workspace": { "enabled": false, "count": 0 }
  }
}
```

### Example 2: Deploy Full Web Application Stack

```json
{
  "modules": {
    "storage_account": { "enabled": true, "count": 1 },
    "app_service": { "enabled": true, "count": 2 },
    "app_service_plan": { "enabled": true, "count": 1 },
    "virtual_network": { "enabled": true, "count": 1 },
    "key_vault": { "enabled": true, "count": 1 },
    "log_analytics_workspace": { "enabled": true, "count": 1 },
    "container_registry": { "enabled": false, "count": 0 },
    "kubernetes_cluster": { "enabled": false, "count": 0 },
    "sql_server": { "enabled": false, "count": 0 },
    "function_app": { "enabled": false, "count": 0 }
  }
}
```

## Module Dependencies

Some modules have dependencies on others:

- **App Service** → Requires **App Service Plan** (will create one if not provided)
- **Function App** → Requires **App Service Plan** and **Storage Account** (will create if not provided)
- **aks_backup** → Requires an existing **kubernetes_cluster** module instance to target

The configuration automatically handles these dependencies.

## Customization

### Modifying Module Configurations

Each module is located in `modules/<module_name>/`. You can customize:

1. **Resource Settings**: Edit `main.tf` in each module directory
2. **Variables**: Modify `variables.tf` to add new parameters
3. **Outputs**: Add outputs in `outputs.tf`

### Adding New Modules

1. Create a new directory under `modules/`
2. Add `main.tf`, `variables.tf`, and `outputs.tf`
3. Add the module to `modules-config.json`
4. Add module call in `main.tf` (root)
5. Add outputs in `outputs.tf` (root)

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning**: This will delete all resources created by this Terraform configuration.

## Troubleshooting

### Common Issues

1. **Authentication Error**
   - Ensure you're logged in: `az login`
   - Verify subscription: `az account show`

2. **Resource Name Conflicts**
   - Azure resource names must be globally unique
   - Try changing `name_prefix` or `environment` variables

3. **Quota Exceeded**
   - Check your Azure subscription quotas
   - Some resources have regional limits

4. **Permission Errors**
   - Ensure your Azure account has Contributor or Owner role
   - Verify subscription permissions

## Security Notes

- **SQL Server Passwords**: Currently hardcoded in the SQL Server module. In production, use Azure Key Vault or Terraform variables with sensitive flags.
- **Key Vault Access**: The Key Vault module grants access to the current user. Adjust access policies as needed.
- **Storage Account Keys**: Storage account keys are marked as sensitive in outputs.

## Best Practices

1. **Use Version Control**: Commit your `modules-config.json` and `terraform.tfvars` (but exclude sensitive data)
2. **Separate Environments**: Use different `terraform.tfvars` files for dev/staging/prod
3. **Review Plans**: Always run `terraform plan` before `terraform apply`
4. **Tag Resources**: Use meaningful tags for cost tracking and organization
5. **Backup State**: Store Terraform state in Azure Storage or Terraform Cloud

## Support

For issues or questions:
1. Check the Terraform Azure Provider documentation: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
2. Review Azure resource documentation
3. Check Terraform logs for detailed error messages

## License

This Terraform configuration is provided as-is for deployment purposes.

