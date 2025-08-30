# Azure Virtual Network (VNet) Terraform Module

A comprehensive Terraform module for creating and managing Azure Virtual Networks with subnets, network security groups, route tables, and associated networking resources.

## Features

### Core Networking
- ✅ **Virtual Network** with customizable address space
- ✅ **Multiple Subnets** with flexible configuration
- ✅ **Network Security Groups (NSGs)** with custom security rules
- ✅ **Route Tables** with custom routes
- ✅ **Service Endpoints** configuration
- ✅ **DNS Servers** configuration

### Advanced Features
- ✅ **Azure Naming Convention** integration using terraform-azurerm-naming module
- ✅ **VNet Peering** for connecting virtual networks
- ✅ **DDoS Protection** plan integration
- ✅ **Network Flow Logs** with retention policies
- ✅ **Traffic Analytics** integration
- ✅ **Service Delegations** for specific Azure services
- ✅ **Comprehensive Tagging** strategy

### Security & Monitoring
- ✅ **Network Security Groups** with granular rules
- ✅ **Flow Logs** for network monitoring
- ✅ **Traffic Analytics** for insights
- ✅ **Private Endpoint** network policies

## Usage

### Basic Example

```hcl
module "vnet" {
  source = "./azure-vnet"

  name                = "my-vnet"
  location           = "East US"
  resource_group_name = "my-rg"
  address_space      = ["10.0.0.0/16"]

  # Azure naming convention configuration
  naming_convention = {
    prefix = ["dev"]
    suffix = ["001"]
  }

  subnets = [
    {
      name             = "web-subnet"
      address_prefixes = ["10.0.1.0/24"]
      create_nsg      = true
      security_rules = [
        {
          name                       = "allow-http"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    },
    {
      name             = "app-subnet"
      address_prefixes = ["10.0.2.0/24"]
      create_nsg      = true
    },
    {
      name             = "db-subnet"
      address_prefixes = ["10.0.3.0/24"]
      create_nsg      = true
      service_endpoints = ["Microsoft.Sql"]
    }
  ]

  tags = {
    Environment = "production"
    Project     = "webapp"
  }
}
```

### Azure Naming Convention Integration

