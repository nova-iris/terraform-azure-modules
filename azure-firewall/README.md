# Azure Firewall Module

This Terraform module creates and manages Azure Firewall with comprehensive security policies, rule collections, IP groups, and monitoring capabilities.

## Features

- **Azure Firewall**: Support for Standard and Premium SKUs
- **Firewall Policies**: Centralized policy management with inheritance
- **Rule Collections**: Application, Network, and NAT rule collections
- **IP Groups**: Centralized IP address management
- **Threat Intelligence**: Built-in threat intelligence with custom allowlists
- **Intrusion Detection**: Advanced threat protection (Premium SKU)
- **DNS Proxy**: DNS filtering and custom DNS servers
- **TLS Inspection**: SSL/TLS certificate inspection (Premium SKU)
- **Forced Tunneling**: Support for on-premises internet breakout
- **Monitoring**: Integration with Azure Monitor and diagnostic settings
- **High Availability**: Zone redundancy and availability zone support
- **Standardized Naming**: Uses Azure naming convention module

## Usage

### Basic Azure Firewall

```hcl
module "azure_firewall" {
  source = "./azure-firewall"

  # General Configuration
  location              = "East US"
  resource_group_name   = "rg-firewall-example"
  create_resource_group = true

  # Firewall Configuration
  firewall_sku_name = "AZFW_VNet"
  firewall_sku_tier = "Standard"
  firewall_zones    = ["1", "2", "3"]

  # Public IPs
  public_ips = {
    "firewall-pip" = {
      allocation_method = "Static"
      sku              = "Standard"
      zones            = ["1", "2", "3"]
    }
  }

  # IP Configuration
  ip_configurations = [
    {
      name           = "firewall-ipconfig"
      subnet_id      = "/subscriptions/.../subnets/AzureFirewallSubnet"
      public_ip_name = "firewall-pip"
    }
  ]

  # Firewall Policy
  create_firewall_policy   = true
  firewall_policy_sku      = "Standard"
  threat_intelligence_mode = "Alert"

  # Rule Collection Groups
  rule_collection_groups = {
    "app-rules" = {
      name     = "application-rules"
      priority = 1000

      application_rule_collections = [
        {
          name     = "allow-web-traffic"
          priority = 1100
          action   = "Allow"

          rules = [
            {
              name             = "allow-microsoft"
              source_addresses = ["10.0.0.0/16"]
              destination_fqdns = ["*.microsoft.com", "*.windows.net"]
              protocols = [
                {
                  type = "Https"
                  port = 443
                }
              ]
            },
            {
              name             = "allow-ubuntu-updates"
              source_addresses = ["10.0.1.0/24"]
              destination_fqdn_tags = ["AzureKubernetesService"]
              protocols = [
                {
                  type = "Http"
                  port = 80
                },
                {
                  type = "Https"
                  port = 443
                }
              ]
            }
          ]
        }
      ]

      network_rule_collections = [
        {
          name     = "allow-dns"
          priority = 1200
          action   = "Allow"

          rules = [
            {
              name                  = "allow-dns-traffic"
              protocols             = ["UDP"]
              source_addresses      = ["10.0.0.0/16"]
              destination_addresses = ["168.63.129.16"]
              destination_ports     = ["53"]
            }
          ]
        }
      ]
    }
  }

  tags = {
    Environment = "production"
    Security    = "required"
  }
}
```

### Premium Firewall with Advanced Features

