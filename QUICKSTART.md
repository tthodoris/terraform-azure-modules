# Quick Start Guide

## Prerequisites Check

1. **Azure CLI**
   ```bash
   az --version
   az login
   az account show
   ```

2. **Terraform**
   ```bash
   terraform version
   ```

## 5-Minute Setup

### Step 1: Configure Your Subscription

1. Get your subscription ID:
   ```bash
   az account show --query id -o tsv
   ```

2. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. Edit `terraform.tfvars` and set:
   - `subscription_id`: Your Azure subscription ID
   - `resource_group_name`: Your desired resource group name
   - `location`: Your preferred Azure region

### Step 2: Configure Modules

Edit `modules-config.json` to enable the modules you want:

**Minimal Example** (just storage accounts):
```json
{
  "modules": {
    "storage_account": { "enabled": true, "count": 1 },
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

### Step 3: Deploy

```bash
# Initialize Terraform
terraform init

# Review what will be created
terraform plan

# Deploy (type 'yes' when prompted)
terraform apply
```

### Step 4: Verify

```bash
# View all outputs
terraform output

# Check resources in Azure
az resource list --resource-group <your-resource-group-name> -o table
```

## Common Scenarios

### Scenario 1: Web Application
Enable: `app_service`, `app_service_plan`, `storage_account`, `key_vault`

### Scenario 2: Container Workload
Enable: `container_registry`, `kubernetes_cluster`, `log_analytics_workspace`

### Scenario 3: Serverless
Enable: `function_app`, `app_service_plan`, `storage_account`

### Scenario 4: Database Backend
Enable: `sql_server`, `key_vault`, `virtual_network`

## Cleanup

```bash
terraform destroy
```

## Next Steps

- Read the full [README.md](README.md) for detailed documentation
- Customize modules in the `modules/` directory
- Add your own modules following the existing pattern

