# Azure Virtual WAN DNS Module

This Terraform module creates a dedicated DNS VNet with Azure Private DNS Resolver specifically designed for **Virtual WAN hub-spoke architecture**. It orchestrates existing `azure-vnet` and `azure-private-dns` modules to implement the common enterprise pattern where DNS resolution flows through Azure Firewall DNS Proxy.

## Architecture Pattern

```
┌─────────────────┐    ┌───────────────────┐    ┌──────────────────┐
│   Spoke VNets   │───▶│  Virtual WAN Hub  │───▶│   DNS VNet       │
│                 │    │  (Azure Firewall │    │  (DNS Resolver)  │
│ DNS: Firewall IP│    │   DNS Proxy)      │    │                  │
└─────────────────┘    └───────────────────┘    └──────────────────┘
                                                          │
                                                          ▼
                                                 ┌─────────────────┐
                                                 │  On-Premises    │
                                                 │  DNS Servers    │
                                                 └─────────────────┘
```

## Features

### 🏗️ Infrastructure Components
- **Dedicated DNS VNet** with properly configured subnets
- **Azure Private DNS Resolver** with inbound/outbound endpoints
- **Private DNS zones** with virtual network links
- **DNS forwarding rules** for hybrid connectivity
- **VNet peering** to Virtual WAN Hub (optional)

### 🔧 DNS Capabilities
- **Hybrid DNS resolution** between Azure and on-premises
- **Conditional forwarding** for specific domains
- **Private Link DNS integration** support
- **Multiple DNS zones** management
- **Custom DNS records** (A, AAAA, CNAME, MX, PTR, SRV, TXT)

### 🔐 Security & Compliance
- **Azure Firewall DNS Proxy** integration ready
- **Network security groups** on DNS resolver subnets
- **Subnet delegation** for DNS resolver services
- **Consistent tagging** strategy

### 📊 Monitoring & Management
- **Comprehensive outputs** for integration
- **DNS configuration guidance** for spoke VNets
- **Firewall DNS proxy** configuration values

## Usage

### Basic Virtual WAN DNS Setup

```hcl
module "vwan_dns" {
  source = "./azure-vwan-dns"

  # Basic Configuration
  location            = "East US"
  resource_group_name = "rg-dns-infrastructure"
  
  # DNS VNet Configuration
  dns_vnet_name         = "vnet-dns-prod"
  dns_vnet_address_space = ["10.100.0.0/24"]
  
  # Primary DNS Zone
  primary_dns_zone = "company.internal"
  
  # Tags
  tags = {
    Environment = "production"
    Project     = "vwan-dns"
    Owner       = "network-team"
  }
}
```

### Advanced Configuration with Hub Connectivity

```hcl
module "vwan_dns" {
  source = "./azure-vwan-dns"

  # Basic Configuration
  location                = "East US"
  resource_group_name     = "rg-dns-infrastructure"
  create_resource_group   = true

  # DNS VNet Configuration
  dns_vnet_name                        = "vnet-dns-prod"
  dns_vnet_address_space               = ["10.100.0.0/24"]
  dns_resolver_inbound_subnet_cidr     = "10.100.0.0/28"
  dns_resolver_outbound_subnet_cidr    = "10.100.0.16/28"

  # Primary DNS Zone
  primary_dns_zone = "company.internal"

  # Additional DNS Zones
  additional_dns_zones = {
    "app-zone" = {
      name                 = "app.company.internal"
      registration_enabled = true
      spoke_vnet_links = {
        "app-spoke" = {
          virtual_network_id   = "/subscriptions/xxx/resourceGroups/rg-spokes/providers/Microsoft.Network/virtualNetworks/vnet-app-spoke"
          registration_enabled = false
        }
      }
      a_records = {
        "app-lb" = {
          name    = "app-loadbalancer"
          records = ["10.1.1.100"]
          ttl     = 300
        }
      }
    },
    "privatelink-zone" = {
      name                 = "privatelink.blob.core.windows.net"
      registration_enabled = false
    }
  }

  # DNS Forwarding for Hybrid Connectivity
  dns_forwarding_rulesets = {
    "onprem-forwarding" = {
      name = "onprem-dns-forwarding"
      virtual_network_links = {
        "hub-link" = {
          name               = "hub-vnet-link"
          virtual_network_id = "/subscriptions/xxx/resourceGroups/rg-hub/providers/Microsoft.Network/virtualNetworks/vnet-hub"
        }
      }
      forwarding_rules = {
        "corp-domain" = {
          name        = "corp-domain-rule"
          domain_name = "corp.company.com."
          enabled     = true
          target_dns_servers = [
            {
              ip_address = "192.168.1.10"
              port       = 53
            },
            {
              ip_address = "192.168.1.11"
              port       = 53
            }
          ]
        }
      }
    }
  }

  # Virtual WAN Hub Connectivity
  hub_virtual_network_id   = "/subscriptions/xxx/resourceGroups/rg-vwan/providers/Microsoft.Network/virtualNetworks/vnet-hub"
  hub_resource_group_name  = "rg-vwan"
  hub_virtual_network_name = "vnet-hub"
  use_hub_gateway         = false

  tags = {
    Environment = "production"
    Project     = "vwan-dns"
    Owner       = "network-team"
  }
}
```

