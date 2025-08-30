# Advanced Azure Virtual WAN Example
# This example creates a full-featured Virtual WAN with multiple hubs and all gateway types

# Create a sample VNet to connect to the hub
resource "azurerm_resource_group" "spoke" {
  name     = "spoke-vnet-rg"
  location = "East US"
}

resource "azurerm_virtual_network" "spoke" {
  name                = "spoke-vnet"
  address_space       = ["10.100.0.0/16"]
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
}

# Create VPN Server Configuration for P2S
resource "azurerm_vpn_server_configuration" "main" {
  name                     = "example-vpn-server-config"
  resource_group_name      = azurerm_resource_group.spoke.name
  location                 = azurerm_resource_group.spoke.location
  vpn_authentication_types = ["Certificate"]

  client_root_certificate {
    name             = "DigiCert-Federated-ID-Root-CA"
    public_cert_data = file("${path.module}/DigiCert-Federated-ID-Root-CA.crt")
  }
}

# Advanced VWAN with all features
module "advanced_vwan" {
  source = "../.."

  name                              = "enterprise-vwan"
  location                          = "East US"
  resource_group_name               = "enterprise-vwan-rg"
  wan_type                          = "Standard"
  allow_branch_to_branch_traffic    = true
  office365_local_breakout_category = "OptimizeAndAllow"

  # Azure naming convention configuration
  naming_convention = {
    prefix = ["enterprise"]
    suffix = ["global"]
  }

  virtual_hubs = [
    # Primary Hub - East US
    {
      name                                   = "hub-eastus"
      location                               = "East US"
      address_prefix                         = "10.0.0.0/23"
      sku                                    = "Standard"
      hub_routing_preference                 = "ExpressRoute"
      virtual_router_auto_scale_min_capacity = 2

      # VPN Gateway with BGP
      vpn_gateway = {
        enable             = true
        routing_preference = "Microsoft Network"
        scale_unit         = 2

        bgp_settings = {
          asn         = 65001
          peer_weight = 0
          instance_0_bgp_peering_address = {
            custom_ips = ["169.254.21.1"]
          }
          instance_1_bgp_peering_address = {
            custom_ips = ["169.254.21.5"]
          }
        }
      }

      # ExpressRoute Gateway
      expressroute_gateway = {
        enable     = true
        scale_unit = 2
      }

      # Point-to-Site VPN for remote users
      p2s_vpn_gateway = {
        enable                      = true
        scale_unit                  = 1
        vpn_server_configuration_id = azurerm_vpn_server_configuration.main.id

        connection_configuration = [
          {
            name                      = "remote-users"
            internet_security_enabled = true
            vpn_client_address_pool = {
              address_prefixes = ["192.168.100.0/24"]
            }
          }
        ]
      }

      # Static routes
      routes = [
        {
          address_prefixes    = ["172.16.0.0/16"]
          next_hop_ip_address = "10.0.0.4"
        }
      ]

      # VNet connections
      vnet_connections = {
        spoke-vnet = {
          remote_virtual_network_id = azurerm_virtual_network.spoke.id
          internet_security_enabled = false
        }
      }
    },

    # Secondary Hub - West US
    {
      name           = "hub-westus"
      location       = "West US"
      address_prefix = "10.1.0.0/23"
      sku            = "Standard"

      # VPN Gateway for DR
      vpn_gateway = {
        enable     = true
        scale_unit = 1

        bgp_settings = {
          asn = 65002
        }
      }

      # ExpressRoute Gateway
      expressroute_gateway = {
        enable     = true
        scale_unit = 1
      }
    }
  ]

  tags = {
    Environment   = "production"
    Project       = "enterprise-wan"
    CostCenter    = "IT-001"
    Owner         = "network-team"
    SecurityLevel = "high"
  }
}

# Outputs
output "vwan_id" {
  description = "ID of the Virtual WAN"
  value       = module.advanced_vwan.vwan_id
}

output "virtual_hub_ids" {
  description = "Virtual Hub IDs"
  value       = module.advanced_vwan.virtual_hub_ids
}

output "vpn_gateway_ids" {
  description = "VPN Gateway IDs"
  value       = module.advanced_vwan.vpn_gateway_ids
}

output "expressroute_gateway_ids" {
  description = "ExpressRoute Gateway IDs"
  value       = module.advanced_vwan.expressroute_gateway_ids
}

output "p2s_vpn_gateway_ids" {
  description = "Point-to-Site VPN Gateway IDs"
  value       = module.advanced_vwan.p2s_vpn_gateway_ids
}

output "vnet_connection_ids" {
  description = "VNet Connection IDs"
  value       = module.advanced_vwan.vnet_connection_ids
}
