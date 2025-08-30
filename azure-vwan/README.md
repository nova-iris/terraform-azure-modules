````markdown
# Azure Virtual WAN (VWAN) Terraform Module

A comprehensive Terraform module for creating and managing Azure Virtual WAN with virtual hubs, VPN gateways, ExpressRoute gateways, Azure Firewall, and associated networking resources following Azure's secure virtual WAN architecture patterns.

## Features

### Core VWAN Components
- ✅ **Virtual WAN** with configurable type (Basic/Standard)
- ✅ **Existing Virtual WAN** support - create hubs in existing WAN
- ✅ **Multiple Virtual Hubs** across different regions
- ✅ **VPN Gateways** with BGP support and auto-scaling
- ✅ **ExpressRoute Gateways** for hybrid connectivity
- ✅ **Point-to-Site VPN Gateways** for remote user access
- ✅ **Azure Firewall** integration with Virtual Hub

### Advanced Features
- ✅ **Azure Naming Convention** integration using terraform-azurerm-naming module
- ✅ **Virtual Hub Connections** to existing VNets
- ✅ **Custom Routing** with static routes and route propagation
- ✅ **Branch-to-Branch Traffic** control
- ✅ **Office365 Local Breakout** configuration
- ✅ **Internet Security** controls for VNet connections
- ✅ **Comprehensive Tagging** strategy

### Security & Connectivity
- ✅ **Secure Hub Architecture** with Azure Firewall
- ✅ **Network Segmentation** through routing controls
- ✅ **VPN Encryption** management
- ✅ **BGP Routing** with custom ASN support
- ✅ **Multi-region** hub deployment

## Architecture

Azure Virtual WAN provides a unified networking service that brings together many networking, security, and routing functionalities. This module supports the following architectural patterns:

### Standard Virtual WAN Architecture
```
                    ┌─────────────────┐
                    │   Virtual WAN   │
                    └─────────────────┘
                             │
           ┌─────────────────┼─────────────────┐
           │                                   │
    ┌─────────────┐                   ┌─────────────┐
    │ Virtual Hub │                   │ Virtual Hub │
    │  (Region A) │                   │  (Region B) │
    └─────────────┘                   └─────────────┘
           │                                   │
    ┌──────┼──────┐                    ┌──────┼──────┐
    │      │      │                    │      │      │
   VPN    ER    VNet                  VPN    ER    VNet
```

### Secure Virtual WAN with Azure Firewall
```
    ┌─────────────────────────────────────────┐
    │            Virtual WAN                  │
    │  ┌─────────────────────────────────────┐│
    │  │         Virtual Hub                 ││
    │  │  ┌─────────────────────────────────┐││
    │  │  │       Azure Firewall           │││
    │  │  └─────────────────────────────────┘││
    │  │                                     ││
    │  │  VPN ←→ ExpressRoute ←→ VNet Conns  ││
    │  └─────────────────────────────────────┘│
    └─────────────────────────────────────────┘
```

## Usage

### Basic Example

```hcl
module "vwan" {
  source = "./azure-vwan"

  name                = "my-vwan"
  location           = "East US"
  resource_group_name = "my-vwan-rg"
  wan_type           = "Standard"

  # Azure naming convention configuration
  naming_convention = {
    prefix = ["corp"]
    suffix = ["prod"]
  }

  virtual_hubs = [
    {
      name           = "hub-eastus"
      location       = "East US"
      address_prefix = "10.0.0.0/23"
      
      # Basic VPN Gateway
      vpn_gateway = {
        enable     = true
        scale_unit = 1
      }
      
      # VNet connections
      vnet_connections = {
        spoke1 = {
          remote_virtual_network_id = "/subscriptions/xxx/resourceGroups/spoke1-rg/providers/Microsoft.Network/virtualNetworks/spoke1-vnet"
          internet_security_enabled = false
        }
      }
    }
  ]

  tags = {
    Environment = "production"
    Project     = "corporate-wan"
  }
}
```

### Advanced Multi-Hub Example with Full Features

