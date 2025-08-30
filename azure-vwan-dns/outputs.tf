# Azure Virtual WAN DNS Module - Outputs
# Output values for the DNS VNet and Private DNS configuration

# Resource Group Outputs
output "resource_group_name" {
  description = "Name of the resource group containing DNS resources"
  value       = local.resource_group_name
}

output "resource_group_id" {
  description = "Resource ID of the resource group containing DNS resources"
  value       = var.create_resource_group ? azurerm_resource_group.main[0].id : data.azurerm_resource_group.main[0].id
}

# DNS VNet Outputs
output "dns_vnet_id" {
  description = "Resource ID of the DNS VNet"
  value       = module.dns_vnet.vnet_id
}

output "dns_vnet_name" {
  description = "Name of the DNS VNet"
  value       = module.dns_vnet.vnet_name
}

output "dns_vnet_address_space" {
  description = "Address space of the DNS VNet"
  value       = module.dns_vnet.vnet_address_space
}

output "dns_vnet_resource_group_name" {
  description = "Resource group name of the DNS VNet"
  value       = module.dns_vnet.resource_group_name
}

# DNS Resolver Subnet Outputs
output "dns_resolver_inbound_subnet_id" {
  description = "Resource ID of the DNS resolver inbound subnet"
  value       = module.dns_vnet.subnet_ids[var.dns_resolver_inbound_subnet_name]
}

output "dns_resolver_outbound_subnet_id" {
  description = "Resource ID of the DNS resolver outbound subnet"
  value       = module.dns_vnet.subnet_ids[var.dns_resolver_outbound_subnet_name]
}

output "dns_resolver_subnet_info" {
  description = "Information about DNS resolver subnets"
  value = {
    inbound = {
      id   = module.dns_vnet.subnet_ids[var.dns_resolver_inbound_subnet_name]
      name = var.dns_resolver_inbound_subnet_name
      cidr = var.dns_resolver_inbound_subnet_cidr
    }
    outbound = {
      id   = module.dns_vnet.subnet_ids[var.dns_resolver_outbound_subnet_name]
      name = var.dns_resolver_outbound_subnet_name
      cidr = var.dns_resolver_outbound_subnet_cidr
    }
  }
}

# Private DNS Zone Outputs
output "primary_dns_zone_id" {
  description = "Resource ID of the primary private DNS zone"
  value       = azurerm_private_dns_zone.primary.id
}

output "primary_dns_zone_name" {
  description = "Name of the primary private DNS zone"
  value       = azurerm_private_dns_zone.primary.name
}

output "additional_dns_zone_ids" {
  description = "Resource IDs of additional private DNS zones"
  value = {
    for zone_name, zone in azurerm_private_dns_zone.additional : zone_name => zone.id
  }
}

output "additional_dns_zone_names" {
  description = "Names of additional private DNS zones"
  value = {
    for zone_name, zone in azurerm_private_dns_zone.additional : zone_name => zone.name
  }
}

output "all_dns_zones" {
  description = "All DNS zones (primary and additional) with their details"
  value = merge(
    {
      primary = {
        id   = azurerm_private_dns_zone.primary.id
        name = azurerm_private_dns_zone.primary.name
        type = "primary"
      }
    },
    {
      for zone_name, zone in azurerm_private_dns_zone.additional : zone_name => {
        id   = zone.id
        name = zone.name
        type = "additional"
      }
    }
  )
}

# Virtual Network Links Outputs
output "vnet_links" {
  description = "Virtual network links for all DNS zones"
  value = {
    primary = {
      primary = azurerm_private_dns_zone_virtual_network_link.primary.id
    }
    additional = {
      for zone_name, link in azurerm_private_dns_zone_virtual_network_link.additional_dns_vnet : zone_name => link.id
    }
  }
}

# Hub Connectivity Outputs
output "hub_connectivity_enabled" {
  description = "Whether hub connectivity is enabled"
  value       = var.hub_virtual_network_id != null
}

output "dns_to_hub_peering_id" {
  description = "Resource ID of the DNS VNet to hub peering"
  value       = var.hub_virtual_network_id != null ? azurerm_virtual_network_peering.dns_to_hub[0].id : null
}

output "hub_to_dns_peering_id" {
  description = "Resource ID of the hub to DNS VNet peering"
  value       = var.hub_virtual_network_id != null ? azurerm_virtual_network_peering.hub_to_dns[0].id : null
}

# Simplified outputs for basic functionality
output "dns_resolver_inbound_endpoint_ip" {
  description = "Note: DNS Resolver endpoints require separate configuration (not included in this simplified module)"
  value       = "DNS Resolver functionality requires additional AzureRM provider support"
}

output "firewall_dns_configuration" {
  description = "DNS configuration values for Azure Firewall DNS Proxy setup"
  value = {
    dns_servers       = ["168.63.129.16"] # Azure DNS default
    dns_proxy_enabled = true
    dns_vnet_id       = module.dns_vnet.vnet_id
    instructions      = "Configure Azure Firewall with DNS Proxy and link to private DNS zones"
    primary_zone      = azurerm_private_dns_zone.primary.name
    additional_zones  = keys(azurerm_private_dns_zone.additional)
  }
}

# Summary Outputs
output "dns_architecture_summary" {
  description = "Summary of the DNS architecture components"
  value = {
    dns_vnet = {
      id            = module.dns_vnet.vnet_id
      name          = module.dns_vnet.vnet_name
      address_space = module.dns_vnet.vnet_address_space
    }
    dns_zones = {
      primary    = azurerm_private_dns_zone.primary.name
      additional = keys(azurerm_private_dns_zone.additional)
    }
    hub_connectivity = var.hub_virtual_network_id != null
    resource_group = {
      name = local.resource_group_name
      id   = var.create_resource_group ? azurerm_resource_group.main[0].id : data.azurerm_resource_group.main[0].id
    }
  }
}