```hcl
module "premium_firewall" {
  source = "./azure-firewall"

  # General Configuration
  location              = "East US"
  resource_group_name   = "rg-premium-firewall"
  create_resource_group = true

  # Premium Firewall Configuration
  firewall_sku_name = "AZFW_VNet"
  firewall_sku_tier = "Premium"
  firewall_zones    = ["1", "2", "3"]

  # Public IPs
  public_ips = {
    "fw-pip-1" = {
      allocation_method = "Static"
      sku              = "Standard"
      zones            = ["1", "2", "3"]
    }
  }

  # IP Configuration
  ip_configurations = [
    {
      name           = "firewall-config"
      subnet_id      = "/subscriptions/.../subnets/AzureFirewallSubnet"
      public_ip_name = "fw-pip-1"
    }
  ]

  # Premium Firewall Policy
  create_firewall_policy   = true
  firewall_policy_sku      = "Premium"
  threat_intelligence_mode = "Deny"

  # DNS Configuration
  dns_configuration = {
    proxy_enabled = true
    servers       = ["168.63.129.16"]
  }

  # Threat Intelligence Allowlist
  threat_intelligence_allowlist = {
    ip_addresses = ["203.0.113.0/24"]
    fqdns        = ["trusted-site.example.com"]
  }

  # Intrusion Detection
  intrusion_detection = {
    mode           = "Alert"
    private_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]

    signature_overrides = [
      {
        id    = "2024897"
        state = "Deny"
      }
    ]

    traffic_bypass = [
      {
        name                  = "bypass-internal-traffic"
        protocol              = "TCP"
        description           = "Bypass internal management traffic"
        source_addresses      = ["10.0.100.0/24"]
        destination_addresses = ["10.0.200.0/24"]
        destination_ports     = ["443", "80"]
      }
    ]
  }

  # TLS Certificate for inspection
  tls_certificate = {
    key_vault_secret_id = "/subscriptions/.../vaults/kv-certs/secrets/firewall-cert"
    name                = "firewall-inspection-cert"
  }

  # Identity for Key Vault access
  firewall_policy_identity = {
    type = "SystemAssigned"
  }

  # IP Groups
  ip_groups = {
    "internal-networks" = {
      name  = "internal-subnets"
      cidrs = ["10.0.0.0/16", "192.168.0.0/16"]
    }
    "dmz-networks" = {
      name  = "dmz-subnets"
      cidrs = ["172.16.0.0/24"]
    }
  }

  # Advanced Rule Collections
  rule_collection_groups = {
    "security-rules" = {
      name     = "security-policy"
      priority = 1000

      application_rule_collections = [
        {
          name     = "web-filtering"
          priority = 1100
          action   = "Allow"

          rules = [
            {
              name             = "allow-business-sites"
              source_ip_groups = ["internal-networks"]
              destination_fqdns = ["*.company.com", "*.business-partner.com"]
              web_categories   = ["Business", "ComputerInformationTechnology"]
              terminate_tls    = true

              protocols = [
                {
                  type = "Https"
                  port = 443
                }
              ]

              http_headers = [
                {
                  name  = "X-Custom-Header"
                  value = "firewall-inspection"
                }
              ]
            }
          ]
        }
      ]

      network_rule_collections = [
        {
          name     = "database-access"
          priority = 1200
          action   = "Allow"

          rules = [
            {
              name                  = "allow-sql-traffic"
              protocols             = ["TCP"]
              source_ip_groups      = ["internal-networks"]
              destination_ip_groups = ["dmz-networks"]
              destination_ports     = ["1433", "5432"]
            }
          ]
        }
      ]

      nat_rule_collections = [
        {
          name     = "inbound-nat"
          priority = 1300
          action   = "Dnat"

          rules = [
            {
              name                = "web-server-nat"
              protocols           = ["TCP"]
              source_addresses    = ["*"]
              destination_address = "20.1.2.3"  # Firewall public IP
              destination_ports   = ["80", "443"]
              translated_address  = "10.0.1.10"
              translated_port     = "80"
            }
          ]
        }
      ]
    }
  }

  # Monitoring
  enable_diagnostic_settings = true
  log_analytics_workspace_id = "/subscriptions/.../workspaces/law-security"

  firewall_logs = [
    "AzureFirewallApplicationRule",
    "AzureFirewallNetworkRule",
    "AzureFirewallDnsProxy",
    "AzureFirewallIdpsSignature"
  ]

  tags = {
    Environment = "production"
    Compliance  = "required"
    CostCenter  = "security"
  }
}
```

### Firewall with Forced Tunneling

```hcl
module "firewall_forced_tunneling" {
  source = "./azure-firewall"

  # General Configuration
  location              = "East US"
  resource_group_name   = "rg-firewall-tunnel"
  create_resource_group = true

  # Firewall Configuration
  firewall_sku_name = "AZFW_VNet"
  firewall_sku_tier = "Standard"

  # Public IPs for management
  public_ips = {
    "fw-pip-main" = {
      allocation_method = "Static"
      sku              = "Standard"
    }
    "fw-pip-mgmt" = {
      allocation_method = "Static"
      sku              = "Standard"
    }
  }

  # Main IP Configuration
  ip_configurations = [
    {
      name           = "firewall-config"
      subnet_id      = "/subscriptions/.../subnets/AzureFirewallSubnet"
      public_ip_name = "fw-pip-main"
    }
  ]

  # Management IP Configuration for forced tunneling
  management_ip_configuration = {
    name           = "firewall-mgmt-config"
    subnet_id      = "/subscriptions/.../subnets/AzureFirewallManagementSubnet"
    public_ip_name = "fw-pip-mgmt"
  }

  # Policy with minimal rules for forced tunneling
  create_firewall_policy   = true
  firewall_policy_sku      = "Standard"
  threat_intelligence_mode = "Alert"

  rule_collection_groups = {
    "essential-rules" = {
      name     = "essential-connectivity"
      priority = 1000

      network_rule_collections = [
        {
          name     = "allow-azure-services"
          priority = 1100
          action   = "Allow"

          rules = [
            {
              name                  = "azure-management"
              protocols             = ["TCP"]
              source_addresses      = ["10.0.0.0/16"]
              destination_addresses = ["AzureCloud"]
              destination_ports     = ["443"]
            }
          ]
        }
      ]
    }
  }

  tags = {
    Environment = "hybrid"
    Connectivity = "on-premises"
  }
}
```