```hcl
module "vwan_enterprise" {
  source = "./azure-vwan"

  # Basic Configuration
  name                              = "enterprise-vwan"
  location                          = "East US"
  resource_group_name               = "enterprise-vwan-rg"
  wan_type                          = "Standard"
  allow_branch_to_branch_traffic    = true
  office365_local_breakout_category = "OptimizeAndAllow"

  # Azure naming convention configuration
  naming_convention = {
    prefix = ["enterprise"]
    suffix = ["global"]
  }

  virtual_hubs = [
    # Primary Hub - East US
    {
      name                                   = "hub-eastus"
      location                               = "East US"
      address_prefix                         = "10.0.0.0/23"
      sku                                    = "Standard"
      hub_routing_preference                 = "ExpressRoute"
      virtual_router_auto_scale_min_capacity = 2

      # VPN Gateway with BGP
      vpn_gateway = {
        enable                                   = true
        routing_preference                       = "Microsoft Network"
        scale_unit                               = 2
        bgp_route_translation_for_nat_enabled    = false
        
        bgp_settings = {
          asn         = 65001
          peer_weight = 0
          instance_0_bgp_peering_address = {
            custom_ips = ["169.254.21.1"]
          }
          instance_1_bgp_peering_address = {
            custom_ips = ["169.254.21.5"]
          }
        }
      }

      # ExpressRoute Gateway
      expressroute_gateway = {
        enable     = true
        scale_unit = 2
      }

      # Point-to-Site VPN for remote users
      p2s_vpn_gateway = {
        enable                      = true
        scale_unit                  = 1
        vpn_server_configuration_id = "/subscriptions/xxx/resourceGroups/vpn-rg/providers/Microsoft.Network/vpnServerConfigurations/p2s-config"
        
        connection_configuration = [
          {
            name                      = "remote-users"
            internet_security_enabled = true
            vpn_client_address_pool = {
              address_prefixes = ["192.168.100.0/24"]
            }
            route = {
              associated_route_table_id = "defaultRouteTable"
              propagated_route_table = {
                ids    = ["defaultRouteTable"]
                labels = ["default"]
              }
            }
          }
        ]
      }

      # Azure Firewall for security
      azure_firewall = {
        enable             = true
        sku_name           = "AZFW_Hub"
        sku_tier           = "Standard"
        public_ip_count    = 2
        firewall_policy_id = "/subscriptions/xxx/resourceGroups/security-rg/providers/Microsoft.Network/firewallPolicies/enterprise-policy"
      }

      # Static routes
      routes = [
        {
          address_prefixes    = ["0.0.0.0/0"]
          next_hop_ip_address = "10.0.0.4"  # Azure Firewall IP
        }
      ]

      # VNet connections with custom routing
      vnet_connections = {
        prod-workloads = {
          remote_virtual_network_id = "/subscriptions/xxx/resourceGroups/prod-rg/providers/Microsoft.Network/virtualNetworks/prod-vnet"
          internet_security_enabled = true
          
          routing = {
            associated_route_table_id = "defaultRouteTable"
            propagated_route_table = {
              labels          = ["prod", "default"]
              route_table_ids = ["defaultRouteTable"]
            }
            static_vnet_route = [
              {
                name                = "to-shared-services"
                address_prefixes    = ["10.100.0.0/16"]
                next_hop_ip_address = "10.0.0.4"
              }
            ]
          }
        }
        
        shared-services = {
          remote_virtual_network_id = "/subscriptions/xxx/resourceGroups/shared-rg/providers/Microsoft.Network/virtualNetworks/shared-vnet"
          internet_security_enabled = false
          
          routing = {
            associated_route_table_id = "defaultRouteTable"
            propagated_route_table = {
              labels = ["shared", "default"]
            }
          }
        }
      }
    },

    # Secondary Hub - West US
    {
      name           = "hub-westus"
      location       = "West US"
      address_prefix = "10.1.0.0/23"
      sku            = "Standard"

      # VPN Gateway for disaster recovery
      vpn_gateway = {
        enable     = true
        scale_unit = 1
        
        bgp_settings = {
          asn = 65002
        }
      }

      # ExpressRoute Gateway
      expressroute_gateway = {
        enable     = true
        scale_unit = 1
      }

      # VNet connections
      vnet_connections = {
        dr-workloads = {
          remote_virtual_network_id = "/subscriptions/xxx/resourceGroups/dr-rg/providers/Microsoft.Network/virtualNetworks/dr-vnet"
          internet_security_enabled = true
        }
      }
    }
  ]

  tags = {
    Environment   = "production"
    Project       = "enterprise-wan"
    CostCenter    = "IT-001"
    Owner         = "network-team"
    SecurityLevel = "high"
  }
}
```

### Enterprise Multi-Region Hub Deployment (Using Existing WAN)

In typical enterprise scenarios, you have one centralized Virtual WAN and deploy regional hubs as needed:

