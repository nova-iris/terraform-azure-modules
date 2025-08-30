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

# Create Private DNS zones using azure-private-dns module
module "private_dns" {
  source = "../azure-private-dns"

  private_dns_zone_name = var.primary_dns_zone
  location              = var.location
  resource_group_name   = local.resource_group_name
  create_resource_group = false

  # Link DNS VNet to the zone
  virtual_network_links = {
    "dns-vnet" = {
      virtual_network_id   = module.dns_vnet.vnet_id
      registration_enabled = true
    }
  }

  # Enable DNS Resolver
  enable_dns_resolver             = true
  dns_resolver_virtual_network_id = module.dns_vnet.vnet_id

  # Configure inbound endpoint
  enable_inbound_endpoint = true
  inbound_endpoint_ip_configurations = [
    {
      private_ip_allocation_method = "Dynamic"
      subnet_id                    = module.dns_vnet.subnet_ids[var.dns_resolver_inbound_subnet_name]
      private_ip_address           = null
    }
  ]

  # Configure outbound endpoint
  enable_outbound_endpoint    = true
  outbound_endpoint_subnet_id = module.dns_vnet.subnet_ids[var.dns_resolver_outbound_subnet_name]

  # DNS Forwarding Rulesets for hybrid connectivity
  dns_forwarding_rulesets = var.dns_forwarding_rulesets

  tags = local.merged_tags
}

# Create additional Private DNS zones if specified
module "additional_private_dns_zones" {
  source = "../azure-private-dns"

  for_each = var.additional_dns_zones

  private_dns_zone_name = each.value.name
  location              = var.location
  resource_group_name   = local.resource_group_name
  create_resource_group = false

  # Link DNS VNet and spoke VNets to each additional zone
  virtual_network_links = merge(
    {
      "dns-vnet" = {
        virtual_network_id   = module.dns_vnet.vnet_id
        registration_enabled = each.value.registration_enabled
      }
    },
    {
      for spoke_key, spoke_config in each.value.spoke_vnet_links : spoke_key => {
        virtual_network_id   = spoke_config.virtual_network_id
        registration_enabled = spoke_config.registration_enabled
      }
    }
  )

  # Create DNS records if specified
  a_records     = lookup(each.value, "a_records", {})
  aaaa_records  = lookup(each.value, "aaaa_records", {})
  cname_records = lookup(each.value, "cname_records", {})
  mx_records    = lookup(each.value, "mx_records", {})
  ptr_records   = lookup(each.value, "ptr_records", {})
  srv_records   = lookup(each.value, "srv_records", {})
  txt_records   = lookup(each.value, "txt_records", {})

  tags = local.merged_tags
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
