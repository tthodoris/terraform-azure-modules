# Network Interface
resource "azurerm_network_interface" "main" {
  name                = var.nic_name != "" ? var.nic_name : "${var.name_prefix}-${var.environment}-nic-${format("%02d", var.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.config.subnet_id != null ? var.config.subnet_id : var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.config.public_ip_enabled ? azurerm_public_ip.main[0].id : null
  }

  tags = var.tags
}

# Public IP (if enabled)
resource "azurerm_public_ip" "main" {
  count = var.config.public_ip_enabled ? 1 : 0

  name                = "${var.name_prefix}-${var.environment}-pip-${format("%02d", var.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.config.public_ip_allocation_method
  sku                 = var.config.public_ip_sku

  tags = var.tags
}

# Detect OS type based on publisher
locals {
  is_windows = var.config.publisher == "MicrosoftWindowsServer"
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "main" {
  count = local.is_windows ? 0 : 1

  name                = var.resource_name != "" ? var.resource_name : "${var.name_prefix}-${var.environment}-vm-${format("%02d", var.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.config.vm_size
  admin_username      = var.config.admin_username
  admin_password      = var.config.disable_password_authentication ? null : (var.config.admin_password != null ? var.config.admin_password : "TempPassword123!")

  network_interface_ids = var.config.network_interface_ids != null ? var.config.network_interface_ids : [azurerm_network_interface.main.id]

  disable_password_authentication = var.config.disable_password_authentication

  dynamic "admin_ssh_key" {
    for_each = var.config.disable_password_authentication ? [1] : []
    content {
      username   = var.config.admin_username
      public_key = var.ssh_public_key != null ? var.ssh_public_key : file("~/.ssh/id_rsa.pub")
    }
  }

  os_disk {
    name                 = var.os_disk_name != "" ? var.os_disk_name : "${var.name_prefix}-${var.environment}-osdisk-${format("%02d", var.index + 1)}"
    caching              = "ReadWrite"
    storage_account_type = var.config.os_disk_type
    disk_size_gb         = var.config.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.config.publisher
    offer     = var.config.offer
    sku       = var.config.sku
    version   = var.config.version
  }

  tags = var.tags
}

# Windows Virtual Machine
resource "azurerm_windows_virtual_machine" "main" {
  count = local.is_windows ? 1 : 0

  name                = var.resource_name != "" ? var.resource_name : "${var.name_prefix}-${var.environment}-vm-${format("%02d", var.index + 1)}"
  computer_name        = substr(replace(lower(var.resource_name != "" ? var.resource_name : "${var.name_prefix}-${var.environment}-vm-${format("%02d", var.index + 1)}"), "-", ""), 0, 15)
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.config.vm_size
  admin_username      = var.config.admin_username
  admin_password      = var.config.admin_password != null ? var.config.admin_password : "TempPassword123!"

  network_interface_ids = var.config.network_interface_ids != null ? var.config.network_interface_ids : [azurerm_network_interface.main.id]

  os_disk {
    name                 = var.os_disk_name != "" ? var.os_disk_name : "${var.name_prefix}-${var.environment}-osdisk-${format("%02d", var.index + 1)}"
    caching              = "ReadWrite"
    storage_account_type = var.config.os_disk_type
    disk_size_gb         = var.config.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.config.publisher
    offer     = var.config.offer
    sku       = var.config.sku
    version   = var.config.version
  }

  tags = var.tags
}

# Additional Managed Disks
resource "azurerm_managed_disk" "additional" {
  for_each = {
    for idx, disk in var.config.additional_managed_disks : disk.name => {
      index = idx
      disk  = disk
    }
  }

  name                 = var.data_disk_name_base != "" ? "${var.data_disk_name_base}-${each.value.disk.name}" : "${var.name_prefix}-${var.environment}-disk-${format("%02d", var.index + 1)}-${each.value.disk.name}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = each.value.disk.storage_account_type
  create_option        = try(each.value.disk.create_option, "Empty")
  disk_size_gb         = each.value.disk.disk_size_gb

  # Optional attributes
  disk_encryption_set_id              = try(each.value.disk.disk_encryption_set_id, null)
  disk_iops_read_write                = try(each.value.disk.disk_iops_read_write, null)
  disk_mbps_read_write                = try(each.value.disk.disk_mbps_read_write, null)
  disk_iops_read_only                 = try(each.value.disk.disk_iops_read_only, null)
  disk_mbps_read_only                 = try(each.value.disk.disk_mbps_read_only, null)
  max_shares                          = try(each.value.disk.max_shares, null)
  network_access_policy               = try(each.value.disk.network_access_policy, null)
  public_network_access_enabled       = try(each.value.disk.public_network_access_enabled, false)
  secure_vm_disk_encryption_set_id     = try(each.value.disk.secure_vm_disk_encryption_set_id, null)
  security_type                       = try(each.value.disk.security_type, null)
  source_resource_id                  = try(each.value.disk.source_resource_id, null)
  source_uri                          = try(each.value.disk.source_uri, null)
  storage_account_id                  = try(each.value.disk.storage_account_id, null)
  tier                                = try(each.value.disk.tier, null)
  trusted_launch_enabled              = try(each.value.disk.trusted_launch_enabled, false)
  zone                                = try(each.value.disk.zone, null)

  tags = var.tags
}

# Data Disk Attachments
resource "azurerm_virtual_machine_data_disk_attachment" "additional" {
  for_each = {
    for idx, disk in var.config.additional_managed_disks : disk.name => {
      index = idx
      disk  = disk
    }
  }

  managed_disk_id    = azurerm_managed_disk.additional[each.value.disk.name].id
  virtual_machine_id = local.is_windows ? azurerm_windows_virtual_machine.main[0].id : azurerm_linux_virtual_machine.main[0].id
  lun                = 10 + each.value.index  # Start LUN at 10 to avoid conflicts
  caching            = try(each.value.disk.caching, "ReadWrite")
}

