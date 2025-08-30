# Azure VM Module

This Terraform module creates and manages Azure Virtual Machines (both Linux and Windows) with comprehensive networking, storage, security, and monitoring capabilities.

## Features

- **Linux & Windows VMs**: Support for both Linux and Windows virtual machines
- **Flexible Storage**: OS disks and multiple data disks with various storage types
- **Networking**: Public IPs, Network Security Groups, and network interface management
- **Security**: SSH key generation, Key Vault integration, and NSG rules
- **High Availability**: Availability sets and availability zones support
- **Extensions**: VM extensions for both Linux and Windows
- **Monitoring**: Boot diagnostics and logging capabilities
- **Identity**: System and user-assigned managed identities
- **Standardized Naming**: Uses Azure naming convention module

## Usage

### Basic Linux VM

```hcl
module "linux_vm" {
  source = "./azure-vm"

  # General Configuration
  location              = "East US"
  resource_group_name   = "rg-vm-example"
  create_resource_group = true

  # Virtual Machines
  virtual_machines = {
    "web-server" = {
      vm_size        = "Standard_B2s"
      os_type        = "Linux"
      admin_username = "azureuser"
      
      # Image Configuration
      image_reference = {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts-gen2"
        version   = "latest"
      }

      # Storage Configuration
      os_disk = {
        caching              = "ReadWrite"
        storage_account_type = "Premium_LRS"
        disk_size_gb         = 64
      }

      data_disks = [
        {
          lun                  = 0
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
          caching              = "ReadWrite"
        }
      ]

      # Network Configuration
      subnet_id                     = "/subscriptions/.../subnets/subnet-web"
      create_public_ip              = true
      public_ip_allocation_method   = "Static"
      public_ip_domain_name_label   = "web-server-example"

      # SSH Configuration
      generate_ssh_key                = true
      disable_password_authentication = true

      # Security Rules
      security_rules = [
        {
          name                     = "SSH"
          priority                 = 1001
          direction                = "Inbound"
          access                   = "Allow"
          protocol                 = "Tcp"
          source_port_range        = "*"
          destination_port_range   = "22"
          source_address_prefix    = "*"
          destination_address_prefix = "*"
        },
        {
          name                     = "HTTP"
          priority                 = 1002
          direction                = "Inbound"
          access                   = "Allow"
          protocol                 = "Tcp"
          source_port_range        = "*"
          destination_port_range   = "80"
          source_address_prefix    = "*"
          destination_address_prefix = "*"
        }
      ]

      # Extensions
      extensions = [
        {
          name                 = "CustomScript"
          publisher            = "Microsoft.Azure.Extensions"
          type                 = "CustomScript"
          type_handler_version = "2.1"
          settings = jsonencode({
            script = base64encode(file("${path.module}/scripts/install-nginx.sh"))
          })
        }
      ]
    }
  }

  # Key Vault for storing secrets
  create_key_vault = true

  tags = {
    Environment = "production"
    Project     = "web-app"
  }
}
```

### Windows VM with Domain Join

```hcl
module "windows_vm" {
  source = "./azure-vm"

  # General Configuration
  location              = "East US"
  resource_group_name   = "rg-windows-vm"
  create_resource_group = true

  # Virtual Machines
  virtual_machines = {
    "app-server" = {
      vm_size        = "Standard_D4s_v3"
      os_type        = "Windows"
      admin_username = "adminuser"
      admin_password = "ComplexPassword123!"
      
      # Image Configuration
      image_reference = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2022-datacenter-azure-edition"
        version   = "latest"
      }

      # Storage Configuration
      os_disk = {
        caching              = "ReadWrite"
        storage_account_type = "Premium_LRS"
        disk_size_gb         = 127
      }

      # Network Configuration
      subnet_id                   = "/subscriptions/.../subnets/subnet-app"
      create_public_ip            = false
      private_ip_address_allocation = "Static"
      private_ip_address          = "10.0.1.10"

      # Windows Configuration
      provision_vm_agent        = true
      enable_automatic_upgrades = true
      
      winrm_listeners = [
        {
          protocol = "Http"
        }
      ]

      # Security Rules
      security_rules = [
        {
          name                     = "RDP"
          priority                 = 1001
          direction                = "Inbound"
          access                   = "Allow"
          protocol                 = "Tcp"
          source_port_range        = "*"
          destination_port_range   = "3389"
          source_address_prefix    = "10.0.0.0/16"
          destination_address_prefix = "*"
        }
      ]

      # Extensions
      extensions = [
        {
          name                 = "IIS"
          publisher            = "Microsoft.Compute"
          type                 = "CustomScriptExtension"
          type_handler_version = "1.10"
          settings = jsonencode({
            commandToExecute = "powershell.exe Install-WindowsFeature -name Web-Server -IncludeManagementTools"
          })
        }
      ]

      # Identity
      identity = {
        type = "SystemAssigned"
      }
    }
  }

  # Availability Set
  create_availability_set = true

  tags = {
    Environment = "production"
    Application = "web-app"
  }
}
```

