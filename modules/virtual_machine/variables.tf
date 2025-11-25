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

variable "os_disk_name" {
  description = "Pre-generated OS disk name from naming convention"
  type        = string
  default     = ""
}

variable "data_disk_name_base" {
  description = "Pre-generated base name for data disks from naming convention"
  type        = string
  default     = ""
}

variable "nic_name" {
  description = "Pre-generated network interface name from naming convention"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Subnet ID (optional, can be provided via config)"
  type        = string
  default     = null
}

variable "ssh_public_key" {
  description = "SSH public key (optional, will use ~/.ssh/id_rsa.pub if not provided)"
  type        = string
  default     = null
}

variable "config" {
  description = "Configuration object for the virtual machine"
  type = object({
    vm_size                        = string
    os_disk_type                   = string
    os_disk_size_gb                = number
    admin_username                 = string
    admin_password                 = optional(string)
    disable_password_authentication = bool
    publisher                      = string
    offer                          = string
    sku                            = string
    version                        = string
    network_interface_ids          = optional(list(string))
    subnet_id                      = optional(string)
    vnet_index                     = optional(number)
    subnet_name                    = optional(string)
    public_ip_enabled              = bool
    public_ip_allocation_method    = string
    public_ip_sku                  = string
    additional_managed_disks       = optional(list(object({
      name         = string
      disk_size_gb = number
      storage_account_type = string  # e.g., "Premium_LRS", "Standard_LRS", "StandardSSD_LRS", "Premium_ZRS", "StandardSSD_ZRS", "PremiumV2_LRS"
      caching      = optional(string, "ReadWrite")  # "None", "ReadOnly", "ReadWrite"
      create_option = optional(string, "Empty")  # "Empty", "Attach", "Copy", "FromImage", "Import", "Restore", "Upload"
      disk_encryption_set_id = optional(string)
      disk_iops_read_write = optional(number)
      disk_mbps_read_write = optional(number)
      disk_iops_read_only = optional(number)
      disk_mbps_read_only = optional(number)
      max_shares = optional(number)
      network_access_policy = optional(string)  # "AllowAll", "AllowPrivate", "DenyAll"
      public_network_access_enabled = optional(bool, false)
      secure_vm_disk_encryption_set_id = optional(string)
      security_type = optional(string)  # "ConfidentialVM_DiskEncryptedWithCustomerKey", "ConfidentialVM_DiskEncryptedWithPlatformKey", "Standard", "TrustedLaunch"
      source_resource_id = optional(string)
      source_uri = optional(string)
      storage_account_id = optional(string)
      tier = optional(string)  # "P1", "P2", "P3", "P4", "P6", "P10", "P15", "P20", "P30", "P40", "P50", "P60", "P70", "P80"
      trusted_launch_enabled = optional(bool, false)
      zone = optional(string)
    })), [])
  })
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

