# Azure Virtual WAN DNS Module - Main Configuration
# Creates dedicated DNS VNet with Private DNS Resolver for Virtual WAN hub-spoke architecture

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

# Create dedicated DNS VNet using azure-vnet module
module "dns_vnet" {
  source = "../azure-vnet"

  name                = var.dns_vnet_name
  location            = var.location
  resource_group_name = local.resource_group_name
  address_space       = var.dns_vnet_address_space

  # DNS Resolver subnets
  subnets = [
    {
      name              = var.dns_resolver_inbound_subnet_name
      address_prefixes  = [var.dns_resolver_inbound_subnet_cidr]
      create_nsg        = true
      service_endpoints = []

      # Delegate subnet to Microsoft.Network/dnsResolvers
      delegation = [
        {
          name = "Microsoft.Network.dnsResolvers"
          service_delegation = [
            {
              name    = "Microsoft.Network/dnsResolvers"
              actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
            }
          ]
        }
      ]
    },
    {
      name              = var.dns_resolver_outbound_subnet_name
      address_prefixes  = [var.dns_resolver_outbound_subnet_cidr]
      create_nsg        = true
      service_endpoints = []

      # Delegate subnet to Microsoft.Network/dnsResolvers
      delegation = [
        {
          name = "Microsoft.Network.dnsResolvers"
          service_delegation = [
            {
              name    = "Microsoft.Network/dnsResolvers"
              actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
            }
          ]
        }
      ]
    }
  ]

  # Enable DDoS protection if required
  enable_ddos_protection = var.enable_ddos_protection

  tags = local.merged_tags
}

# Create Primary Private DNS Zone
resource "azurerm_private_dns_zone" "primary" {
  name                = var.primary_dns_zone
  resource_group_name = local.resource_group_name
  tags                = local.merged_tags
}

# Link DNS VNet to primary zone
resource "azurerm_private_dns_zone_virtual_network_link" "primary" {
  name                  = "${var.dns_vnet_name}-to-${replace(var.primary_dns_zone, ".", "-")}"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.primary.name
  virtual_network_id    = module.dns_vnet.vnet_id
  registration_enabled  = true
  tags                  = local.merged_tags
}

# Create additional Private DNS zones if specified
resource "azurerm_private_dns_zone" "additional" {
  for_each = var.additional_dns_zones

  name                = each.value.name
  resource_group_name = local.resource_group_name
  tags                = local.merged_tags
}

# Link additional DNS zones to DNS VNet
resource "azurerm_private_dns_zone_virtual_network_link" "additional_dns_vnet" {
  for_each = var.additional_dns_zones

  name                  = "${var.dns_vnet_name}-to-${replace(each.value.name, ".", "-")}"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.additional[each.key].name
  virtual_network_id    = module.dns_vnet.vnet_id
  registration_enabled  = each.value.registration_enabled
  tags                  = local.merged_tags
}

# Link additional DNS zones to spoke VNets
resource "azurerm_private_dns_zone_virtual_network_link" "additional_spokes" {
  for_each = {
    for link_key, link_config in flatten([
      for zone_key, zone_config in var.additional_dns_zones : [
        for spoke_key, spoke_config in zone_config.spoke_vnet_links : {
          key                  = "${zone_key}-${spoke_key}"
          zone_key             = zone_key
          zone_name            = zone_config.name
          spoke_key            = spoke_key
          virtual_network_id   = spoke_config.virtual_network_id
          registration_enabled = spoke_config.registration_enabled
        }
      ]
    ]) : link_config.key => link_config
  }

  name                  = "${each.value.spoke_key}-to-${replace(each.value.zone_name, ".", "-")}"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.additional[each.value.zone_key].name
  virtual_network_id    = each.value.virtual_network_id
  registration_enabled  = each.value.registration_enabled
  tags                  = local.merged_tags
}

# Create VNet peering connections to Virtual WAN Hub (if hub_virtual_network_id is provided)
resource "azurerm_virtual_network_peering" "dns_to_hub" {
  count = var.hub_virtual_network_id != null ? 1 : 0

  name                      = "${var.dns_vnet_name}-to-hub"
  resource_group_name       = local.resource_group_name
  virtual_network_name      = module.dns_vnet.vnet_name
  remote_virtual_network_id = var.hub_virtual_network_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = var.use_hub_gateway
}

resource "azurerm_virtual_network_peering" "hub_to_dns" {
  count = var.hub_virtual_network_id != null ? 1 : 0

  name                      = "hub-to-${var.dns_vnet_name}"
  resource_group_name       = var.hub_resource_group_name
  virtual_network_name      = var.hub_virtual_network_name
  remote_virtual_network_id = module.dns_vnet.vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = var.use_hub_gateway
  use_remote_gateways          = false
}
