# Azure Load Balancer Module

This Terraform module creates and manages Azure Load Balancers with comprehensive configuration options for frontend IPs, backend pools, health probes, load balancing rules, NAT rules, and outbound rules.

## Features

- **Multiple Load Balancer Types**: Support for public and internal load balancers
- **SKU Support**: Basic, Standard, and Gateway SKUs
- **Frontend IP Configurations**: Multiple frontend IPs with public or private endpoints
- **Backend Pools**: Flexible backend address pool management with IP addresses and NIC associations
- **Health Probes**: HTTP, HTTPS, and TCP health probes
- **Load Balancing Rules**: Comprehensive rule configuration with session persistence
- **NAT Rules**: Inbound NAT rules and NAT pools for direct VM access
- **Outbound Rules**: SNAT configuration for Standard SKU load balancers
- **High Availability**: Zone redundancy and availability zone support
- **Monitoring**: Integration with Azure Monitor and diagnostics
- **Standardized Naming**: Uses Azure naming convention module

## Usage

### Basic Public Load Balancer

```hcl
module "public_load_balancer" {
  source = "./azure-load-balancer"

  # General Configuration
  location              = "East US"
  resource_group_name   = "rg-lb-example"
  create_resource_group = true

  # Load Balancer Configuration
  load_balancer_sku      = "Standard"
  load_balancer_sku_tier = "Regional"

  # Public IPs
  public_ips = {
    "lb-frontend" = {
      allocation_method = "Static"
      sku              = "Standard"
      zones            = ["1", "2", "3"]
      domain_name_label = "my-app-lb"
    }
  }

  # Frontend IP Configuration
  frontend_ip_configurations = [
    {
      name           = "frontend-ip"
      public_ip_name = "lb-frontend"
    }
  ]

  # Backend Address Pools
  backend_address_pools = {
    "web-servers" = {
      name = "web-servers-pool"
      
      # Static IP addresses
      addresses = [
        {
          name               = "web-01"
          virtual_network_id = "/subscriptions/.../virtualNetworks/vnet-app"
          ip_address         = "10.0.1.10"
        },
        {
          name               = "web-02"
          virtual_network_id = "/subscriptions/.../virtualNetworks/vnet-app"
          ip_address         = "10.0.1.11"
        }
      ]
    }
  }

  # Health Probes
  health_probes = {
    "http-probe" = {
      name                = "http-health-probe"
      protocol            = "Http"
      port                = 80
      request_path        = "/health"
      interval_in_seconds = 15
      number_of_probes    = 2
    }
  }

  # Load Balancing Rules
  load_balancing_rules = {
    "http-rule" = {
      name                           = "http-lb-rule"
      protocol                       = "Tcp"
      frontend_port                  = 80
      backend_port                   = 80
      frontend_ip_configuration_name = "frontend-ip"
      backend_address_pool_names     = ["web-servers"]
      probe_name                     = "http-probe"
      load_distribution              = "Default"
      idle_timeout_in_minutes        = 4
    }
  }

  tags = {
    Environment = "production"
    Application = "web-app"
  }
}
```

### Internal Load Balancer

