# Azure VWAN Module - Outputs
# Output values from the Azure VWAN module

# Resource Group Outputs
output "resource_group_name" {
  description = "Name of the resource group"
  value       = local.resource_group_name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = var.create_resource_group ? azurerm_resource_group.main[0].id : data.azurerm_resource_group.main[0].id
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = var.location
}

# Virtual WAN Outputs
output "vwan_id" {
  description = "ID of the Virtual WAN"
  value       = local.virtual_wan_id
}

output "vwan_name" {
  description = "Name of the Virtual WAN"
  value       = var.create_virtual_wan ? azurerm_virtual_wan.main[0].name : data.azurerm_virtual_wan.existing[0].name
}

output "vwan_location" {
  description = "Location of the Virtual WAN"
  value       = var.create_virtual_wan ? azurerm_virtual_wan.main[0].location : data.azurerm_virtual_wan.existing[0].location
}

output "vwan_type" {
  description = "Type of the Virtual WAN"
  value       = var.create_virtual_wan ? var.wan_type : "Unknown"
}

# Virtual Hub Outputs
output "virtual_hub_ids" {
  description = "Map of virtual hub names to their IDs"
  value = {
    for name, hub in azurerm_virtual_hub.main : name => hub.id
  }
}

output "virtual_hub_names" {
  description = "List of virtual hub names"
  value       = [for hub in azurerm_virtual_hub.main : hub.name]
}

output "virtual_hubs" {
  description = "Map of virtual hub objects with all attributes"
  value = {
    for name, hub in azurerm_virtual_hub.main : name => {
      id                                     = hub.id
      name                                   = hub.name
      location                               = hub.location
      address_prefix                         = hub.address_prefix
      sku                                    = hub.sku
      virtual_router_asn                     = hub.virtual_router_asn
      virtual_router_ips                     = hub.virtual_router_ips
      default_route_table_id                 = hub.default_route_table_id
      virtual_router_auto_scale_min_capacity = hub.virtual_router_auto_scale_min_capacity
    }
  }
}

output "virtual_hub_default_route_table_ids" {
  description = "Map of virtual hub names to their default route table IDs"
  value = {
    for name, hub in azurerm_virtual_hub.main : name => hub.default_route_table_id
  }
}

output "virtual_hub_router_asns" {
  description = "Map of virtual hub names to their router ASNs"
  value = {
    for name, hub in azurerm_virtual_hub.main : name => hub.virtual_router_asn
  }
}

output "virtual_hub_router_ips" {
  description = "Map of virtual hub names to their router IPs"
  value = {
    for name, hub in azurerm_virtual_hub.main : name => hub.virtual_router_ips
  }
}

# VPN Gateway Outputs
output "vpn_gateway_ids" {
  description = "Map of VPN gateway names to their IDs"
  value = {
    for name, gateway in azurerm_vpn_gateway.main : name => gateway.id
  }
}

output "vpn_gateway_names" {
  description = "List of VPN gateway names"
  value       = [for gateway in azurerm_vpn_gateway.main : gateway.name]
}

output "vpn_gateways" {
  description = "Map of VPN gateway objects with all attributes"
  value = {
    for name, gateway in azurerm_vpn_gateway.main : name => {
      id                 = gateway.id
      name               = gateway.name
      location           = gateway.location
      virtual_hub_id     = gateway.virtual_hub_id
      routing_preference = gateway.routing_preference
      scale_unit         = gateway.scale_unit
    }
  }
}

# ExpressRoute Gateway Outputs
output "expressroute_gateway_ids" {
  description = "Map of ExpressRoute gateway names to their IDs"
  value = {
    for name, gateway in azurerm_express_route_gateway.main : name => gateway.id
  }
}

output "expressroute_gateway_names" {
  description = "List of ExpressRoute gateway names"
  value       = [for gateway in azurerm_express_route_gateway.main : gateway.name]
}

output "expressroute_gateways" {
  description = "Map of ExpressRoute gateway objects with all attributes"
  value = {
    for name, gateway in azurerm_express_route_gateway.main : name => {
      id             = gateway.id
      name           = gateway.name
      location       = gateway.location
      virtual_hub_id = gateway.virtual_hub_id
      scale_units    = gateway.scale_units
    }
  }
}

# Point-to-Site VPN Gateway Outputs
output "p2s_vpn_gateway_ids" {
  description = "Map of Point-to-Site VPN gateway names to their IDs"
  value = {
    for name, gateway in azurerm_point_to_site_vpn_gateway.main : name => gateway.id
  }
}

