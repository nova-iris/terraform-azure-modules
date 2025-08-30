# Basic Virtual WAN DNS Setup Example
# This example creates a simple DNS VNet with Private DNS Resolver

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

# Create resource group for the example
resource "azurerm_resource_group" "example" {
  name     = "rg-vwan-dns-basic-example"
  location = "East US"

  tags = {
    Environment = "demo"
    Example     = "basic-vwan-dns"
  }
}

# Deploy basic Virtual WAN DNS setup
module "vwan_dns" {
  source = "../../"

  # Basic Configuration
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  create_resource_group = false

  # DNS VNet Configuration
  dns_vnet_name          = "vnet-dns-basic"
  dns_vnet_address_space = ["10.100.0.0/24"]

  # DNS Resolver Subnets
  dns_resolver_inbound_subnet_cidr  = "10.100.0.0/28"
  dns_resolver_outbound_subnet_cidr = "10.100.0.16/28"

  # Primary DNS Zone
  primary_dns_zone = "basic.company.com"

  # Tags
  tags = {
    Environment = "demo"
    Example     = "basic-vwan-dns"
    Purpose     = "testing"
  }
}

# Outputs
output "dns_vnet_id" {
  description = "Resource ID of the DNS VNet"
  value       = module.vwan_dns.dns_vnet_id
}

output "dns_resolver_inbound_ip" {
  description = "Private IP address of the DNS resolver inbound endpoint"
  value       = module.vwan_dns.dns_resolver_inbound_endpoint_ip
}

output "primary_dns_zone_name" {
  description = "Name of the primary DNS zone"
  value       = module.vwan_dns.primary_dns_zone_name
}

output "firewall_dns_configuration" {
  description = "Configuration for Azure Firewall DNS Proxy"
  value       = module.vwan_dns.firewall_dns_configuration
}
