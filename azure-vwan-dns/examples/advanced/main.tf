# Advanced Virtual WAN DNS Setup with Hub Connectivity
# This example demonstrates a complete Virtual WAN hub-spoke DNS architecture

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.42.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Variables for the example
variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

# Create resource groups
resource "azurerm_resource_group" "dns" {
  name     = "rg-vwan-dns-advanced"
  location = "East US"

  tags = {
    Environment = "production"
    Example     = "advanced-vwan-dns"
  }
}

resource "azurerm_resource_group" "hub" {
  name     = "rg-vwan-hub"
  location = "East US"

  tags = {
    Environment = "production"
    Component   = "hub"
  }
}

# Create Virtual WAN Hub VNet (simplified for example)
resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  tags = {
    Environment = "production"
    Component   = "hub"
  }
}

# Create spoke VNet for demonstration
resource "azurerm_virtual_network" "spoke_app" {
  name                = "vnet-spoke-app"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  tags = {
    Environment = "production"
    Component   = "spoke"
    Purpose     = "application"
  }
}

# Deploy advanced Virtual WAN DNS setup
module "vwan_dns" {
  source = "../../"

  # Basic Configuration
  location              = azurerm_resource_group.dns.location
  resource_group_name   = azurerm_resource_group.dns.name
  create_resource_group = false

  # DNS VNet Configuration
  dns_vnet_name                     = "vnet-dns-prod"
  dns_vnet_address_space            = ["10.100.0.0/24"]
  dns_resolver_inbound_subnet_cidr  = "10.100.0.0/28"
  dns_resolver_outbound_subnet_cidr = "10.100.0.16/28"

  # Primary DNS Zone
  primary_dns_zone = "company.internal"

  # Additional DNS Zones with spoke VNet links
  additional_dns_zones = {
    "app-zone" = {
      name                 = "app.company.internal"
      registration_enabled = true
      spoke_vnet_links = {
        "app-spoke" = {
          virtual_network_id   = azurerm_virtual_network.spoke_app.id
          registration_enabled = false
        }
      }
      a_records = {
        "app-lb" = {
          name    = "app-loadbalancer"
          records = ["10.1.1.100"]
          ttl     = 300
        },
        "app-db" = {
          name    = "database"
          records = ["10.1.2.100"]
          ttl     = 300
        }
      }
      cname_records = {
        "app-frontend" = {
          name   = "frontend"
          record = "app-loadbalancer.app.company.internal"
          ttl    = 300
        }
      }
    },
    "privatelink-storage" = {
      name                 = "privatelink.blob.core.windows.net"
      registration_enabled = false
      spoke_vnet_links = {
        "app-spoke" = {
          virtual_network_id   = azurerm_virtual_network.spoke_app.id
          registration_enabled = false
        }
      }
    },
    "privatelink-sql" = {
      name                 = "privatelink.database.windows.net"
      registration_enabled = false
      spoke_vnet_links = {
        "app-spoke" = {
          virtual_network_id   = azurerm_virtual_network.spoke_app.id
          registration_enabled = false
        }
      }
    }
  }

  # Virtual WAN Hub Connectivity
  hub_virtual_network_id   = azurerm_virtual_network.hub.id
  hub_resource_group_name  = azurerm_resource_group.hub.name
  hub_virtual_network_name = azurerm_virtual_network.hub.name
  use_hub_gateway          = false

  # Tags
  tags = {
    Environment = "production"
    Project     = "vwan-dns"
    Owner       = "network-team"
    CostCenter  = "infrastructure"
  }
}

# Outputs
output "dns_architecture_summary" {
  description = "Summary of the DNS architecture"
  value       = module.vwan_dns.dns_architecture_summary
}

output "firewall_dns_configuration" {
  description = "Configuration for Azure Firewall DNS Proxy"
  value       = module.vwan_dns.firewall_dns_configuration
}

output "all_dns_zones" {
  description = "All configured DNS zones"
  value       = module.vwan_dns.all_dns_zones
}

# Example configuration guidance
output "next_steps" {
  description = "Next steps for completing the Virtual WAN DNS setup"
  value = {
    firewall_configuration = "Configure Azure Firewall with DNS servers: ${jsonencode(module.vwan_dns.firewall_dns_configuration.dns_servers)}"
    spoke_vnet_dns         = "Configure spoke VNets to use Azure Firewall private IP as DNS server"
    dns_zones_available    = "Available DNS zones: ${jsonencode(keys(module.vwan_dns.all_dns_zones))}"
    monitoring             = "Enable DNS query logging on Azure Firewall for monitoring and troubleshooting"
    dns_resolver_note      = "Note: DNS resolver endpoints require separate configuration with azurerm_private_dns_resolver resource"
  }
}
