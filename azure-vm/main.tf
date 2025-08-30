# Azure VM Module - Main Configuration
# Creates Azure Virtual Machines with networking, storage, and monitoring

# Azure Naming Module for standardized naming conventions
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.4.0"
  prefix  = var.naming_convention.prefix
  suffix  = var.naming_convention.suffix
}

# Create resource group if specified
resource "azurerm_resource_group" "main" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Create Public IPs for VMs if specified
resource "azurerm_public_ip" "main" {
  for_each = {
    for vm_name, vm in local.vms_map : vm_name => vm
    if vm.create_public_ip
  }

  name                = "${module.naming.public_ip.name}-${each.key}"
  location            = var.location
  resource_group_name = local.resource_group_name
  allocation_method   = each.value.public_ip_allocation_method
  sku                 = each.value.public_ip_sku
  zones               = each.value.availability_zones
  domain_name_label   = each.value.public_ip_domain_name_label

  tags = local.merged_tags
}

# Create Network Security Groups for VMs
resource "azurerm_network_security_group" "main" {
  for_each = {
    for vm_name, vm in local.vms_map : vm_name => vm
    if vm.create_nsg
  }

  name                = "${module.naming.network_security_group.name}-${each.key}"
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = local.merged_tags
}

# Create NSG Security Rules
resource "azurerm_network_security_rule" "main" {
  for_each = local.nsg_rules_map

  name                         = each.value.rule.name
  priority                     = each.value.rule.priority
  direction                    = each.value.rule.direction
  access                       = each.value.rule.access
  protocol                     = each.value.rule.protocol
  source_port_range            = each.value.rule.source_port_range
  destination_port_range       = each.value.rule.destination_port_range
  source_port_ranges           = each.value.rule.source_port_ranges
  destination_port_ranges      = each.value.rule.destination_port_ranges
  source_address_prefix        = each.value.rule.source_address_prefix
  destination_address_prefix   = each.value.rule.destination_address_prefix
  source_address_prefixes      = each.value.rule.source_address_prefixes
  destination_address_prefixes = each.value.rule.destination_address_prefixes
  resource_group_name          = local.resource_group_name
  network_security_group_name  = azurerm_network_security_group.main[each.value.vm_name].name
}

# Create Network Interfaces
resource "azurerm_network_interface" "main" {
  for_each = local.vms_map

  name                           = "${module.naming.network_interface.name}-${each.key}"
  location                       = var.location
  resource_group_name            = local.resource_group_name
  accelerated_networking_enabled = each.value.enable_accelerated_networking
  ip_forwarding_enabled          = each.value.enable_ip_forwarding
  tags                           = local.merged_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = each.value.private_ip_address_allocation
    private_ip_address            = each.value.private_ip_address
    public_ip_address_id          = each.value.create_public_ip ? azurerm_public_ip.main[each.key].id : null
  }
}

# Associate NSGs with Network Interfaces
resource "azurerm_network_interface_security_group_association" "main" {
  for_each = {
    for vm_name, vm in local.vms_map : vm_name => vm
    if vm.create_nsg
  }

  network_interface_id      = azurerm_network_interface.main[each.key].id
  network_security_group_id = azurerm_network_security_group.main[each.key].id
}

# Create Availability Set if specified
resource "azurerm_availability_set" "main" {
  count = var.create_availability_set ? 1 : 0

  name                         = module.naming.availability_set.name
  location                     = var.location
  resource_group_name          = local.resource_group_name
  platform_fault_domain_count  = var.availability_set_fault_domain_count
  platform_update_domain_count = var.availability_set_update_domain_count
  managed                      = true
  tags                         = local.merged_tags
}

# Create Key Vault for VM secrets (if enabled)
resource "azurerm_key_vault" "main" {
  count = var.create_key_vault ? 1 : 0

  name                = module.naming.key_vault.name
  location            = var.location
  resource_group_name = local.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = var.key_vault_sku

  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  enabled_for_disk_encryption     = true
  soft_delete_retention_days      = var.key_vault_soft_delete_retention_days
  purge_protection_enabled        = var.key_vault_purge_protection_enabled

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create", "Delete", "Get", "Import", "List", "Update", "Recover", "Restore"
    ]

    secret_permissions = [
      "Set", "Get", "Delete", "List", "Recover", "Restore"
    ]

    certificate_permissions = [
      "Create", "Delete", "Get", "Import", "List", "Update", "Recover", "Restore"
    ]
  }

  tags = local.merged_tags
}

# Generate SSH Key Pair for Linux VMs
resource "tls_private_key" "main" {
  for_each = {
    for vm_name, vm in local.vms_map : vm_name => vm
    if vm.os_type == "Linux" && vm.generate_ssh_key
  }

  algorithm = "RSA"
  rsa_bits  = 4096
}