```hcl
module "internal_load_balancer" {
  source = "./azure-load-balancer"

  # General Configuration
  location              = "East US"
  resource_group_name   = "rg-internal-lb"
  create_resource_group = true

  # Load Balancer Configuration
  load_balancer_sku = "Standard"

  # Frontend IP Configuration (Internal)
  frontend_ip_configurations = [
    {
      name                          = "internal-frontend"
      subnet_id                     = "/subscriptions/.../subnets/subnet-internal"
      private_ip_address            = "10.0.2.10"
      private_ip_address_allocation = "Static"
    }
  ]

  # Backend Address Pools with NIC associations
  backend_address_pools = {
    "database-servers" = {
      name = "db-servers-pool"
      
      network_interface_associations = [
        {
          network_interface_id  = "/subscriptions/.../networkInterfaces/nic-db-01"
          ip_configuration_name = "internal"
        },
        {
          network_interface_id  = "/subscriptions/.../networkInterfaces/nic-db-02"
          ip_configuration_name = "internal"
        }
      ]
    }
  }

  # Health Probes
  health_probes = {
    "tcp-probe" = {
      name     = "db-tcp-probe"
      protocol = "Tcp"
      port     = 5432
    }
  }

  # Load Balancing Rules
  load_balancing_rules = {
    "db-rule" = {
      name                           = "database-lb-rule"
      protocol                       = "Tcp"
      frontend_port                  = 5432
      backend_port                   = 5432
      frontend_ip_configuration_name = "internal-frontend"
      backend_address_pool_names     = ["database-servers"]
      probe_name                     = "tcp-probe"
    }
  }

  tags = {
    Environment = "production"
    Tier        = "database"
  }
}
```

### Load Balancer with NAT Rules

```hcl
module "lb_with_nat" {
  source = "./azure-load-balancer"

  # General Configuration
  location              = "East US"
  resource_group_name   = "rg-lb-nat"
  create_resource_group = true

  # Public IPs
  public_ips = {
    "lb-public" = {
      allocation_method = "Static"
      sku              = "Standard"
    }
  }

  # Frontend IP Configuration
  frontend_ip_configurations = [
    {
      name           = "frontend-public"
      public_ip_name = "lb-public"
    }
  ]

  # Backend Address Pools
  backend_address_pools = {
    "vm-pool" = {
      name = "virtual-machines"
    }
  }

  # Load Balancing Rules
  load_balancing_rules = {
    "web-rule" = {
      name                           = "web-traffic"
      protocol                       = "Tcp"
      frontend_port                  = 80
      backend_port                   = 80
      frontend_ip_configuration_name = "frontend-public"
      backend_address_pool_names     = ["vm-pool"]
    }
  }

  # Inbound NAT Rules for RDP/SSH access
  inbound_nat_rules = {
    "vm1-rdp" = {
      name                           = "vm1-rdp-access"
      protocol                       = "Tcp"
      frontend_port                  = 3389
      backend_port                   = 3389
      frontend_ip_configuration_name = "frontend-public"
      
      network_interface_associations = [
        {
          network_interface_id = "/subscriptions/.../networkInterfaces/nic-vm-01"
        }
      ]
    },
    "vm2-rdp" = {
      name                           = "vm2-rdp-access"
      protocol                       = "Tcp"
      frontend_port                  = 3390
      backend_port                   = 3389
      frontend_ip_configuration_name = "frontend-public"
      
      network_interface_associations = [
        {
          network_interface_id = "/subscriptions/.../networkInterfaces/nic-vm-02"
        }
      ]
    }
  }

  # NAT Pool for Scale Sets
  inbound_nat_pools = {
    "ssh-pool" = {
      name                           = "ssh-nat-pool"
      protocol                       = "Tcp"
      frontend_port_start            = 50000
      frontend_port_end              = 50099
      backend_port                   = 22
      frontend_ip_configuration_name = "frontend-public"
    }
  }

  tags = {
    Environment = "development"
    Purpose     = "testing"
  }
}
```

### Standard Load Balancer with Outbound Rules