### Secure Virtual Hub Firewall

```hcl
module "vwan_firewall" {
  source = "./azure-firewall"

  # General Configuration
  location              = "East US"
  resource_group_name   = "rg-vwan-firewall"
  create_resource_group = true

  # Virtual WAN Firewall Configuration
  firewall_sku_name = "AZFW_Hub"
  firewall_sku_tier = "Standard"

  # Virtual Hub Configuration
  virtual_hub_configuration = {
    virtual_hub_id  = "/subscriptions/.../virtualHubs/hub-eastus"
    public_ip_count = 2
  }

  # Centralized Policy
  create_firewall_policy   = true
  firewall_policy_sku      = "Standard"
  threat_intelligence_mode = "Alert"

  # Global rule collections
  rule_collection_groups = {
    "global-rules" = {
      name     = "global-security-policy"
      priority = 1000

      application_rule_collections = [
        {
          name     = "global-web-access"
          priority = 1100
          action   = "Allow"

          rules = [
            {
              name             = "allow-office365"
              source_addresses = ["*"]
              destination_fqdn_tags = ["Office365"]
              protocols = [
                {
                  type = "Https"
                  port = 443
                }
              ]
            }
          ]
        }
      ]
    }
  }

  tags = {
    Environment = "production"
    Network     = "global"
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 4.42.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 4.42.0 |

## Resources

| Name | Type |
|------|------|
| azurerm_firewall | resource |
| azurerm_firewall_policy | resource |
| azurerm_firewall_policy_rule_collection_group | resource |
| azurerm_public_ip | resource |
| azurerm_ip_group | resource |
| azurerm_monitor_diagnostic_setting | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| location | Azure region where resources will be created | `string` | n/a | yes |
| resource_group_name | Name of the resource group | `string` | n/a | yes |
| create_resource_group | Whether to create a new resource group | `bool` | `true` | no |
| firewall_sku_tier | SKU tier of the Azure Firewall | `string` | `"Standard"` | no |
| ip_configurations | List of IP configurations for the Azure Firewall | `list(object)` | `[]` | yes |
| create_firewall_policy | Whether to create a new firewall policy | `bool` | `true` | no |
| rule_collection_groups | Map of rule collection groups to create | `map(object)` | `{}` | no |
| ip_groups | Map of IP groups to create | `map(object)` | `{}` | no |
| enable_diagnostic_settings | Enable diagnostic settings for the firewall | `bool` | `false` | no |
| tags | A map of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| firewall_id | ID of the Azure Firewall |
| firewall_name | Name of the Azure Firewall |
| firewall_private_ip_address | Private IP address of the Azure Firewall |
| firewall_policy_id | ID of the Firewall Policy |
| public_ip_addresses | Map of public IP names to their IP addresses |
| ip_group_ids | Map of IP group names to their IDs |
| firewall_module | Complete Firewall module output object |

## Examples

The `examples/` directory contains:

- `basic/` - Basic Azure Firewall setup
- `premium/` - Premium firewall with advanced features
- `forced-tunneling/` - Firewall with forced tunneling
- `secure-virtual-hub/` - Virtual WAN integrated firewall

## Security Best Practices

1. **Use Premium SKU** for advanced threat protection in production
2. **Enable TLS Inspection** for encrypted traffic analysis
3. **Configure Intrusion Detection** to identify and block threats
4. **Use IP Groups** for centralized IP address management
5. **Enable Diagnostic Logging** for security monitoring and compliance
6. **Implement Zero Trust** principles with explicit allow rules
7. **Regular Policy Reviews** to ensure rules remain relevant and secure

## License

MIT License
<!-- END_TF_DOCS -->
