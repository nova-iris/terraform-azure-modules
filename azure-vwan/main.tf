# Azure VWAN Module - Main Configuration
# Creates a Virtual WAN with virtual hubs, gateways, and associated resources

# Azure Naming Module for standardized naming conventions
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.4.0"
  prefix  = var.naming_convention.prefix
  suffix  = var.naming_convention.suffix
}

# Create resource group if specified
resource "azurerm_resource_group" "main" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Create Virtual WAN (optional)
resource "azurerm_virtual_wan" "main" {
  count = var.create_virtual_wan ? 1 : 0

  name                              = local.vwan_name
  resource_group_name               = local.resource_group_name
  location                          = var.location
  type                              = var.wan_type
  disable_vpn_encryption            = var.disable_vpn_encryption
  allow_branch_to_branch_traffic    = var.allow_branch_to_branch_traffic
  office365_local_breakout_category = var.office365_local_breakout_category

  tags = local.merged_tags
}

# Create Virtual Hubs
resource "azurerm_virtual_hub" "main" {
  for_each = local.virtual_hubs_map

  name                                   = "${each.value.name}-vhub"
  resource_group_name                    = local.resource_group_name
  location                               = each.value.location
  virtual_wan_id                         = local.virtual_wan_id
  address_prefix                         = each.value.address_prefix
  sku                                    = each.value.sku
  hub_routing_preference                 = each.value.hub_routing_preference
  virtual_router_auto_scale_min_capacity = each.value.virtual_router_auto_scale_min_capacity

  # Static routes
  dynamic "route" {
    for_each = each.value.routes
    content {
      address_prefixes    = route.value.address_prefixes
      next_hop_ip_address = route.value.next_hop_ip_address
    }
  }

  tags = local.merged_tags
}

# Create VPN Gateways for Virtual Hubs
resource "azurerm_vpn_gateway" "main" {
  for_each = {
    for hub_name, hub in local.virtual_hubs_map : hub_name => hub
    if hub.vpn_gateway != null && hub.vpn_gateway.enable
  }

  name                = "${module.naming.virtual_network_gateway.name}-${each.key}"
  location            = each.value.location
  resource_group_name = local.resource_group_name
  virtual_hub_id      = azurerm_virtual_hub.main[each.key].id
  routing_preference  = each.value.vpn_gateway.routing_preference
  scale_unit          = each.value.vpn_gateway.scale_unit

  dynamic "bgp_settings" {
    for_each = each.value.vpn_gateway.bgp_settings != null ? [each.value.vpn_gateway.bgp_settings] : []
    content {
      asn         = bgp_settings.value.asn
      peer_weight = bgp_settings.value.peer_weight

      dynamic "instance_0_bgp_peering_address" {
        for_each = bgp_settings.value.instance_0_bgp_peering_address != null ? [bgp_settings.value.instance_0_bgp_peering_address] : []
        content {
          custom_ips = instance_0_bgp_peering_address.value.custom_ips
        }
      }

      dynamic "instance_1_bgp_peering_address" {
        for_each = bgp_settings.value.instance_1_bgp_peering_address != null ? [bgp_settings.value.instance_1_bgp_peering_address] : []
        content {
          custom_ips = instance_1_bgp_peering_address.value.custom_ips
        }
      }
    }
  }

  tags = local.merged_tags
}

# Create ExpressRoute Gateways for Virtual Hubs
resource "azurerm_express_route_gateway" "main" {
  for_each = {
    for hub_name, hub in local.virtual_hubs_map : hub_name => hub
    if hub.expressroute_gateway != null && hub.expressroute_gateway.enable
  }

  name                = "${module.naming.express_route_gateway.name}-${each.key}"
  resource_group_name = local.resource_group_name
  location            = each.value.location
  virtual_hub_id      = azurerm_virtual_hub.main[each.key].id
  scale_units         = each.value.expressroute_gateway.scale_unit

  tags = local.merged_tags
}