### Integration with Azure Firewall

```hcl
# 1. Create DNS infrastructure
module "vwan_dns" {
  source = "./azure-vwan-dns"
  # ... configuration as above
}

# 2. Configure Azure Firewall (separate firewall module)
module "azure_firewall" {
  source = "./azure-firewall"

  # Configure DNS Proxy
  dns_proxy_enabled = true
  dns_servers       = [module.vwan_dns.dns_resolver_inbound_endpoint_ip]
  
  # Other firewall configuration...
}

# 3. Configure Spoke VNets (using azure-vnet module)
module "spoke_vnet" {
  source = "./azure-vnet"

  # Configure DNS servers to point to Azure Firewall
  dns_servers = [module.azure_firewall.firewall_private_ip]
  
  # Other VNet configuration...
}
```

## Module Integration

This module is designed to work with other Azure modules:

### Required Modules
- `azure-vnet` - Creates the DNS VNet infrastructure
- `azure-private-dns` - Manages DNS zones and resolver

### Optional Integration
- `azure-firewall` - For DNS proxy functionality
- `azure-vwan` - For Virtual WAN hub connectivity

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 4.42.0 |
| random | >= 3.1 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 4.42.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| naming | Azure/naming/azurerm | ~> 0.4.0 |
| dns_vnet | ../azure-vnet | n/a |
| private_dns | ../azure-private-dns | n/a |
| additional_private_dns_zones | ../azure-private-dns | n/a |

## Resources

| Name | Type |
|------|------|
| azurerm_resource_group.main | resource |
| azurerm_virtual_network_peering.dns_to_hub | resource |
| azurerm_virtual_network_peering.hub_to_dns | resource |
| azurerm_client_config.current | data source |
| azurerm_resource_group.main | data source |
| azurerm_virtual_network.hub | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| location | The Azure region where resources will be created | `string` | n/a | yes |
| resource_group_name | The name of the resource group where DNS resources will be created | `string` | n/a | yes |
| additional_dns_zones | Additional private DNS zones to create with their configurations | `map(object)` | `{}` | no |
| azure_private_dns_module_source | Source path for the azure-private-dns module | `string` | `"../azure-private-dns"` | no |
| azure_vnet_module_source | Source path for the azure-vnet module | `string` | `"../azure-vnet"` | no |
| create_resource_group | Whether to create a new resource group for DNS resources | `bool` | `false` | no |
| ddos_protection_plan_id | Resource ID of the DDoS protection plan | `string` | `null` | no |
| dns_forwarding_rulesets | DNS forwarding rulesets for hybrid connectivity | `map(object)` | `{}` | no |
| dns_resolver_inbound_subnet_cidr | CIDR block for the inbound DNS resolver subnet | `string` | `"10.100.0.0/28"` | no |
| dns_resolver_inbound_subnet_name | Name of the inbound DNS resolver subnet | `string` | `"snet-dns-inbound"` | no |
| dns_resolver_outbound_subnet_cidr | CIDR block for the outbound DNS resolver subnet | `string` | `"10.100.0.16/28"` | no |
| dns_resolver_outbound_subnet_name | Name of the outbound DNS resolver subnet | `string` | `"snet-dns-outbound"` | no |
| dns_vnet_address_space | Address space for the DNS VNet | `list(string)` | `["10.100.0.0/24"]` | no |
| dns_vnet_name | Name of the dedicated DNS VNet | `string` | `"vnet-dns"` | no |
| enable_ddos_protection | Enable DDoS protection for the DNS VNet | `bool` | `false` | no |
| hub_resource_group_name | Resource group name of the Virtual WAN Hub | `string` | `null` | no |
| hub_virtual_network_id | Resource ID of the Virtual WAN Hub VNet for peering | `string` | `null` | no |
| hub_virtual_network_name | Name of the Virtual WAN Hub VNet | `string` | `null` | no |
| naming_convention | Naming convention configuration for Azure resources | `object` | `{ prefix = [], suffix = [] }` | no |
| primary_dns_zone | Primary private DNS zone name | `string` | `"internal.company.com"` | no |
| tags | A map of tags to assign to the resources | `map(string)` | `{}` | no |
| use_hub_gateway | Whether to use the hub gateway for connectivity | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| additional_dns_zone_ids | Resource IDs of additional private DNS zones |
| additional_dns_zone_names | Names of additional private DNS zones |
| all_dns_zones | All DNS zones (primary and additional) with their details |
| dns_architecture_summary | Summary of the DNS architecture components |
| dns_resolver_id | Resource ID of the Private DNS Resolver |
| dns_resolver_inbound_endpoint_id | Resource ID of the DNS resolver inbound endpoint |
| dns_resolver_inbound_endpoint_ip | Private IP address of the DNS resolver inbound endpoint |
| dns_resolver_name | Name of the Private DNS Resolver |
| dns_resolver_outbound_endpoint_id | Resource ID of the DNS resolver outbound endpoint |
| dns_resolver_subnet_info | Information about DNS resolver subnets |
| dns_to_hub_peering_id | Resource ID of the DNS VNet to hub peering |
| dns_vnet_address_space | Address space of the DNS VNet |
| dns_vnet_id | Resource ID of the DNS VNet |
| dns_vnet_name | Name of the DNS VNet |
| dns_vnet_resource_group_name | Resource group name of the DNS VNet |
| firewall_dns_configuration | DNS configuration values for Azure Firewall DNS Proxy setup |
| hub_connectivity_enabled | Whether hub connectivity is enabled |
| hub_to_dns_peering_id | Resource ID of the hub to DNS VNet peering |
| primary_dns_zone_id | Resource ID of the primary private DNS zone |
| primary_dns_zone_name | Name of the primary private DNS zone |
| resource_group_id | Resource ID of the resource group containing DNS resources |
| resource_group_name | Name of the resource group containing DNS resources |
| spoke_vnet_dns_configuration | DNS configuration for spoke VNets in Virtual WAN architecture |
| vnet_links | Virtual network links for all DNS zones |

