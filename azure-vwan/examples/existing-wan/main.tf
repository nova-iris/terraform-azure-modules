# Example: Using Existing Virtual WAN
# This example shows how to create virtual hubs in an existing Virtual WAN

module "existing_vwan_hubs" {
  source = "../.."

  # Don't create a new Virtual WAN, use existing one
  create_virtual_wan      = false
  existing_virtual_wan_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/central-wan-rg/providers/Microsoft.Network/virtualWans/corporate-wan"

  # Basic configuration (only needed for resource group management)
  name                = "regional-hubs"
  location            = "East US" # This can be different from WAN location
  resource_group_name = "regional-hubs-rg"

  # Azure naming convention configuration
  naming_convention = {
    prefix = ["corp"]
    suffix = ["region"]
  }

  virtual_hubs = [
    # Hub in East US
    {
      name           = "hub-eastus"
      location       = "East US"
      address_prefix = "10.1.0.0/23"
      sku            = "Standard"

      # VPN Gateway for branch connectivity
      vpn_gateway = {
        enable     = true
        scale_unit = 1

        bgp_settings = {
          asn = 65001
        }
      }

      # ExpressRoute Gateway for hybrid connectivity
      expressroute_gateway = {
        enable     = true
        scale_unit = 1
      }

      # VNet connections
      vnet_connections = {
        prod-eastus = {
          remote_virtual_network_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/prod-eastus-rg/providers/Microsoft.Network/virtualNetworks/prod-eastus-vnet"
          internet_security_enabled = false
        }
        shared-eastus = {
          remote_virtual_network_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/shared-rg/providers/Microsoft.Network/virtualNetworks/shared-eastus-vnet"
          internet_security_enabled = false
        }
      }
    },

    # Hub in West US
    {
      name           = "hub-westus"
      location       = "West US"
      address_prefix = "10.2.0.0/23"
      sku            = "Standard"

      # VPN Gateway for branch connectivity
      vpn_gateway = {
        enable     = true
        scale_unit = 1

        bgp_settings = {
          asn = 65002
        }
      }

      # ExpressRoute Gateway for hybrid connectivity
      expressroute_gateway = {
        enable     = true
        scale_unit = 1
      }

      # VNet connections
      vnet_connections = {
        prod-westus = {
          remote_virtual_network_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/prod-westus-rg/providers/Microsoft.Network/virtualNetworks/prod-westus-vnet"
          internet_security_enabled = false
        }
      }
    },

    # Hub in West Europe
    {
      name           = "hub-westeurope"
      location       = "West Europe"
      address_prefix = "10.3.0.0/23"
      sku            = "Standard"

      # VPN Gateway for branch connectivity
      vpn_gateway = {
        enable     = true
        scale_unit = 1

        bgp_settings = {
          asn = 65003
        }
      }

      # VNet connections
      vnet_connections = {
        prod-europe = {
          remote_virtual_network_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/prod-europe-rg/providers/Microsoft.Network/virtualNetworks/prod-europe-vnet"
          internet_security_enabled = false
        }
      }
    }
  ]

  tags = {
    Environment = "production"
    Project     = "global-connectivity"
    CostCenter  = "IT-Network"
    Owner       = "network-team"
  }
}

# Outputs
output "virtual_hub_ids" {
  description = "Virtual Hub IDs"
  value       = module.existing_vwan_hubs.virtual_hub_ids
}

output "vpn_gateway_ids" {
  description = "VPN Gateway IDs"
  value       = module.existing_vwan_hubs.vpn_gateway_ids
}

output "expressroute_gateway_ids" {
  description = "ExpressRoute Gateway IDs"
  value       = module.existing_vwan_hubs.expressroute_gateway_ids
}

output "vnet_connection_ids" {
  description = "VNet Connection IDs"
  value       = module.existing_vwan_hubs.vnet_connection_ids
}

output "virtual_wan_info" {
  description = "Information about the Virtual WAN being used"
  value = {
    id       = module.existing_vwan_hubs.vwan_id
    name     = module.existing_vwan_hubs.vwan_name
    type     = module.existing_vwan_hubs.vwan_type
    location = module.existing_vwan_hubs.vwan_location
  }
}