```hcl
# Deploy regional hubs to existing corporate Virtual WAN
module "regional_hubs" {
  source = "./azure-vwan"

  # Use existing Virtual WAN instead of creating new one
  create_virtual_wan      = false
  existing_virtual_wan_id = "/subscriptions/xxx/resourceGroups/central-wan-rg/providers/Microsoft.Network/virtualWans/corporate-wan"

  name                = "regional-hubs"
  location           = "East US"  # Resource group location
  resource_group_name = "regional-hubs-rg"

  naming_convention = {
    prefix = ["corp"]
    suffix = ["region"]
  }

  virtual_hubs = [
    # East US Hub
    {
      name           = "hub-eastus"
      location       = "East US"
      address_prefix = "10.1.0.0/23"
      
      vpn_gateway = {
        enable     = true
        scale_unit = 2
        bgp_settings = {
          asn = 65001
        }
      }

      expressroute_gateway = {
        enable     = true
        scale_unit = 2
      }

      vnet_connections = {
        prod-eastus = {
          remote_virtual_network_id = "/subscriptions/xxx/resourceGroups/prod-eastus-rg/providers/Microsoft.Network/virtualNetworks/prod-eastus-vnet"
        }
      }
    },

    # West Europe Hub
    {
      name           = "hub-westeurope"
      location       = "West Europe"
      address_prefix = "10.2.0.0/23"
      
      vpn_gateway = {
        enable     = true
        scale_unit = 1
        bgp_settings = {
          asn = 65002
        }
      }

      vnet_connections = {
        prod-europe = {
          remote_virtual_network_id = "/subscriptions/xxx/resourceGroups/prod-europe-rg/providers/Microsoft.Network/virtualNetworks/prod-europe-vnet"
        }
      }
    }
  ]

  tags = {
    Environment = "production"
    Project     = "global-connectivity"
  }
}
```

### Secure Hub with Azure Firewall Example

```hcl
module "secure_vwan" {
  source = "./azure-vwan"

  name                = "secure-vwan"
  location           = "East US"
  resource_group_name = "secure-vwan-rg"
  wan_type           = "Standard"

  naming_convention = {
    prefix = ["secure"]
    suffix = ["hub"]
  }

  virtual_hubs = [
    {
      name           = "secure-hub"
      location       = "East US"
      address_prefix = "10.0.0.0/23"

      # Azure Firewall as security gateway
      azure_firewall = {
        enable             = true
        sku_name           = "AZFW_Hub"
        sku_tier           = "Premium"  # Premium for advanced threat protection
        public_ip_count    = 1
        firewall_policy_id = azurerm_firewall_policy.main.id
      }

      # All VNet connections use internet security (traffic via firewall)
      vnet_connections = {
        workload-vnet = {
          remote_virtual_network_id = module.workload_vnet.vnet_id
          internet_security_enabled = true  # Forces traffic through firewall
        }
        
        shared-vnet = {
          remote_virtual_network_id = module.shared_vnet.vnet_id
          internet_security_enabled = true
        }
      }
    }
  ]

  tags = {
    Environment = "production"
    Security    = "high"
  }
}

# Firewall Policy (created separately)
resource "azurerm_firewall_policy" "main" {
  name                = "secure-hub-policy"
  resource_group_name = "secure-vwan-rg"
  location           = "East US"
  sku                = "Premium"

  threat_intelligence_mode = "Alert"
}
```

## Module Structure