```hcl
module "standard_lb_outbound" {
  source = "./azure-load-balancer"

  # General Configuration
  location              = "East US"
  resource_group_name   = "rg-standard-lb"
  create_resource_group = true

  # Load Balancer Configuration
  load_balancer_sku = "Standard"

  # Multiple Public IPs for outbound SNAT
  public_ips = {
    "inbound-ip" = {
      allocation_method = "Static"
      sku              = "Standard"
    }
    "outbound-ip-1" = {
      allocation_method = "Static"
      sku              = "Standard"
    }
    "outbound-ip-2" = {
      allocation_method = "Static"
      sku              = "Standard"
    }
  }

  # Frontend IP Configurations
  frontend_ip_configurations = [
    {
      name           = "inbound-frontend"
      public_ip_name = "inbound-ip"
    },
    {
      name           = "outbound-frontend-1"
      public_ip_name = "outbound-ip-1"
    },
    {
      name           = "outbound-frontend-2"
      public_ip_name = "outbound-ip-2"
    }
  ]

  # Backend Address Pools
  backend_address_pools = {
    "app-servers" = {
      name = "application-servers"
    }
  }

  # Load Balancing Rules
  load_balancing_rules = {
    "app-rule" = {
      name                           = "application-rule"
      protocol                       = "Tcp"
      frontend_port                  = 443
      backend_port                   = 443
      frontend_ip_configuration_name = "inbound-frontend"
      backend_address_pool_names     = ["app-servers"]
      disable_outbound_snat          = true  # Use outbound rule instead
    }
  }

  # Outbound Rules for explicit SNAT
  outbound_rules = {
    "internet-access" = {
      name                      = "outbound-internet"
      protocol                  = "All"
      backend_address_pool_name = "app-servers"
      allocated_outbound_ports  = 1024
      idle_timeout_in_minutes   = 4
      
      frontend_ip_configurations = [
        { name = "outbound-frontend-1" },
        { name = "outbound-frontend-2" }
      ]
    }
  }

  tags = {
    Environment = "production"
    Compliance  = "required"
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
| azurerm_lb | resource |
| azurerm_public_ip | resource |
| azurerm_lb_backend_address_pool | resource |
| azurerm_lb_backend_address_pool_address | resource |
| azurerm_network_interface_backend_address_pool_association | resource |
| azurerm_lb_probe | resource |
| azurerm_lb_rule | resource |
| azurerm_lb_nat_rule | resource |
| azurerm_network_interface_nat_rule_association | resource |
| azurerm_lb_nat_pool | resource |
| azurerm_lb_outbound_rule | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| location | Azure region where resources will be created | `string` | n/a | yes |
| resource_group_name | Name of the resource group | `string` | n/a | yes |
| create_resource_group | Whether to create a new resource group | `bool` | `true` | no |
| load_balancer_sku | SKU of the Load Balancer | `string` | `"Standard"` | no |
| public_ips | Map of public IPs to create for the load balancer | `map(object)` | `{}` | no |
| frontend_ip_configurations | List of frontend IP configurations | `list(object)` | `[]` | yes |
| backend_address_pools | Map of backend address pools to create | `map(object)` | `{}` | yes |
| health_probes | Map of health probes to create | `map(object)` | `{}` | no |
| load_balancing_rules | Map of load balancing rules to create | `map(object)` | `{}` | no |
| inbound_nat_rules | Map of inbound NAT rules to create | `map(object)` | `{}` | no |
| inbound_nat_pools | Map of inbound NAT pools to create | `map(object)` | `{}` | no |
| outbound_rules | Map of outbound rules to create | `map(object)` | `{}` | no |
| tags | A map of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| load_balancer_id | ID of the Load Balancer |
| load_balancer_name | Name of the Load Balancer |
| public_ip_addresses | Map of public IP names to their IP addresses |
| backend_address_pool_ids | Map of backend address pool names to their IDs |
| health_probe_ids | Map of health probe names to their IDs |
| load_balancing_rule_ids | Map of load balancing rule names to their IDs |
| load_balancer_module | Complete Load Balancer module output object |

## Examples

The `examples/` directory contains:

- `basic-public/` - Basic public load balancer
- `internal/` - Internal load balancer
- `standard-with-outbound/` - Standard SKU with outbound rules
- `nat-rules/` - Load balancer with NAT rules

## Best Practices

1. **Use Standard SKU** for production workloads for better features and SLA
2. **Health Probes** are essential for high availability
3. **Outbound Rules** provide explicit control over SNAT ports in Standard SKU
4. **Zone Redundancy** improves availability across Azure regions
5. **Session Persistence** should be configured based on application requirements

## License

MIT License
<!-- END_TF_DOCS -->