### High Availability VM Setup

```hcl
module "ha_vms" {
  source = "./azure-vm"

  # General Configuration
  location              = "East US"
  resource_group_name   = "rg-ha-vms"
  create_resource_group = true

  # Virtual Machines
  virtual_machines = {
    "web-01" = {
      vm_size              = "Standard_D2s_v3"
      os_type              = "Linux"
      admin_username       = "azureuser"
      generate_ssh_key     = true
      availability_zones   = ["1"]
      
      image_reference = {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts-gen2"
        version   = "latest"
      }

      os_disk = {
        storage_account_type = "Premium_LRS"
      }

      subnet_id        = "/subscriptions/.../subnets/subnet-web"
      create_public_ip = true

      enable_boot_diagnostics = true
      boot_diagnostics_storage_account_uri = "https://mystorageaccount.blob.core.windows.net/"
    }

    "web-02" = {
      vm_size              = "Standard_D2s_v3"
      os_type              = "Linux"
      admin_username       = "azureuser"
      generate_ssh_key     = true
      availability_zones   = ["2"]
      
      image_reference = {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts-gen2"
        version   = "latest"
      }

      os_disk = {
        storage_account_type = "Premium_LRS"
      }

      subnet_id        = "/subscriptions/.../subnets/subnet-web"
      create_public_ip = true

      enable_boot_diagnostics = true
      boot_diagnostics_storage_account_uri = "https://mystorageaccount.blob.core.windows.net/"
    }
  }

  tags = {
    Environment = "production"
    HA          = "true"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 4.42.0 |
| tls | >= 4.0 |
| random | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 4.42.0 |
| tls | >= 4.0 |
| random | >= 3.0 |

## Resources

| Name | Type |
|------|------|
| azurerm_linux_virtual_machine | resource |
| azurerm_windows_virtual_machine | resource |
| azurerm_network_interface | resource |
| azurerm_public_ip | resource |
| azurerm_network_security_group | resource |
| azurerm_network_security_rule | resource |
| azurerm_managed_disk | resource |
| azurerm_virtual_machine_data_disk_attachment | resource |
| azurerm_availability_set | resource |
| azurerm_key_vault | resource |
| azurerm_virtual_machine_extension | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| virtual_machines | Map of virtual machines to create | `map(object)` | `{}` | yes |
| location | Azure region where resources will be created | `string` | n/a | yes |
| resource_group_name | Name of the resource group | `string` | n/a | yes |
| create_resource_group | Whether to create a new resource group | `bool` | `true` | no |
| create_availability_set | Whether to create an availability set | `bool` | `false` | no |
| create_key_vault | Whether to create a Key Vault for storing VM secrets | `bool` | `false` | no |
| tags | A map of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| all_vm_ids | Map of all VM names to their IDs |
| all_vm_private_ip_addresses | Map of all VM names to their private IP addresses |
| all_vm_public_ip_addresses | Map of all VM names to their public IP addresses |
| linux_vm_ids | Map of Linux VM names to their IDs |
| windows_vm_ids | Map of Windows VM names to their IDs |
| network_interface_ids | Map of VM names to their network interface IDs |
| public_ip_addresses | Map of VM names to their public IP addresses |
| ssh_private_keys | Map of Linux VM names to their generated SSH private keys (sensitive) |
| admin_passwords | Map of Windows VM names to their generated admin passwords (sensitive) |
| key_vault_id | ID of the Key Vault |
| vm_module | Complete VM module output object |

## Examples

The `examples/` directory contains:

- `basic-linux/` - Basic Linux VM setup
- `basic-windows/` - Basic Windows VM setup
- `high-availability/` - Multi-VM high availability setup
- `with-extensions/` - VMs with various extensions

## Security Considerations

1. **SSH Keys**: The module can generate SSH key pairs automatically for Linux VMs
2. **Passwords**: Windows VM passwords are automatically generated if not provided
3. **Key Vault**: Enable Key Vault to securely store generated secrets
4. **NSG Rules**: Configure appropriate security rules for your use case
5. **Identity**: Use managed identities for secure access to Azure resources

## License

MIT License