# Store SSH private key in Key Vault
resource "azurerm_key_vault_secret" "ssh_private_key" {
  for_each = {
    for vm_name, vm in local.vms_map : vm_name => vm
    if vm.os_type == "Linux" && vm.generate_ssh_key && var.create_key_vault
  }

  name         = "${each.key}-ssh-private-key"
  value        = tls_private_key.main[each.key].private_key_pem
  key_vault_id = azurerm_key_vault.main[0].id

  depends_on = [azurerm_key_vault.main]
}

# Generate admin password for Windows VMs
resource "random_password" "admin_password" {
  for_each = {
    for vm_name, vm in local.vms_map : vm_name => vm
    if vm.os_type == "Windows" && vm.admin_password == null
  }

  length  = 16
  special = true
}

# Store admin password in Key Vault
resource "azurerm_key_vault_secret" "admin_password" {
  for_each = {
    for vm_name, vm in local.vms_map : vm_name => vm
    if vm.os_type == "Windows" && var.create_key_vault
  }

  name         = "${each.key}-admin-password"
  value        = each.value.admin_password != null ? each.value.admin_password : random_password.admin_password[each.key].result
  key_vault_id = azurerm_key_vault.main[0].id

  depends_on = [azurerm_key_vault.main]
}

# Create Linux Virtual Machines
resource "azurerm_linux_virtual_machine" "main" {
  for_each = {
    for vm_name, vm in local.vms_map : vm_name => vm
    if vm.os_type == "Linux"
  }

  name                            = "${module.naming.virtual_machine.name}-${each.key}"
  location                        = var.location
  resource_group_name             = local.resource_group_name
  size                            = each.value.vm_size
  admin_username                  = each.value.admin_username
  computer_name                   = each.value.computer_name != null ? each.value.computer_name : each.key
  disable_password_authentication = each.value.disable_password_authentication
  availability_set_id             = var.create_availability_set ? azurerm_availability_set.main[0].id : null
  zone                            = length(each.value.availability_zones) > 0 ? each.value.availability_zones[0] : null
  custom_data                     = each.value.custom_data != null ? base64encode(each.value.custom_data) : null
  tags                            = local.merged_tags

  network_interface_ids = [
    azurerm_network_interface.main[each.key].id,
  ]

  source_image_reference {
    publisher = each.value.image_reference.publisher
    offer     = each.value.image_reference.offer
    sku       = each.value.image_reference.sku
    version   = each.value.image_reference.version
  }

  os_disk {
    name                 = "${module.naming.managed_disk.name}-${each.key}-os"
    caching              = each.value.os_disk.caching
    storage_account_type = each.value.os_disk.storage_account_type
    disk_size_gb         = each.value.os_disk.disk_size_gb
  }

  # SSH Keys
  dynamic "admin_ssh_key" {
    for_each = each.value.generate_ssh_key ? [1] : []
    content {
      username   = each.value.admin_username
      public_key = tls_private_key.main[each.key].public_key_openssh
    }
  }

  dynamic "admin_ssh_key" {
    for_each = each.value.ssh_public_keys
    content {
      username   = each.value.admin_username
      public_key = admin_ssh_key.value
    }
  }

  # Boot Diagnostics
  dynamic "boot_diagnostics" {
    for_each = each.value.enable_boot_diagnostics ? [1] : []
    content {
      storage_account_uri = each.value.boot_diagnostics_storage_account_uri
    }
  }

  # Identity
  dynamic "identity" {
    for_each = each.value.identity.type != null ? [1] : []
    content {
      type         = each.value.identity.type
      identity_ids = each.value.identity.identity_ids
    }
  }
}

# Create Windows Virtual Machines
resource "azurerm_windows_virtual_machine" "main" {
  for_each = {
    for vm_name, vm in local.vms_map : vm_name => vm
    if vm.os_type == "Windows"
  }

  name                     = "${module.naming.virtual_machine.name}-${each.key}"
  location                 = var.location
  resource_group_name      = local.resource_group_name
  size                     = each.value.vm_size
  admin_username           = each.value.admin_username
  admin_password           = each.value.admin_password != null ? each.value.admin_password : random_password.admin_password[each.key].result
  computer_name            = each.value.computer_name != null ? each.value.computer_name : each.key
  availability_set_id      = var.create_availability_set ? azurerm_availability_set.main[0].id : null
  zone                     = length(each.value.availability_zones) > 0 ? each.value.availability_zones[0] : null
  custom_data              = each.value.custom_data != null ? base64encode(each.value.custom_data) : null
  provision_vm_agent       = each.value.provision_vm_agent
  enable_automatic_updates = each.value.enable_automatic_upgrades
  tags                     = local.merged_tags

  network_interface_ids = [
    azurerm_network_interface.main[each.key].id,
  ]

  source_image_reference {
    publisher = each.value.image_reference.publisher
    offer     = each.value.image_reference.offer
    sku       = each.value.image_reference.sku
    version   = each.value.image_reference.version
  }

  os_disk {
    name                 = "${module.naming.managed_disk.name}-${each.key}-os"
    caching              = each.value.os_disk.caching
    storage_account_type = each.value.os_disk.storage_account_type
    disk_size_gb         = each.value.os_disk.disk_size_gb
  }

  # WinRM Configuration
  dynamic "winrm_listener" {
    for_each = each.value.winrm_listeners
    content {
      protocol        = winrm_listener.value.protocol
      certificate_url = winrm_listener.value.certificate_url
    }
  }

  # Additional Unattend Config
  dynamic "additional_unattend_content" {
    for_each = each.value.additional_unattend_configs
    content {
      setting = additional_unattend_content.value.pass
      content = additional_unattend_content.value.content
    }
  }

  # Boot Diagnostics
  dynamic "boot_diagnostics" {
    for_each = each.value.enable_boot_diagnostics ? [1] : []
    content {
      storage_account_uri = each.value.boot_diagnostics_storage_account_uri
    }
  }

  # Identity
  dynamic "identity" {
    for_each = each.value.identity.type != null ? [1] : []
    content {
      type         = each.value.identity.type
      identity_ids = each.value.identity.identity_ids
    }
  }
}