## Implementation Steps

### 1. Deploy DNS Infrastructure

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan -var-file="terraform.tfvars"

# Deploy the infrastructure
terraform apply -var-file="terraform.tfvars"
```

### 2. Configure Azure Firewall DNS Proxy

After deployment, configure your Azure Firewall:

```hcl
# Get DNS resolver IP from output
dns_servers = [module.vwan_dns.dns_resolver_inbound_endpoint_ip]

# Enable DNS Proxy in Azure Firewall
resource "azurerm_firewall" "hub" {
  # ... other configuration
  
  dns_proxy_enabled = true
  dns_servers       = [module.vwan_dns.dns_resolver_inbound_endpoint_ip]
}
```

### 3. Configure Spoke VNets

Update spoke VNets to use Azure Firewall as DNS server:

```hcl
resource "azurerm_virtual_network" "spoke" {
  # ... other configuration
  
  dns_servers = [azurerm_firewall.hub.ip_configuration[0].private_ip_address]
}
```

## Best Practices

### DNS Architecture
- Use dedicated DNS VNet separate from hub/spoke traffic
- Implement DNS forwarding rules for hybrid scenarios
- Configure conditional forwarding for different domains
- Use Azure Firewall DNS Proxy for centralized DNS management

### Security
- Apply network security groups to DNS resolver subnets
- Use private endpoints for Azure services
- Implement DNS filtering at the firewall level
- Monitor DNS query logs for security analysis

### Performance
- Place DNS resolver close to Virtual WAN hub
- Use multiple on-premises DNS servers for redundancy
- Configure appropriate TTL values for DNS records
- Monitor DNS resolution performance

### Management
- Use consistent naming conventions
- Implement comprehensive tagging strategy
- Document DNS forwarding rules and zones
- Automate DNS record management where possible

## Troubleshooting

### Common Issues

1. **DNS Resolution Not Working**
   - Verify Azure Firewall DNS Proxy is enabled
   - Check spoke VNet DNS server configuration
   - Validate DNS forwarding rules

2. **Private Link DNS Issues**
   - Ensure Private Link DNS zones are properly configured
   - Verify virtual network links are established
   - Check Private Link endpoint configurations

3. **Hybrid Connectivity Problems**
   - Validate on-premises DNS server connectivity
   - Check DNS forwarding rule target servers
   - Verify network connectivity between VNets

### Debugging Commands

```bash
# Test DNS resolution from spoke VNet
nslookup company.internal

# Check DNS resolver endpoint status
az network private-dns resolver show --name <resolver-name> --resource-group <rg-name>

# Validate DNS forwarding rules
az network private-dns resolver forwarding-rule list --dns-forwarding-ruleset <ruleset-name> --resource-group <rg-name>
```

## Examples

See the `examples/` directory for complete implementation examples:
- `basic/` - Simple DNS VNet setup
- `advanced/` - Full Virtual WAN integration
- `hybrid/` - On-premises connectivity
- `multi-region/` - Multi-region DNS architecture

## Contributing

1. Follow the module structure and naming conventions
2. Add comprehensive tests for new features
3. Update documentation and examples
4. Validate with `terraform validate` and `terraform plan`

## License

This module is licensed under the MIT License.
<!-- END_TF_DOCS -->