# Create Point-to-Site VPN Gateways for Virtual Hubs
resource "azurerm_point_to_site_vpn_gateway" "main" {
  for_each = {
    for hub_name, hub in local.virtual_hubs_map : hub_name => hub
    if hub.p2s_vpn_gateway != null && hub.p2s_vpn_gateway.enable
  }

  name                        = "${each.key}-p2s-vpn-gw"
  location                    = each.value.location
  resource_group_name         = local.resource_group_name
  virtual_hub_id              = azurerm_virtual_hub.main[each.key].id
  vpn_server_configuration_id = each.value.p2s_vpn_gateway.vpn_server_configuration_id
  scale_unit                  = each.value.p2s_vpn_gateway.scale_unit

  dynamic "connection_configuration" {
    for_each = each.value.p2s_vpn_gateway.connection_configuration
    content {
      name                      = connection_configuration.value.name
      internet_security_enabled = connection_configuration.value.internet_security_enabled

      vpn_client_address_pool {
        address_prefixes = connection_configuration.value.vpn_client_address_pool.address_prefixes
      }

      dynamic "route" {
        for_each = connection_configuration.value.route != null ? [connection_configuration.value.route] : []
        content {
          associated_route_table_id = route.value.associated_route_table_id

          dynamic "propagated_route_table" {
            for_each = route.value.propagated_route_table != null ? [route.value.propagated_route_table] : []
            content {
              ids    = propagated_route_table.value.ids
              labels = propagated_route_table.value.labels
            }
          }
        }
      }
    }
  }

  tags = local.merged_tags
}

# Create Azure Firewalls for Virtual Hubs
resource "azurerm_firewall" "main" {
  for_each = {
    for hub_name, hub in local.virtual_hubs_map : hub_name => hub
    if hub.azure_firewall != null && hub.azure_firewall.enable
  }

  name                = "${module.naming.firewall.name}-${each.key}"
  location            = each.value.location
  resource_group_name = local.resource_group_name
  sku_name            = each.value.azure_firewall.sku_name
  sku_tier            = each.value.azure_firewall.sku_tier
  firewall_policy_id  = each.value.azure_firewall.firewall_policy_id

  dynamic "virtual_hub" {
    for_each = each.value.azure_firewall.sku_name == "AZFW_Hub" ? [1] : []
    content {
      virtual_hub_id  = azurerm_virtual_hub.main[each.key].id
      public_ip_count = each.value.azure_firewall.public_ip_count
    }
  }

  dynamic "management_ip_configuration" {
    for_each = each.value.azure_firewall.management_ip_configuration != null ? [each.value.azure_firewall.management_ip_configuration] : []
    content {
      name                 = management_ip_configuration.value.name
      subnet_id            = management_ip_configuration.value.subnet_id
      public_ip_address_id = management_ip_configuration.value.public_ip_address_id
    }
  }

  tags = local.merged_tags
}

# Create Virtual Hub VNet Connections
resource "azurerm_virtual_hub_connection" "main" {
  for_each = local.vnet_connections_map

  name                      = "${each.value.connection_name}-vhub-conn"
  virtual_hub_id            = azurerm_virtual_hub.main[each.value.hub_name].id
  remote_virtual_network_id = each.value.connection.remote_virtual_network_id
  internet_security_enabled = each.value.connection.internet_security_enabled

  dynamic "routing" {
    for_each = each.value.connection.routing != null ? [each.value.connection.routing] : []
    content {
      associated_route_table_id = routing.value.associated_route_table_id

      dynamic "propagated_route_table" {
        for_each = routing.value.propagated_route_table != null ? [routing.value.propagated_route_table] : []
        content {
          labels          = propagated_route_table.value.labels
          route_table_ids = propagated_route_table.value.route_table_ids
        }
      }

      dynamic "static_vnet_route" {
        for_each = routing.value.static_vnet_route != null ? routing.value.static_vnet_route : []
        content {
          name                = static_vnet_route.value.name
          address_prefixes    = static_vnet_route.value.address_prefixes
          next_hop_ip_address = static_vnet_route.value.next_hop_ip_address
        }
      }
    }
  }
}
