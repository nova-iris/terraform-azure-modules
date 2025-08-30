# Hub-Spoke Architecture Example
# This example demonstrates a hub-spoke network topology with VNet peering

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.42.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

# Data sources for existing resource groups
data "azurerm_resource_group" "hub" {
  name = var.hub_resource_group_name
}

data "azurerm_resource_group" "spoke1" {
  name = var.spoke1_resource_group_name
}

data "azurerm_resource_group" "spoke2" {
  name = var.spoke2_resource_group_name
}

# Hub VNet - Central connectivity hub
module "hub_vnet" {
  source = "../../"

  name                  = "hub-vnet"
  location              = data.azurerm_resource_group.hub.location
  resource_group_name   = data.azurerm_resource_group.hub.name
  create_resource_group = false
  address_space         = ["10.0.0.0/16"]

  # Azure naming convention configuration
  naming_convention = {
    prefix = ["hub"]
    suffix = ["eastus"]
  }

  subnets = [
    {
      name             = "GatewaySubnet"
      address_prefixes = ["10.0.1.0/27"]
      create_nsg       = false # Gateway subnet doesn't use NSG
    },
    {
      name             = "AzureFirewallSubnet"
      address_prefixes = ["10.0.2.0/26"]
      create_nsg       = false # Firewall subnet doesn't use NSG
    },
    {
      name             = "shared-services"
      address_prefixes = ["10.0.3.0/24"]
      create_nsg       = true

      security_rules = [
        {
          name                       = "allow-rdp"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "3389"
          source_address_prefixes    = ["10.1.0.0/16", "10.2.0.0/16"] # From spokes
          destination_address_prefix = "*"
        },
        {
          name                       = "allow-ssh"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefixes    = ["10.1.0.0/16", "10.2.0.0/16"] # From spokes
          destination_address_prefix = "*"
        }
      ]
    },
    {
      name             = "management"
      address_prefixes = ["10.0.4.0/24"]
      create_nsg       = true

      security_rules = [
        {
          name                       = "allow-management"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_ranges    = ["22", "3389", "443"]
          source_address_prefix      = "10.0.0.0/8" # Private ranges only
          destination_address_prefix = "*"
        }
      ]
    }
  ]

  enable_ddos_protection = true

  tags = {
    Environment = "hub"
    Role        = "connectivity"
    Purpose     = "shared-services"
  }
}

# Spoke 1 VNet - Production workloads
module "spoke1_vnet" {
  source = "../../"

  name                  = "spoke1-vnet"
  location              = data.azurerm_resource_group.spoke1.location
  resource_group_name   = data.azurerm_resource_group.spoke1.name
  create_resource_group = false
  address_space         = ["10.1.0.0/16"]

  # Azure naming convention configuration
  naming_convention = {
    prefix = ["spoke1"]
    suffix = ["prod"]
  }

