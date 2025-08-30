# Azure Private DNS Module

This Terraform module creates and manages Azure Private DNS zones, virtual network links, DNS records, and Private DNS Resolvers with inbound/outbound endpoints.

## Features

- **Private DNS Zone**: Create and manage private DNS zones
- **Virtual Network Links**: Link virtual networks to private DNS zones
- **DNS Records**: Support for A, AAAA, CNAME, MX, PTR, SRV, and TXT records
- **Private Link Integration**: DNS zone groups for private endpoints
- **Private DNS Resolver**: Optional DNS resolver with inbound/outbound endpoints
- **DNS Forwarding**: Configurable DNS forwarding rules and rulesets
- **Standardized Naming**: Uses Azure naming convention module
- **Comprehensive Tagging**: Built-in tagging strategy

## Usage

### Basic Private DNS Zone

```hcl
module "private_dns" {
  source = "./azure-private-dns"

  # General Configuration
  location                = "East US"
  resource_group_name     = "rg-dns-example"
  create_resource_group   = true
  private_dns_zone_name   = "example.internal"

  # Virtual Network Links
  virtual_network_links = {
    "hub-vnet" = {
      virtual_network_id   = "/subscriptions/.../virtualNetworks/vnet-hub"
      registration_enabled = true
    }
    "spoke-vnet" = {
      virtual_network_id   = "/subscriptions/.../virtualNetworks/vnet-spoke"
      registration_enabled = false
    }
  }

  # DNS Records
  a_records = {
    "web" = {
      name    = "web"
      ttl     = 300
      records = ["10.0.1.4", "10.0.1.5"]
    }
    "api" = {
      name    = "api"
      ttl     = 300
      records = ["10.0.2.10"]
    }
  }

  cname_records = {
    "www" = {
      name   = "www"
      ttl    = 300
      record = "web.example.internal"
    }
  }

  tags = {
    Environment = "production"
    Project     = "web-app"
  }
}
```

### Private DNS with DNS Resolver

```hcl
module "private_dns_with_resolver" {
  source = "./azure-private-dns"

  # General Configuration
  location                = "East US"
  resource_group_name     = "rg-dns-resolver"
  create_resource_group   = true
  private_dns_zone_name   = "corp.internal"

  # DNS Resolver Configuration
  enable_dns_resolver              = true
  dns_resolver_virtual_network_id  = "/subscriptions/.../virtualNetworks/vnet-hub"
  
  # Inbound Endpoint
  enable_inbound_endpoint = true
  inbound_endpoint_ip_configurations = [
    {
      subnet_id                    = "/subscriptions/.../subnets/subnet-dns-inbound"
      private_ip_allocation_method = "Static"
      private_ip_address           = "10.0.100.10"
    }
  ]

  # Outbound Endpoint
  enable_outbound_endpoint     = true
  outbound_endpoint_subnet_id  = "/subscriptions/.../subnets/subnet-dns-outbound"

  # DNS Forwarding
  dns_forwarding_rulesets = {
    "external-dns" = {
      name = "external-dns-rules"
      forwarding_rules = [
        {
          name        = "onprem-forward"
          domain_name = "onprem.corp.com."
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
      ]
      virtual_network_links = [
        {
          name               = "hub-vnet-link"
          virtual_network_id = "/subscriptions/.../virtualNetworks/vnet-hub"
        }
      ]
    }
  }

  tags = {
    Environment = "production"
    Project     = "hybrid-dns"
  }
}
```

### Private Link DNS Integration

```hcl
module "private_dns_privatelink" {
  source = "./azure-private-dns"

  # General Configuration
  location                = "East US"
  resource_group_name     = "rg-privatelink-dns"
  create_resource_group   = true
  private_dns_zone_name   = "privatelink.blob.core.windows.net"

  # Virtual Network Links
  virtual_network_links = {
    "app-vnet" = {
      virtual_network_id   = "/subscriptions/.../virtualNetworks/vnet-app"
      registration_enabled = false
    }
  }

  # Private Endpoint DNS Zone Groups
  private_endpoint_dns_zone_groups = {
    "storage-endpoint" = {
      name                = "storage-dns-group"
      private_endpoint_id = "/subscriptions/.../privateEndpoints/pe-storage"
      private_dns_zone_configs = [
        {
          name = "blob-config"
          # private_dns_zone_id will use the module's DNS zone by default
        }
      ]
    }
  }

  tags = {
    Environment = "production"
    Service     = "storage"
  }
}
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

## Resources

| Name | Type |
|------|------|
| azurerm_private_dns_zone | resource |
| azurerm_private_dns_zone_virtual_network_link | resource |
| azurerm_private_dns_a_record | resource |
| azurerm_private_dns_aaaa_record | resource |
| azurerm_private_dns_cname_record | resource |
| azurerm_private_dns_mx_record | resource |
| azurerm_private_dns_ptr_record | resource |
| azurerm_private_dns_srv_record | resource |
| azurerm_private_dns_txt_record | resource |
| azurerm_private_dns_zone_group | resource |
| azurerm_private_dns_resolver | resource |
| azurerm_private_dns_resolver_inbound_endpoint | resource |
| azurerm_private_dns_resolver_outbound_endpoint | resource |
| azurerm_private_dns_resolver_dns_forwarding_ruleset | resource |
| azurerm_private_dns_resolver_forwarding_rule | resource |
| azurerm_private_dns_resolver_virtual_network_link | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| private_dns_zone_name | Name of the private DNS zone | `string` | n/a | yes |
| location | Azure region where resources will be created | `string` | n/a | yes |
| resource_group_name | Name of the resource group | `string` | n/a | yes |
| create_resource_group | Whether to create a new resource group | `bool` | `true` | no |
| virtual_network_links | Map of virtual network links to create | `map(object)` | `{}` | no |
| a_records | Map of A records to create | `map(object)` | `{}` | no |
| aaaa_records | Map of AAAA records to create | `map(object)` | `{}` | no |
| cname_records | Map of CNAME records to create | `map(object)` | `{}` | no |
| mx_records | Map of MX records to create | `map(object)` | `{}` | no |
| ptr_records | Map of PTR records to create | `map(object)` | `{}` | no |
| srv_records | Map of SRV records to create | `map(object)` | `{}` | no |
| txt_records | Map of TXT records to create | `map(object)` | `{}` | no |
| enable_dns_resolver | Enable Private DNS Resolver | `bool` | `false` | no |
| enable_inbound_endpoint | Enable inbound endpoint for DNS resolver | `bool` | `false` | no |
| enable_outbound_endpoint | Enable outbound endpoint for DNS resolver | `bool` | `false` | no |
| dns_forwarding_rulesets | Map of DNS forwarding rulesets to create | `map(object)` | `{}` | no |
| tags | A map of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| private_dns_zone_id | ID of the Private DNS zone |
| private_dns_zone_name | Name of the Private DNS zone |
| virtual_network_link_ids | Map of virtual network link names to their IDs |
| dns_resolver_id | ID of the Private DNS Resolver |
| dns_resolver_inbound_endpoint_id | ID of the DNS Resolver inbound endpoint |
| dns_resolver_outbound_endpoint_id | ID of the DNS Resolver outbound endpoint |
| private_dns_module | Complete Private DNS module output object |

## Examples

The `examples/` directory contains:

- `basic/` - Basic private DNS zone with records
- `advanced/` - DNS resolver with forwarding rules
- `privatelink/` - Private Link DNS integration

## License

MIT License
