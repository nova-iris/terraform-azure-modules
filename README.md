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

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.42.0 |

## Providers

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.42.0 |

## Modules

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_naming"></a> [naming](#module\_naming) | Azure/naming/azurerm | ~> 0.4.0 |
## Resources

## Resources

| Name | Type |
|------|------|
| [azurerm_network_ddos_protection_plan.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_ddos_protection_plan) | resource |
| [azurerm_network_security_group.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.subnet_rules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_watcher_flow_log.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_watcher_flow_log) | resource |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_route.subnet_routes](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route) | resource |
| [azurerm_route_table.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
| [azurerm_subnet.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_route_table_association.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [azurerm_virtual_network.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network_peering.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |

## Inputs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | The address space that is used the virtual network | `list(string)` | <pre>[<br>  "10.0.0.0/16"<br>]</pre> | no |
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | Whether to create a new resource group | `bool` | `true` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | List of IP addresses of DNS servers | `list(string)` | `[]` | no |
| <a name="input_enable_ddos_protection"></a> [enable\_ddos\_protection](#input\_enable\_ddos\_protection) | Enable DDoS protection plan | `bool` | `false` | no |
| <a name="input_enable_flow_logs"></a> [enable\_flow\_logs](#input\_enable\_flow\_logs) | Enable Network Security Group flow logs | `bool` | `false` | no |
| <a name="input_enable_traffic_analytics"></a> [enable\_traffic\_analytics](#input\_enable\_traffic\_analytics) | Enable traffic analytics for flow logs | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., dev, staging, prod) | `string` | `"dev"` | no |
| <a name="input_flow_logs_retention_days"></a> [flow\_logs\_retention\_days](#input\_flow\_logs\_retention\_days) | Number of days to retain flow logs | `number` | `30` | no |
| <a name="input_flow_logs_retention_enabled"></a> [flow\_logs\_retention\_enabled](#input\_flow\_logs\_retention\_enabled) | Enable flow logs retention | `bool` | `true` | no |
| <a name="input_flow_logs_storage_account_id"></a> [flow\_logs\_storage\_account\_id](#input\_flow\_logs\_storage\_account\_id) | Storage account ID for flow logs | `string` | `""` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region where resources will be created | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics workspace ID for traffic analytics | `string` | `""` | no |
| <a name="input_log_analytics_workspace_resource_id"></a> [log\_analytics\_workspace\_resource\_id](#input\_log\_analytics\_workspace\_resource\_id) | Log Analytics workspace resource ID for traffic analytics | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Virtual Network | `string` | n/a | yes |
| <a name="input_naming_convention"></a> [naming\_convention](#input\_naming\_convention) | Configuration for Azure naming convention module (required for standardized resource naming) | <pre>object({<br>    prefix        = optional(list(string), [])<br>    suffix        = optional(list(string), [])<br>    unique_suffix = optional(string, "")<br>  })</pre> | `{}` | no |
| <a name="input_network_watcher_name"></a> [network\_watcher\_name](#input\_network\_watcher\_name) | Name of the Network Watcher | `string` | `""` | no |
| <a name="input_network_watcher_resource_group_name"></a> [network\_watcher\_resource\_group\_name](#input\_network\_watcher\_resource\_group\_name) | Resource group name of the Network Watcher | `string` | `""` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | `""` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | List of subnets to create | <pre>list(object({<br>    name                                          = string<br>    address_prefixes                              = list(string)<br>    service_endpoints                             = optional(list(string), [])<br>    private_endpoint_network_policies_enabled     = optional(bool, true)<br>    private_link_service_network_policies_enabled = optional(bool, true)<br>    create_nsg                                    = optional(bool, true)<br>    create_route_table                            = optional(bool, false)<br>    disable_bgp_route_propagation                 = optional(bool, false)<br><br>    # Service delegations<br>    delegations = optional(list(object({<br>      name = string<br>      service_delegation = object({<br>        name    = string<br>        actions = list(string)<br>      })<br>    })), [])<br><br>    # NSG Security Rules<br>    security_rules = optional(list(object({<br>      name                         = string<br>      priority                     = number<br>      direction                    = string<br>      access                       = string<br>      protocol                     = string<br>      source_port_range            = optional(string)<br>      destination_port_range       = optional(string)<br>      source_port_ranges           = optional(list(string))<br>      destination_port_ranges      = optional(list(string))<br>      source_address_prefix        = optional(string)<br>      destination_address_prefix   = optional(string)<br>      source_address_prefixes      = optional(list(string))<br>      destination_address_prefixes = optional(list(string))<br>    })), [])<br><br>    # Route Table Routes<br>    routes = optional(list(object({<br>      name                   = string<br>      address_prefix         = string<br>      next_hop_type          = string<br>      next_hop_in_ip_address = optional(string)<br>    })), [])<br>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resources | `map(string)` | `{}` | no |
| <a name="input_traffic_analytics_interval"></a> [traffic\_analytics\_interval](#input\_traffic\_analytics\_interval) | Traffic analytics interval in minutes (10 or 60) | `number` | `60` | no |
| <a name="input_vnet_peerings"></a> [vnet\_peerings](#input\_vnet\_peerings) | Map of VNet peerings to create | <pre>map(object({<br>    name                         = string<br>    remote_virtual_network_id    = string<br>    allow_virtual_network_access = optional(bool, true)<br>    allow_forwarded_traffic      = optional(bool, false)<br>    allow_gateway_transit        = optional(bool, false)<br>    use_remote_gateways          = optional(bool, false)<br>  }))</pre> | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ddos_protection_plan_id"></a> [ddos\_protection\_plan\_id](#output\_ddos\_protection\_plan\_id) | ID of the DDoS protection plan |
| <a name="output_ddos_protection_plan_name"></a> [ddos\_protection\_plan\_name](#output\_ddos\_protection\_plan\_name) | Name of the DDoS protection plan |
| <a name="output_flow_log_ids"></a> [flow\_log\_ids](#output\_flow\_log\_ids) | Map of flow log names to their IDs |
| <a name="output_flow_log_names"></a> [flow\_log\_names](#output\_flow\_log\_names) | List of flow log names |
| <a name="output_nsg_ids"></a> [nsg\_ids](#output\_nsg\_ids) | Map of NSG names to their IDs |
| <a name="output_nsg_names"></a> [nsg\_names](#output\_nsg\_names) | List of NSG names |
| <a name="output_nsgs"></a> [nsgs](#output\_nsgs) | Map of NSG objects with all attributes |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | ID of the resource group |
| <a name="output_resource_group_location"></a> [resource\_group\_location](#output\_resource\_group\_location) | Location of the resource group |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the resource group |
| <a name="output_route_table_ids"></a> [route\_table\_ids](#output\_route\_table\_ids) | Map of route table names to their IDs |
| <a name="output_route_table_names"></a> [route\_table\_names](#output\_route\_table\_names) | List of route table names |
| <a name="output_route_tables"></a> [route\_tables](#output\_route\_tables) | Map of route table objects with all attributes |
| <a name="output_subnet_address_prefixes"></a> [subnet\_address\_prefixes](#output\_subnet\_address\_prefixes) | Map of subnet names to their address prefixes |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | Map of subnet names to their IDs |
| <a name="output_subnet_names"></a> [subnet\_names](#output\_subnet\_names) | List of subnet names |
| <a name="output_subnet_nsg_associations"></a> [subnet\_nsg\_associations](#output\_subnet\_nsg\_associations) | Map of subnet NSG associations |
| <a name="output_subnet_route_table_associations"></a> [subnet\_route\_table\_associations](#output\_subnet\_route\_table\_associations) | Map of subnet route table associations |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | Map of subnet objects with all attributes |
| <a name="output_vnet_address_space"></a> [vnet\_address\_space](#output\_vnet\_address\_space) | Address space of the Virtual Network |
| <a name="output_vnet_guid"></a> [vnet\_guid](#output\_vnet\_guid) | GUID of the Virtual Network |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | ID of the Virtual Network |
| <a name="output_vnet_location"></a> [vnet\_location](#output\_vnet\_location) | Location of the Virtual Network |
| <a name="output_vnet_module"></a> [vnet\_module](#output\_vnet\_module) | Complete VNet module output object |
| <a name="output_vnet_name"></a> [vnet\_name](#output\_vnet\_name) | Name of the Virtual Network |
| <a name="output_vnet_peering_ids"></a> [vnet\_peering\_ids](#output\_vnet\_peering\_ids) | Map of VNet peering names to their IDs |
| <a name="output_vnet_peering_names"></a> [vnet\_peering\_names](#output\_vnet\_peering\_names) | List of VNet peering names |
<!-- END_TF_DOCS -->
   action   = string<br><br>      rules = list(object({<br>        name                = string<br>        description         = optional(string)<br>        protocols           = list(string)<br>        source_addresses    = optional(list(string), [])<br>        source_ip_groups    = optional(list(string), [])<br>        destination_address = string<br>        destination_ports   = list(string)<br>        translated_address  = string<br>        translated_port     = string<br>      }))<br>    })), [])<br>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resources | `map(string)` | `{}` | no |
| <a name="input_threat_intel_mode"></a> [threat\_intel\_mode](#input\_threat\_intel\_mode) | Threat intelligence mode for the Azure Firewall | `string` | `"Alert"` | no |
| <a name="input_threat_intelligence_allowlist"></a> [threat\_intelligence\_allowlist](#input\_threat\_intelligence\_allowlist) | Threat intelligence allowlist configuration | <pre>object({<br>    ip_addresses = optional(list(string), [])<br>    fqdns        = optional(list(string), [])<br>  })</pre> | `null` | no |
| <a name="input_threat_intelligence_mode"></a> [threat\_intelligence\_mode](#input\_threat\_intelligence\_mode) | Threat intelligence mode for the firewall policy | `string` | `"Alert"` | no |
| <a name="input_tls_certificate"></a> [tls\_certificate](#input\_tls\_certificate) | TLS certificate configuration | <pre>object({<br>    key_vault_secret_id = string<br>    name                = string<br>  })</pre> | `null` | no |
| <a name="input_virtual_hub_configuration"></a> [virtual\_hub\_configuration](#input\_virtual\_hub\_configuration) | Virtual hub configuration for Secure Virtual Hub | <pre>object({<br>    virtual_hub_id  = string<br>    public_ip_count = optional(number, 1)<br>  })</pre> | `null` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_firewall_diagnostic_setting_id"></a> [firewall\_diagnostic\_setting\_id](#output\_firewall\_diagnostic\_setting\_id) | ID of the firewall diagnostic setting |
| <a name="output_firewall_id"></a> [firewall\_id](#output\_firewall\_id) | ID of the Azure Firewall |
| <a name="output_firewall_ip_configuration"></a> [firewall\_ip\_configuration](#output\_firewall\_ip\_configuration) | IP configuration of the Azure Firewall |
| <a name="output_firewall_module"></a> [firewall\_module](#output\_firewall\_module) | Complete Firewall module output object |
| <a name="output_firewall_name"></a> [firewall\_name](#output\_firewall\_name) | Name of the Azure Firewall |
| <a name="output_firewall_policy_child_policies"></a> [firewall\_policy\_child\_policies](#output\_firewall\_policy\_child\_policies) | List of child policies of the Firewall Policy |
| <a name="output_firewall_policy_diagnostic_setting_id"></a> [firewall\_policy\_diagnostic\_setting\_id](#output\_firewall\_policy\_diagnostic\_setting\_id) | ID of the firewall policy diagnostic setting |
| <a name="output_firewall_policy_firewalls"></a> [firewall\_policy\_firewalls](#output\_firewall\_policy\_firewalls) | List of firewalls associated with the Firewall Policy |
| <a name="output_firewall_policy_id"></a> [firewall\_policy\_id](#output\_firewall\_policy\_id) | ID of the Firewall Policy |
| <a name="output_firewall_policy_name"></a> [firewall\_policy\_name](#output\_firewall\_policy\_name) | Name of the Firewall Policy |
| <a name="output_firewall_private_ip_address"></a> [firewall\_private\_ip\_address](#output\_firewall\_private\_ip\_address) | Private IP address of the Azure Firewall |
| <a name="output_firewall_public_ip_addresses"></a> [firewall\_public\_ip\_addresses](#output\_firewall\_public\_ip\_addresses) | List of public IP addresses of the Azure Firewall |
| <a name="output_ip_group_ids"></a> [ip\_group\_ids](#output\_ip\_group\_ids) | Map of IP group names to their IDs |
| <a name="output_ip_group_names"></a> [ip\_group\_names](#output\_ip\_group\_names) | List of IP group names |
| <a name="output_ip_groups"></a> [ip\_groups](#output\_ip\_groups) | Map of IP groups |
| <a name="output_public_ip_addresses"></a> [public\_ip\_addresses](#output\_public\_ip\_addresses) | Map of public IP names to their IP addresses |
| <a name="output_public_ip_fqdns"></a> [public\_ip\_fqdns](#output\_public\_ip\_fqdns) | Map of public IP names to their FQDNs |
| <a name="output_public_ip_ids"></a> [public\_ip\_ids](#output\_public\_ip\_ids) | Map of public IP names to their IDs |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | ID of the resource group |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the resource group |
| <a name="output_rule_collection_group_ids"></a> [rule\_collection\_group\_ids](#output\_rule\_collection\_group\_ids) | Map of rule collection group names to their IDs |
| <a name="output_rule_collection_group_names"></a> [rule\_collection\_group\_names](#output\_rule\_collection\_group\_names) | List of rule collection group names |
| <a name="output_rule_collection_groups"></a> [rule\_collection\_groups](#output\_rule\_collection\_groups) | Map of rule collection groups |
<!-- END_TF_DOCS -->