  subnets = [
    {
      name               = "web-tier"
      address_prefixes   = ["10.1.1.0/24"]
      create_nsg         = true
      create_route_table = true

      security_rules = [
        {
          name                       = "allow-http-https"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_ranges    = ["80", "443"]
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "allow-app-tier"
          priority                   = 200
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "8080"
          source_address_prefix      = "*"
          destination_address_prefix = "10.1.2.0/24"
        }
      ]

      routes = [
        {
          name                   = "to-hub-firewall"
          address_prefix         = "0.0.0.0/0"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = "10.0.2.4" # Azure Firewall IP
        }
      ]
    },
    {
      name              = "app-tier"
      address_prefixes  = ["10.1.2.0/24"]
      create_nsg        = true
      service_endpoints = ["Microsoft.Sql", "Microsoft.Storage"]

      security_rules = [
        {
          name                       = "allow-web-tier"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "8080"
          source_address_prefix      = "10.1.1.0/24"
          destination_address_prefix = "*"
        },
        {
          name                       = "allow-db-tier"
          priority                   = 200
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "1433"
          source_address_prefix      = "*"
          destination_address_prefix = "10.1.3.0/24"
        }
      ]
    },
    {
      name              = "db-tier"
      address_prefixes  = ["10.1.3.0/24"]
      create_nsg        = true
      service_endpoints = ["Microsoft.Sql"]

      security_rules = [
        {
          name                       = "allow-app-tier"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "1433"
          source_address_prefix      = "10.1.2.0/24"
          destination_address_prefix = "*"
        },
        {
          name                       = "deny-all-inbound"
          priority                   = 4000
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }
  ]

  vnet_peerings = {
    to-hub = {
      name                      = "spoke1-to-hub"
      remote_virtual_network_id = module.hub_vnet.vnet_id
      allow_forwarded_traffic   = true
      use_remote_gateways       = true
    }
  }

  tags = {
    Environment = "production"
    Role        = "workload"
    Application = "web-app"
    Tier        = "production"
  }
}

# Spoke 2 VNet - Development workloads
module "spoke2_vnet" {
  source = "../../"

  name                  = "spoke2-vnet"
  location              = data.azurerm_resource_group.spoke2.location
  resource_group_name   = data.azurerm_resource_group.spoke2.name
  create_resource_group = false
  address_space         = ["10.2.0.0/16"]

  # Azure naming convention configuration
  naming_convention = {
    prefix = ["spoke2"]
    suffix = ["dev"]
  }

  subnets = [
    {
      name               = "dev-workloads"
      address_prefixes   = ["10.2.1.0/24"]
      create_nsg         = true
      create_route_table = true

      security_rules = [
        {
          name                       = "allow-dev-access"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_ranges    = ["22", "80", "443", "8080"]
          source_address_prefix      = "10.0.3.0/24" # From hub management subnet
          destination_address_prefix = "*"
        }
      ]

      routes = [
        {
          name                   = "to-hub-firewall"
          address_prefix         = "0.0.0.0/0"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = "10.0.2.4" # Azure Firewall IP
        }
      ]
    },
    {
      name              = "dev-storage"
      address_prefixes  = ["10.2.2.0/24"]
      create_nsg        = true
      service_endpoints = ["Microsoft.Storage"]
    }
  ]

  vnet_peerings = {
    to-hub = {
      name                      = "spoke2-to-hub"
      remote_virtual_network_id = module.hub_vnet.vnet_id
      allow_forwarded_traffic   = true
      use_remote_gateways       = true
    }
  }

  tags = {
    Environment = "development"
    Role        = "workload"
    Application = "dev-environment"
    Tier        = "development"
  }
}

# Hub-to-Spoke peerings (return connections)
resource "azurerm_virtual_network_peering" "hub_to_spoke1" {
  name                      = "hub-to-spoke1"
  resource_group_name       = data.azurerm_resource_group.hub.name
  virtual_network_name      = module.hub_vnet.vnet_name
  remote_virtual_network_id = module.spoke1_vnet.vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "hub_to_spoke2" {
  name                      = "hub-to-spoke2"
  resource_group_name       = data.azurerm_resource_group.hub.name
  virtual_network_name      = module.hub_vnet.vnet_name
  remote_virtual_network_id = module.spoke2_vnet.vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}

# Outputs
output "hub_vnet_id" {
  description = "Hub VNet ID"
  value       = module.hub_vnet.vnet_id
}

output "spoke1_vnet_id" {
  description = "Spoke 1 VNet ID"
  value       = module.spoke1_vnet.vnet_id
}

output "spoke2_vnet_id" {
  description = "Spoke 2 VNet ID"
  value       = module.spoke2_vnet.vnet_id
}

output "peering_connections" {
  description = "All peering connections"
  value = {
    hub_to_spoke1 = azurerm_virtual_network_peering.hub_to_spoke1.id
    hub_to_spoke2 = azurerm_virtual_network_peering.hub_to_spoke2.id
    spoke1_to_hub = module.spoke1_vnet.vnet_peering_ids
    spoke2_to_hub = module.spoke2_vnet.vnet_peering_ids
  }
}
