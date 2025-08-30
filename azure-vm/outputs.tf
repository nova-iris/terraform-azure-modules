# Azure VM Module - Outputs
# Output values from the Azure VM module

# Resource Group Outputs
output "resource_group_name" {
  description = "Name of the resource group"
  value       = local.resource_group_name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = var.create_resource_group ? azurerm_resource_group.main[0].id : data.azurerm_resource_group.main[0].id
}

# Linux VM Outputs
output "linux_vm_ids" {
  description = "Map of Linux VM names to their IDs"
  value = {
    for name, vm in azurerm_linux_virtual_machine.main : name => vm.id
  }
}

output "linux_vm_names" {
  description = "List of Linux VM names"
  value       = [for vm in azurerm_linux_virtual_machine.main : vm.name]
}

output "linux_vm_private_ip_addresses" {
  description = "Map of Linux VM names to their private IP addresses"
  value = {
    for name, vm in azurerm_linux_virtual_machine.main : name => vm.private_ip_address
  }
}

output "linux_vm_public_ip_addresses" {
  description = "Map of Linux VM names to their public IP addresses"
  value = {
    for name, vm in azurerm_linux_virtual_machine.main : name => vm.public_ip_address
  }
}

# Windows VM Outputs
output "windows_vm_ids" {
  description = "Map of Windows VM names to their IDs"
  value = {
    for name, vm in azurerm_windows_virtual_machine.main : name => vm.id
  }
}

output "windows_vm_names" {
  description = "List of Windows VM names"
  value       = [for vm in azurerm_windows_virtual_machine.main : vm.name]
}

output "windows_vm_private_ip_addresses" {
  description = "Map of Windows VM names to their private IP addresses"
  value = {
    for name, vm in azurerm_windows_virtual_machine.main : name => vm.private_ip_address
  }
}

output "windows_vm_public_ip_addresses" {
  description = "Map of Windows VM names to their public IP addresses"
  value = {
    for name, vm in azurerm_windows_virtual_machine.main : name => vm.public_ip_address
  }
}

# Combined VM Outputs
output "all_vm_ids" {
  description = "Map of all VM names to their IDs"
  value = merge(
    {
      for name, vm in azurerm_linux_virtual_machine.main : name => vm.id
    },
    {
      for name, vm in azurerm_windows_virtual_machine.main : name => vm.id
    }
  )
}

output "all_vm_private_ip_addresses" {
  description = "Map of all VM names to their private IP addresses"
  value = merge(
    {
      for name, vm in azurerm_linux_virtual_machine.main : name => vm.private_ip_address
    },
    {
      for name, vm in azurerm_windows_virtual_machine.main : name => vm.private_ip_address
    }
  )
}

output "all_vm_public_ip_addresses" {
  description = "Map of all VM names to their public IP addresses"
  value = merge(
    {
      for name, vm in azurerm_linux_virtual_machine.main : name => vm.public_ip_address
    },
    {
      for name, vm in azurerm_windows_virtual_machine.main : name => vm.public_ip_address
    }
  )
}

# Network Interface Outputs
output "network_interface_ids" {
  description = "Map of VM names to their network interface IDs"
  value = {
    for name, nic in azurerm_network_interface.main : name => nic.id
  }
}

output "network_interface_private_ip_addresses" {
  description = "Map of VM names to their network interface private IP addresses"
  value = {
    for name, nic in azurerm_network_interface.main : name => nic.private_ip_address
  }
}

# Public IP Outputs
output "public_ip_ids" {
  description = "Map of VM names to their public IP IDs"
  value = {
    for name, pip in azurerm_public_ip.main : name => pip.id
  }
}

output "public_ip_addresses" {
  description = "Map of VM names to their public IP addresses"
  value = {
    for name, pip in azurerm_public_ip.main : name => pip.ip_address
  }
}

output "public_ip_fqdns" {
  description = "Map of VM names to their public IP FQDNs"
  value = {
    for name, pip in azurerm_public_ip.main : name => pip.fqdn
  }
}

# Network Security Group Outputs
output "nsg_ids" {
  description = "Map of VM names to their NSG IDs"
  value = {
    for name, nsg in azurerm_network_security_group.main : name => nsg.id
  }
}

output "nsg_names" {
  description = "List of NSG names"
  value       = [for nsg in azurerm_network_security_group.main : nsg.name]
}

# Data Disk Outputs
output "data_disk_ids" {
  description = "Map of data disk names to their IDs"
  value = {
    for name, disk in azurerm_managed_disk.data_disks : name => disk.id
  }
}

# Availability Set Outputs
output "availability_set_id" {
  description = "ID of the availability set"
  value       = var.create_availability_set ? azurerm_availability_set.main[0].id : null
}

output "availability_set_name" {
  description = "Name of the availability set"
  value       = var.create_availability_set ? azurerm_availability_set.main[0].name : null
}

# Key Vault Outputs
output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = var.create_key_vault ? azurerm_key_vault.main[0].id : null
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = var.create_key_vault ? azurerm_key_vault.main[0].name : null
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = var.create_key_vault ? azurerm_key_vault.main[0].vault_uri : null
}

# SSH Key Outputs (sensitive)
output "ssh_private_keys" {
  description = "Map of Linux VM names to their generated SSH private keys"
  value = {
    for name, key in tls_private_key.main : name => key.private_key_pem
  }
  sensitive = true
}

output "ssh_public_keys" {
  description = "Map of Linux VM names to their generated SSH public keys"
  value = {
    for name, key in tls_private_key.main : name => key.public_key_openssh
  }
}

# Admin Password Outputs (sensitive)
output "admin_passwords" {
  description = "Map of Windows VM names to their generated admin passwords"
  value = {
    for name, password in random_password.admin_password : name => password.result
  }
  sensitive = true
}

# VM Extension Outputs
output "linux_vm_extension_ids" {
  description = "Map of Linux VM extension names to their IDs"
  value = {
    for name, ext in azurerm_virtual_machine_extension.linux_extensions : name => ext.id
  }
}

output "windows_vm_extension_ids" {
  description = "Map of Windows VM extension names to their IDs"
  value = {
    for name, ext in azurerm_virtual_machine_extension.windows_extensions : name => ext.id
  }
}

# Complete module output for reference
output "vm_module" {
  description = "Complete VM module output object"
  value = {
    linux_vms = {
      for name, vm in azurerm_linux_virtual_machine.main : name => {
        id                 = vm.id
        name               = vm.name
        private_ip_address = vm.private_ip_address
        public_ip_address  = vm.public_ip_address
      }
    }
    windows_vms = {
      for name, vm in azurerm_windows_virtual_machine.main : name => {
        id                 = vm.id
        name               = vm.name
        private_ip_address = vm.private_ip_address
        public_ip_address  = vm.public_ip_address
      }
    }
    network_interfaces = {
      for name, nic in azurerm_network_interface.main : name => {
        id                 = nic.id
        name               = nic.name
        private_ip_address = nic.private_ip_address
      }
    }
    public_ips = {
      for name, pip in azurerm_public_ip.main : name => {
        id         = pip.id
        ip_address = pip.ip_address
        fqdn       = pip.fqdn
      }
    }
    key_vault = var.create_key_vault ? {
      id   = azurerm_key_vault.main[0].id
      name = azurerm_key_vault.main[0].name
      uri  = azurerm_key_vault.main[0].vault_uri
    } : null
  }
}
