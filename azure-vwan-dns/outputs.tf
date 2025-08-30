# Azure Virtual WAN DNS Module - Outputs
# Output values for the DNS VNet and Private DNS Resolver configuration

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
  value       = local.dns_resolver_subnet_config
}

# Private DNS Resolver Outputs
output "dns_resolver_id" {
  description = "Resource ID of the Private DNS Resolver"
  value       = module.private_dns.dns_resolver_id
}

output "dns_resolver_name" {
  description = "Name of the Private DNS Resolver"
  value       = module.private_dns.dns_resolver_name
}

output "dns_resolver_inbound_endpoint_id" {
  description = "Resource ID of the DNS resolver inbound endpoint"
  value       = module.private_dns.dns_resolver_inbound_endpoint_id
}

output "dns_resolver_inbound_endpoint_ip" {
  description = "Private IP address of the DNS resolver inbound endpoint"
  value       = module.private_dns.dns_resolver_inbound_endpoint_ip
}

output "dns_resolver_outbound_endpoint_id" {
  description = "Resource ID of the DNS resolver outbound endpoint"
  value       = module.private_dns.dns_resolver_outbound_endpoint_id
}

# Private DNS Zone Outputs
output "primary_dns_zone_id" {
  description = "Resource ID of the primary private DNS zone"
  value       = module.private_dns.private_dns_zone_id
}

output "primary_dns_zone_name" {
  description = "Name of the primary private DNS zone"
  value       = module.private_dns.private_dns_zone_name
}

output "additional_dns_zone_ids" {
  description = "Resource IDs of additional private DNS zones"
  value = {
    for zone_name, zone_module in module.additional_private_dns_zones : zone_name => zone_module.private_dns_zone_id
  }
}

output "additional_dns_zone_names" {
  description = "Names of additional private DNS zones"
  value = {
    for zone_name, zone_module in module.additional_private_dns_zones : zone_name => zone_module.private_dns_zone_name
  }
}

output "all_dns_zones" {
  description = "All DNS zones (primary and additional) with their details"
  value = merge(
    {
      primary = {
        id   = module.private_dns.private_dns_zone_id
        name = module.private_dns.private_dns_zone_name
        type = "primary"
      }
    },
    {
      for zone_name, zone_module in module.additional_private_dns_zones : zone_name => {
        id   = zone_module.private_dns_zone_id
        name = zone_module.private_dns_zone_name
        type = "additional"
      }
    }
  )
}

# DNS Forwarding Outputs
output "dns_forwarding_ruleset_ids" {
  description = "Resource IDs of DNS forwarding rulesets"
  value = {
    for ruleset_name, ruleset in module.private_dns.dns_forwarding_ruleset_ids : ruleset_name => ruleset
  }
}

output "dns_forwarding_rule_ids" {
  description = "Resource IDs of DNS forwarding rules"
  value       = module.private_dns.dns_forwarding_rule_ids
}

# Virtual Network Links Outputs
output "vnet_links" {
  description = "Virtual network links for all DNS zones"
  value = {
    primary = module.private_dns.virtual_network_link_ids
    additional = {
      for zone_name, zone_module in module.additional_private_dns_zones : zone_name => zone_module.virtual_network_link_ids
    }
  }
}

# Hub Connectivity Outputs
output "hub_connectivity_enabled" {
  description = "Whether hub connectivity is enabled"
  value       = local.hub_connectivity.enabled
}

output "dns_to_hub_peering_id" {
  description = "Resource ID of the DNS VNet to hub peering"
  value       = local.hub_connectivity.enabled ? azurerm_virtual_network_peering.dns_to_hub[0].id : null
}

output "hub_to_dns_peering_id" {
  description = "Resource ID of the hub to DNS VNet peering"
  value       = local.hub_connectivity.enabled ? azurerm_virtual_network_peering.hub_to_dns[0].id : null
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
    dns_resolver = {
      id                = module.private_dns.dns_resolver_id
      inbound_endpoint  = module.private_dns.dns_resolver_inbound_endpoint_ip
      outbound_endpoint = module.private_dns.dns_resolver_outbound_endpoint_id
    }
    dns_zones        = local.dns_zones_summary
    hub_connectivity = local.hub_connectivity
    resource_group = {
      name = local.resource_group_name
      id   = var.create_resource_group ? azurerm_resource_group.main[0].id : data.azurerm_resource_group.main[0].id
    }
  }
}

# Configuration for Azure Firewall DNS Proxy
output "firewall_dns_configuration" {
  description = "DNS configuration values for Azure Firewall DNS Proxy setup"
  value = {
    dns_servers       = [module.private_dns.dns_resolver_inbound_endpoint_ip]
    dns_proxy_enabled = true
    dns_vnet_id       = module.dns_vnet.vnet_id
    instructions      = "Configure Azure Firewall with these DNS servers and enable DNS Proxy feature"
  }
}

# Spoke VNet DNS Configuration
output "spoke_vnet_dns_configuration" {
  description = "DNS configuration for spoke VNets in Virtual WAN architecture"
  value = {
    instructions        = "Configure spoke VNets to use Azure Firewall private IP as DNS server"
    dns_resolver_ip     = module.private_dns.dns_resolver_inbound_endpoint_ip
    dns_zones_available = keys(merge({ primary = var.primary_dns_zone }, var.additional_dns_zones))
  }
}
