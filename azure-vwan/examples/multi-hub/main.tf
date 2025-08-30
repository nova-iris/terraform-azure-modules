# Multi-Hub Azure Virtual WAN Example
# This example creates a Virtual WAN with multiple hubs across different regions

# Create sample VNets in different regions
resource "azurerm_resource_group" "east" {
  name     = "vwan-east-rg"
  location = "East US"
}

resource "azurerm_resource_group" "west" {
  name     = "vwan-west-rg"
  location = "West US"
}

resource "azurerm_virtual_network" "east_spoke" {
  name                = "east-spoke-vnet"
  address_space       = ["10.100.0.0/16"]
  location            = azurerm_resource_group.east.location
  resource_group_name = azurerm_resource_group.east.name
}

resource "azurerm_virtual_network" "west_spoke" {
  name                = "west-spoke-vnet"
  address_space       = ["10.200.0.0/16"]
  location            = azurerm_resource_group.west.location
  resource_group_name = azurerm_resource_group.west.name
}

# Multi-hub VWAN deployment
module "multi_hub_vwan" {
  source = "../.."

  name                           = "global-vwan"
  location                       = "East US"
  resource_group_name            = "global-vwan-rg"
  wan_type                       = "Standard"
  allow_branch_to_branch_traffic = true

  # Azure naming convention configuration
  naming_convention = {
    prefix = ["global"]
    suffix = ["multi"]
  }

  virtual_hubs = [
    # East US Hub - Primary
    {
      name                                   = "hub-eastus"
      location                               = "East US"
      address_prefix                         = "10.0.0.0/23"
      sku                                    = "Standard"
      hub_routing_preference                 = "ExpressRoute"
      virtual_router_auto_scale_min_capacity = 3

      # Primary connectivity gateways
      vpn_gateway = {
        enable     = true
        scale_unit = 2

        bgp_settings = {
          asn = 65001
        }
      }

      expressroute_gateway = {
        enable     = true
        scale_unit = 3
      }

      # VNet connections in East US
      vnet_connections = {
        east-spoke = {
          remote_virtual_network_id = azurerm_virtual_network.east_spoke.id
          internet_security_enabled = false

          routing = {
            propagated_route_table = {
              labels = ["east", "default"]
            }
          }
        }
      }
    },

    # West US Hub - Secondary
    {
      name                                   = "hub-westus"
      location                               = "West US"
      address_prefix                         = "10.1.0.0/23"
      sku                                    = "Standard"
      hub_routing_preference                 = "ExpressRoute"
      virtual_router_auto_scale_min_capacity = 2

      # Secondary connectivity gateways
      vpn_gateway = {
        enable     = true
        scale_unit = 1

        bgp_settings = {
          asn = 65002
        }
      }

      expressroute_gateway = {
        enable     = true
        scale_unit = 2
      }

      # VNet connections in West US
      vnet_connections = {
        west-spoke = {
          remote_virtual_network_id = azurerm_virtual_network.west_spoke.id
          internet_security_enabled = false

          routing = {
            propagated_route_table = {
              labels = ["west", "default"]
            }
          }
        }
      }
    },

    # Europe West Hub - Tertiary
    {
      name           = "hub-westeurope"
      location       = "West Europe"
      address_prefix = "10.2.0.0/23"
      sku            = "Standard"

      # Basic connectivity for Europe
      vpn_gateway = {
        enable     = true
        scale_unit = 1

        bgp_settings = {
          asn = 65003
        }
      }

      expressroute_gateway = {
        enable     = true
        scale_unit = 1
      }
    }
  ]

  tags = {
    Environment = "production"
    Project     = "global-connectivity"
    CostCenter  = "IT-Global"
    Owner       = "network-ops"
    Deployment  = "multi-region"
  }
}

# Outputs
output "vwan_details" {
  description = "Complete VWAN details"
  value = {
    vwan_id          = module.multi_hub_vwan.vwan_id
    vwan_name        = module.multi_hub_vwan.vwan_name
    virtual_hubs     = module.multi_hub_vwan.virtual_hubs
    vpn_gateways     = module.multi_hub_vwan.vpn_gateways
    er_gateways      = module.multi_hub_vwan.expressroute_gateways
    vnet_connections = module.multi_hub_vwan.vnet_connections
  }
}

output "hub_connectivity_matrix" {
  description = "Hub connectivity information"
  value = {
    for hub_name, hub in module.multi_hub_vwan.virtual_hubs : hub_name => {
      location               = hub.location
      address_prefix         = hub.address_prefix
      default_route_table_id = hub.default_route_table_id
      router_asn             = hub.virtual_router_asn
      router_ips             = hub.virtual_router_ips
    }
  }
}