```
azure-vwan/
├── main.tf           # Main resource definitions
├── variables.tf      # Input variable definitions
├── outputs.tf        # Output value definitions
├── locals.tf         # Local value computations
├── data.tf           # Data source definitions
├── versions.tf       # Provider version constraints
├── README.md         # This documentation
└── examples/         # Usage examples
    ├── basic/
    ├── advanced/
    └── multi-hub/
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 4.42.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 4.42.0 |

## Resources Created

- `azurerm_virtual_wan` - The main Virtual WAN
- `azurerm_virtual_hub` - Virtual hubs within the WAN
- `azurerm_vpn_gateway` - VPN gateways for site-to-site connectivity
- `azurerm_express_route_gateway` - ExpressRoute gateways for hybrid connectivity
- `azurerm_point_to_site_vpn_gateway` - Point-to-site VPN gateways for remote users
- `azurerm_firewall` - Azure Firewall for security (when configured as AZFW_Hub)
- `azurerm_virtual_hub_connection` - Connections between virtual hubs and VNets

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the Virtual WAN (when creating) or identifier for the module | `string` | n/a | yes |
| create_virtual_wan | Whether to create a new Virtual WAN or use existing one | `bool` | `true` | no |
| existing_virtual_wan_id | ID of existing Virtual WAN (required when create_virtual_wan is false) | `string` | `""` | no |
| naming_convention | Configuration for Azure naming convention module | `object` | `{}` | no |
| location | Azure region where resources will be created | `string` | n/a | yes |
| resource_group_name | Name of the resource group | `string` | n/a | yes |
| wan_type | Virtual WAN type (Basic or Standard, only when creating WAN) | `string` | `"Standard"` | no |
| virtual_hubs | List of virtual hubs to create | `list(object)` | `[]` | no |
| create_resource_group | Whether to create a new resource group | `bool` | `true` | no |
| disable_vpn_encryption | Boolean flag to specify whether VPN encryption is disabled (only when creating WAN) | `bool` | `false` | no |
| allow_branch_to_branch_traffic | Boolean flag to specify whether branch to branch traffic is allowed (only when creating WAN) | `bool` | `true` | no |
| office365_local_breakout_category | Office365 local breakout category (only when creating WAN) | `string` | `"None"` | no |
| tags | A map of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vwan_id | ID of the Virtual WAN |
| vwan_name | Name of the Virtual WAN |
| virtual_hub_ids | Map of virtual hub names to their IDs |
| virtual_hub_default_route_table_ids | Map of virtual hub names to their default route table IDs |
| vpn_gateway_ids | Map of VPN gateway names to their IDs |
| expressroute_gateway_ids | Map of ExpressRoute gateway names to their IDs |
| p2s_vpn_gateway_ids | Map of Point-to-Site VPN gateway names to their IDs |
| firewall_ids | Map of Azure Firewall names to their IDs |
| vnet_connection_ids | Map of virtual hub connection names to their IDs |

## Best Practices

### Architecture Planning
- Use **Standard Virtual WAN** for production workloads requiring advanced features
- Plan hub addressing carefully using /23 or larger subnets as recommended by Microsoft
- Consider **multi-region deployment** for high availability and disaster recovery
- Implement **hub-spoke topology** with Virtual Hub as the central connectivity point

### Security
- Enable **Azure Firewall** in Virtual Hub for centralized security policy enforcement
- Use **internet_security_enabled = true** for VNet connections to route traffic through firewall
- Configure **Office365 local breakout** for optimized Microsoft 365 traffic
- Implement **network segmentation** using custom route tables and routing policies

### Connectivity
- Use **ExpressRoute** for primary connectivity and **VPN** for backup/branch offices
- Configure **BGP settings** properly for optimal routing
- Plan **address spaces** carefully to avoid overlaps across hubs and connected networks
- Use **Point-to-Site VPN** for secure remote user access

### Performance & Scaling
- Size **gateways appropriately** using scale units based on throughput requirements
- Configure **virtual router auto-scaling** for dynamic capacity adjustment
- Use **routing preferences** to optimize traffic paths (ExpressRoute vs VPN)
- Monitor **hub utilization** and scale resources as needed

### Monitoring & Operations
- Implement **comprehensive tagging** for cost management and operational visibility
- Use **Azure Monitor** for gateway and connectivity monitoring
- Configure **diagnostic settings** for all VWAN components
- Set up **alerts** for gateway health and connectivity issues

## Virtual WAN vs Traditional Hub-Spoke

| Feature | Traditional Hub-Spoke | Virtual WAN |
|---------|----------------------|-------------|
| **Connectivity** | Manual peering setup | Automatic hub connectivity |
| **Routing** | Manual UDR management | Dynamic routing with Virtual Hub Router |
| **Scaling** | Manual gateway scaling | Auto-scaling capabilities |
| **Global Transit** | Complex multi-hub setup | Native global transit |
| **Management** | Multiple management points | Centralized management |
| **Azure Firewall** | Deployed in VNet | Native hub integration |

## Migration Considerations

When migrating from traditional hub-spoke to Virtual WAN:

1. **Plan address spaces** to avoid conflicts
2. **Assess current routing** requirements and custom routes
3. **Evaluate gateway sizing** and scale unit requirements
4. **Plan migration phases** to minimize downtime
5. **Test connectivity** thoroughly before production cutover

## Examples

See the `examples/` directory for complete usage examples:

- **Basic**: Simple Virtual WAN with single hub and basic connectivity
- **Advanced**: Full-featured Virtual WAN with multiple hubs and all gateway types
- **Multi-Hub**: Enterprise-grade multi-region deployment
- **Existing-WAN**: Deploy hubs to existing Virtual WAN infrastructure

## Contributing

1. Follow Terraform best practices and HCL formatting standards
2. Update documentation for any changes or new features
3. Add comprehensive examples for new functionality
4. Test thoroughly across different Azure regions
5. Ensure backward compatibility when possible

## License

This module is licensed under the MIT License. See LICENSE file for details.

## References

- [Azure Virtual WAN Documentation](https://docs.microsoft.com/en-us/azure/virtual-wan/)
- [Virtual WAN Architecture Guide](https://docs.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about)
- [Azure Firewall in Virtual Hub](https://docs.microsoft.com/en-us/azure/firewall/deploy-multi-public-ip-powershell)
- [Virtual WAN Pricing](https://azure.microsoft.com/en-us/pricing/details/virtual-wan/)

````