# Create Data Disks
resource "azurerm_managed_disk" "data_disks" {
  for_each = {
    for disk_key, disk in flatten([
      for vm_name, vm in local.vms_map : [
        for idx, data_disk in vm.data_disks : {
          key                  = "${vm_name}-data-${idx}"
          vm_name              = vm_name
          lun                  = data_disk.lun
          disk_size_gb         = data_disk.disk_size_gb
          storage_account_type = data_disk.storage_account_type
          caching              = data_disk.caching
        }
      ]
    ]) : disk.key => disk
  }

  name                 = "${module.naming.managed_disk.name}-${each.value.key}"
  location             = var.location
  resource_group_name  = local.resource_group_name
  storage_account_type = each.value.storage_account_type
  create_option        = "Empty"
  disk_size_gb         = each.value.disk_size_gb
  tags                 = local.merged_tags
}

# Attach Data Disks to Linux VMs
resource "azurerm_virtual_machine_data_disk_attachment" "linux_data_disks" {
  for_each = {
    for disk_key, disk in flatten([
      for vm_name, vm in local.vms_map : [
        for idx, data_disk in vm.data_disks : {
          key     = "${vm_name}-data-${idx}"
          vm_name = vm_name
          vm_id   = azurerm_linux_virtual_machine.main[vm_name].id
          lun     = data_disk.lun
          caching = data_disk.caching
        }
      ] if vm.os_type == "Linux"
    ]) : disk.key => disk
  }

  managed_disk_id    = azurerm_managed_disk.data_disks[each.key].id
  virtual_machine_id = each.value.vm_id
  lun                = each.value.lun
  caching            = each.value.caching
}

# Attach Data Disks to Windows VMs
resource "azurerm_virtual_machine_data_disk_attachment" "windows_data_disks" {
  for_each = {
    for disk_key, disk in flatten([
      for vm_name, vm in local.vms_map : [
        for idx, data_disk in vm.data_disks : {
          key     = "${vm_name}-data-${idx}"
          vm_name = vm_name
          vm_id   = azurerm_windows_virtual_machine.main[vm_name].id
          lun     = data_disk.lun
          caching = data_disk.caching
        }
      ] if vm.os_type == "Windows"
    ]) : disk.key => disk
  }

  managed_disk_id    = azurerm_managed_disk.data_disks[each.key].id
  virtual_machine_id = each.value.vm_id
  lun                = each.value.lun
  caching            = each.value.caching
}

# Linux VM Extensions
resource "azurerm_virtual_machine_extension" "linux_extensions" {
  for_each = {
    for ext_key, ext in local.vm_extensions_map : ext_key => ext
    if contains(keys(azurerm_linux_virtual_machine.main), ext.vm_name)
  }

  name                       = each.value.extension.name
  virtual_machine_id         = azurerm_linux_virtual_machine.main[each.value.vm_name].id
  publisher                  = each.value.extension.publisher
  type                       = each.value.extension.type
  type_handler_version       = each.value.extension.type_handler_version
  auto_upgrade_minor_version = each.value.extension.auto_upgrade_minor_version
  settings                   = each.value.extension.settings
  protected_settings         = each.value.extension.protected_settings
  tags                       = local.merged_tags
}

# Windows VM Extensions
resource "azurerm_virtual_machine_extension" "windows_extensions" {
  for_each = {
    for ext_key, ext in local.vm_extensions_map : ext_key => ext
    if contains(keys(azurerm_windows_virtual_machine.main), ext.vm_name)
  }

  name                       = each.value.extension.name
  virtual_machine_id         = azurerm_windows_virtual_machine.main[each.value.vm_name].id
  publisher                  = each.value.extension.publisher
  type                       = each.value.extension.type
  type_handler_version       = each.value.extension.type_handler_version
  auto_upgrade_minor_version = each.value.extension.auto_upgrade_minor_version
  settings                   = each.value.extension.settings
  protected_settings         = each.value.extension.protected_settings
  tags                       = local.merged_tags
}