This module integrates with the [Azure Naming Module](https://github.com/Azure/terraform-azurerm-naming) to provide standardized resource naming following Microsoft's recommended naming conventions.

#### Features
- 🏷️ **Standardized Naming**: Automatically applies Azure-recommended naming patterns
- 🔧 **Customizable**: Configure prefix and suffix for your organization's needs
- 📋 **Consistent**: Ensures all networking resources follow the same naming standard
- 🌐 **Global**: Supports different environments and regions

#### Naming Pattern Examples
With `naming_convention = { prefix = ["myorg"], suffix = ["prod"] }`:

| Resource Type | Generated Name Pattern | Example |
|---------------|----------------------|---------|
| Virtual Network | `{prefix}-vnet-{suffix}` | `myorg-vnet-prod` |
| Subnet | `{prefix}-snet-{suffix}-{subnet_name}` | `myorg-snet-prod-web` |
| Network Security Group | `{prefix}-nsg-{suffix}-{subnet_name}` | `myorg-nsg-prod-web` |
| Route Table | `{prefix}-route-{suffix}-{subnet_name}` | `myorg-route-prod-web` |
| DDoS Protection Plan | `{prefix}-ddospp-{suffix}` | `myorg-ddospp-prod` |
| VNet Peering | `{prefix}-vpeer-{suffix}-{peering_name}` | `myorg-vpeer-prod-hub` |

#### Configuration Options
```hcl
naming_convention = {
  prefix        = ["myorg"]      # Organization/project prefix (list of strings)
  suffix        = ["prod"]       # Environment/region suffix (list of strings)
  unique_suffix = "001"        # Optional unique identifier (not used in current implementation)
}
```

### Advanced Example with All Features

```hcl
module "vnet_advanced" {
  source = "./azure-vnet"

  # Basic Configuration
  name                = "enterprise-vnet"
  location           = "East US"
  resource_group_name = "enterprise-rg"
  address_space      = ["10.0.0.0/16"]
  dns_servers        = ["8.8.8.8", "8.8.4.4"]

  # Azure naming convention configuration
  naming_convention = {
    prefix = ["enterprise"]
    suffix = ["eastus"]
  }

  # DDoS Protection
  enable_ddos_protection = true

  # Subnets with comprehensive configuration
  subnets = [
    {
      name             = "web-subnet"
      address_prefixes = ["10.0.1.0/24"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      create_nsg       = true
      create_route_table = true
      
      # NSG Security Rules
      security_rules = [
        {
          name                       = "allow-http"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "allow-https"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
      
      # Custom Routes
      routes = [
        {
          name           = "to-firewall"
          address_prefix = "0.0.0.0/0"
          next_hop_type  = "VirtualAppliance"
          next_hop_in_ip_address = "10.0.100.4"
        }
      ]
    },
    {
      name             = "app-subnet"
      address_prefixes = ["10.0.2.0/24"]
      create_nsg       = true
      service_endpoints = ["Microsoft.Sql", "Microsoft.Storage"]
      
      # Service Delegation for Azure Container Instances
      delegations = [
        {
          name = "aci-delegation"
          service_delegation = {
            name = "Microsoft.ContainerInstance/containerGroups"
            actions = [
              "Microsoft.Network/virtualNetworks/subnets/action"
            ]
          }
        }
      ]
    },
    {
      name             = "db-subnet"
      address_prefixes = ["10.0.3.0/24"]
      create_nsg       = true
      service_endpoints = ["Microsoft.Sql"]
      
      security_rules = [
        {
          name                       = "allow-sql"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "1433"
          source_address_prefix      = "10.0.2.0/24"
          destination_address_prefix = "*"
        }
      ]
    }
  ]

  # VNet Peering
  vnet_peerings = {
    hub-connection = {
      name                      = "enterprise-to-hub"
      remote_virtual_network_id = "/subscriptions/xxx/resourceGroups/hub-rg/providers/Microsoft.Network/virtualNetworks/hub-vnet"
      allow_forwarded_traffic   = true
      use_remote_gateways      = true
    }
  }

  # Flow Logs and Traffic Analytics
  enable_flow_logs                        = true
  network_watcher_name                    = "NetworkWatcher_eastus"
  network_watcher_resource_group_name     = "NetworkWatcherRG"
  flow_logs_storage_account_id           = "/subscriptions/xxx/resourceGroups/monitoring-rg/providers/Microsoft.Storage/storageAccounts/flowlogssa"
  flow_logs_retention_enabled           = true
  flow_logs_retention_days              = 90
  
  enable_traffic_analytics              = true
  log_analytics_workspace_id            = "12345678-1234-1234-1234-123456789012"
  log_analytics_workspace_resource_id   = "/subscriptions/xxx/resourceGroups/monitoring-rg/providers/Microsoft.OperationalInsights/workspaces/law-monitoring"

  tags = {
    Environment = "production"
    Project     = "enterprise-app"
    CostCenter  = "IT-001"
    Owner       = "infrastructure-team"
  }
}
```

### Hub-Spoke Architecture Example

```hcl
# Hub VNet
module "hub_vnet" {
  source = "./azure-vnet"

  name                = "hub-vnet"
  location           = "East US"
  resource_group_name = "hub-rg"
  address_space      = ["10.0.0.0/16"]

  subnets = [
    {
      name             = "GatewaySubnet"
      address_prefixes = ["10.0.1.0/27"]
      create_nsg      = false  # Gateway subnet doesn't need NSG
    },
    {
      name             = "AzureFirewallSubnet"
      address_prefixes = ["10.0.2.0/26"]
      create_nsg      = false  # Firewall subnet doesn't need NSG
    },
    {
      name             = "shared-services"
      address_prefixes = ["10.0.3.0/24"]
      create_nsg      = true
    }
  ]

  enable_ddos_protection = true
  
  tags = {
    Environment = "hub"
    Role        = "connectivity"
  }
}

# Spoke VNet 1
module "spoke1_vnet" {
  source = "./azure-vnet"

  name                = "spoke1-vnet"
  location           = "East US"
  resource_group_name = "spoke1-rg"
  address_space      = ["10.1.0.0/16"]

  subnets = [
    {
      name             = "workload-subnet"
      address_prefixes = ["10.1.1.0/24"]
      create_nsg      = true
      create_route_table = true
      
      routes = [
        {
          name           = "to-hub"
          address_prefix = "0.0.0.0/0"
          next_hop_type  = "VirtualAppliance"
          next_hop_in_ip_address = "10.0.2.4"  # Azure Firewall IP
        }
      ]
    }
  ]

  vnet_peerings = {
    to-hub = {
      name                      = "spoke1-to-hub"
      remote_virtual_network_id = module.hub_vnet.vnet_id
      allow_forwarded_traffic   = true
      use_remote_gateways      = true
    }
  }

  tags = {
    Environment = "production"
    Role        = "workload"
    Application = "web-app"
  }
}
```

## Module Structure

```
azure-vnet/
├── main.tf           # Main resource definitions
├── variables.tf      # Input variable definitions
├── outputs.tf        # Output value definitions
├── versions.tf       # Provider version constraints
├── README.md         # This documentation
└── examples/         # Usage examples
    ├── basic/
    ├── advanced/
    └── hub-spoke/
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.0 |

## Resources Created

- `azurerm_virtual_network` - The main virtual network
- `azurerm_subnet` - Subnets within the VNet
- `azurerm_network_security_group` - Network security groups for subnets
- `azurerm_network_security_rule` - Security rules for NSGs
- `azurerm_route_table` - Route tables for subnets
- `azurerm_route` - Custom routes
- `azurerm_subnet_network_security_group_association` - NSG to subnet associations
- `azurerm_subnet_route_table_association` - Route table to subnet associations
- `azurerm_virtual_network_peering` - VNet peering connections
- `azurerm_network_ddos_protection_plan` - DDoS protection plan (optional)
- `azurerm_network_watcher_flow_log` - Flow logs for monitoring (optional)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the Virtual Network | `string` | n/a | yes |
| naming_convention | Configuration for Azure naming convention module (required for standardized resource naming) | `object({ prefix = optional(list(string), []), suffix = optional(list(string), []), unique_suffix = optional(string, "") })` | `{}` | no |
| location | Azure region where resources will be created | `string` | n/a | yes |
| resource_group_name | Name of the resource group | `string` | n/a | yes |
| address_space | The address space that is used the virtual network | `list(string)` | `["10.0.0.0/16"]` | no |
| subnets | List of subnets to create | `list(object)` | `[]` | no |
| create_resource_group | Whether to create a new resource group | `bool` | `true` | no |
| dns_servers | List of IP addresses of DNS servers | `list(string)` | `[]` | no |
| enable_ddos_protection | Enable DDoS protection plan | `bool` | `false` | no |
| vnet_peerings | Map of VNet peerings to create | `map(object)` | `{}` | no |
| enable_flow_logs | Enable Network Security Group flow logs | `bool` | `false` | no |
| enable_traffic_analytics | Enable traffic analytics for flow logs | `bool` | `false` | no |
| tags | A map of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vnet_id | ID of the Virtual Network |
| vnet_name | Name of the Virtual Network |
| vnet_address_space | Address space of the Virtual Network |
| subnet_ids | Map of subnet names to their IDs |
| subnet_names | List of subnet names |
| nsg_ids | Map of NSG names to their IDs |
| route_table_ids | Map of route table names to their IDs |
| vnet_peering_ids | Map of VNet peering names to their IDs |

## Best Practices

### Security
- Always create NSGs for application subnets
- Use specific security rules instead of allowing all traffic
- Enable flow logs for security monitoring
- Implement proper subnet segmentation

### Networking
- Plan IP address space carefully to avoid conflicts
- Use service endpoints where appropriate
- Implement hub-spoke topology for enterprise scenarios
- Configure custom DNS servers if needed

### Monitoring
- Enable flow logs for traffic analysis
- Use traffic analytics for insights
- Implement proper tagging strategy
- Monitor NSG rule effectiveness

### Performance
- Use proximity placement groups for latency-sensitive workloads
- Consider ExpressRoute for hybrid connectivity
- Implement proper routing for traffic optimization

## Examples

See the `examples/` directory for complete usage examples:

- **Basic**: Simple VNet with subnets and NSGs
- **Advanced**: Full-featured VNet with all options
- **Hub-Spoke**: Enterprise hub-spoke architecture

## Contributing

1. Follow Terraform best practices
2. Update documentation for any changes
3. Add examples for new features
4. Test thoroughly before submitting PRs

## License

This module is licensed under the MIT License. See LICENSE file for details.
<!-- END_TF_DOCS -->