output "p2s_vpn_gateway_names" {
  description = "List of Point-to-Site VPN gateway names"
  value       = [for gateway in azurerm_point_to_site_vpn_gateway.main : gateway.name]
}

output "p2s_vpn_gateways" {
  description = "Map of Point-to-Site VPN gateway objects with all attributes"
  value = {
    for name, gateway in azurerm_point_to_site_vpn_gateway.main : name => {
      id                          = gateway.id
      name                        = gateway.name
      location                    = gateway.location
      virtual_hub_id              = gateway.virtual_hub_id
      vpn_server_configuration_id = gateway.vpn_server_configuration_id
      scale_unit                  = gateway.scale_unit
    }
  }
}

# Azure Firewall Outputs
output "firewall_ids" {
  description = "Map of Azure Firewall names to their IDs"
  value = {
    for name, firewall in azurerm_firewall.main : name => firewall.id
  }
}

output "firewall_names" {
  description = "List of Azure Firewall names"
  value       = [for firewall in azurerm_firewall.main : firewall.name]
}

output "firewalls" {
  description = "Map of Azure Firewall objects with all attributes"
  value = {
    for name, firewall in azurerm_firewall.main : name => {
      id                 = firewall.id
      name               = firewall.name
      location           = firewall.location
      sku_name           = firewall.sku_name
      sku_tier           = firewall.sku_tier
      firewall_policy_id = firewall.firewall_policy_id
      virtual_hub        = firewall.virtual_hub
    }
  }
}

# Virtual Hub Connection Outputs
output "vnet_connection_ids" {
  description = "Map of virtual hub connection names to their IDs"
  value = {
    for name, connection in azurerm_virtual_hub_connection.main : name => connection.id
  }
}

output "vnet_connection_names" {
  description = "List of virtual hub connection names"
  value       = [for connection in azurerm_virtual_hub_connection.main : connection.name]
}

output "vnet_connections" {
  description = "Map of virtual hub connection objects with all attributes"
  value = {
    for name, connection in azurerm_virtual_hub_connection.main : name => {
      id                        = connection.id
      name                      = connection.name
      virtual_hub_id            = connection.virtual_hub_id
      remote_virtual_network_id = connection.remote_virtual_network_id
      internet_security_enabled = connection.internet_security_enabled
    }
  }
}

# Complete module output for reference
output "vwan_module" {
  description = "Complete VWAN module output object"
  value = {
    vwan = {
      id       = local.virtual_wan_id
      name     = var.create_virtual_wan ? azurerm_virtual_wan.main[0].name : data.azurerm_virtual_wan.existing[0].name
      location = var.create_virtual_wan ? azurerm_virtual_wan.main[0].location : data.azurerm_virtual_wan.existing[0].location
      type     = var.create_virtual_wan ? var.wan_type : "Unknown"
    }
    virtual_hubs = {
      for name, hub in azurerm_virtual_hub.main : name => {
        id                     = hub.id
        name                   = hub.name
        location               = hub.location
        address_prefix         = hub.address_prefix
        default_route_table_id = hub.default_route_table_id
        virtual_router_asn     = hub.virtual_router_asn
        virtual_router_ips     = hub.virtual_router_ips
      }
    }
    vpn_gateways = {
      for name, gateway in azurerm_vpn_gateway.main : name => {
        id             = gateway.id
        name           = gateway.name
        virtual_hub_id = gateway.virtual_hub_id
      }
    }
    expressroute_gateways = {
      for name, gateway in azurerm_express_route_gateway.main : name => {
        id             = gateway.id
        name           = gateway.name
        virtual_hub_id = gateway.virtual_hub_id
      }
    }
    p2s_vpn_gateways = {
      for name, gateway in azurerm_point_to_site_vpn_gateway.main : name => {
        id             = gateway.id
        name           = gateway.name
        virtual_hub_id = gateway.virtual_hub_id
      }
    }
    firewalls = {
      for name, firewall in azurerm_firewall.main : name => {
        id   = firewall.id
        name = firewall.name
      }
    }
    vnet_connections = {
      for name, connection in azurerm_virtual_hub_connection.main : name => {
        id                        = connection.id
        name                      = connection.name
        virtual_hub_id            = connection.virtual_hub_id
        remote_virtual_network_id = connection.remote_virtual_network_id
      }
    }
  }
}
