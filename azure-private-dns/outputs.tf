# Azure Private DNS Module - Outputs
# Output values from the Azure Private DNS module

# Resource Group Outputs
output "resource_group_name" {
  description = "Name of the resource group"
  value       = local.resource_group_name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = var.create_resource_group ? azurerm_resource_group.main[0].id : data.azurerm_resource_group.main[0].id
}

# Private DNS Zone Outputs
output "private_dns_zone_id" {
  description = "ID of the Private DNS zone"
  value       = azurerm_private_dns_zone.main.id
}

output "private_dns_zone_name" {
  description = "Name of the Private DNS zone"
  value       = azurerm_private_dns_zone.main.name
}

output "private_dns_zone_max_number_of_record_sets" {
  description = "Maximum number of record sets in the Private DNS zone"
  value       = azurerm_private_dns_zone.main.max_number_of_record_sets
}

output "private_dns_zone_max_number_of_virtual_network_links" {
  description = "Maximum number of virtual network links in the Private DNS zone"
  value       = azurerm_private_dns_zone.main.max_number_of_virtual_network_links
}

output "private_dns_zone_max_number_of_virtual_network_links_with_registration" {
  description = "Maximum number of virtual network links with registration in the Private DNS zone"
  value       = azurerm_private_dns_zone.main.max_number_of_virtual_network_links_with_registration
}

output "private_dns_zone_number_of_record_sets" {
  description = "Current number of record sets in the Private DNS zone"
  value       = azurerm_private_dns_zone.main.number_of_record_sets
}

# Virtual Network Links Outputs
output "virtual_network_link_ids" {
  description = "Map of virtual network link names to their IDs"
  value = {
    for name, link in azurerm_private_dns_zone_virtual_network_link.main : name => link.id
  }
}

output "virtual_network_link_names" {
  description = "List of virtual network link names"
  value       = [for link in azurerm_private_dns_zone_virtual_network_link.main : link.name]
}

# DNS Records Outputs
output "a_record_ids" {
  description = "Map of A record names to their IDs"
  value = {
    for name, record in azurerm_private_dns_a_record.main : name => record.id
  }
}

output "aaaa_record_ids" {
  description = "Map of AAAA record names to their IDs"
  value = {
    for name, record in azurerm_private_dns_aaaa_record.main : name => record.id
  }
}

output "cname_record_ids" {
  description = "Map of CNAME record names to their IDs"
  value = {
    for name, record in azurerm_private_dns_cname_record.main : name => record.id
  }
}

output "mx_record_ids" {
  description = "Map of MX record names to their IDs"
  value = {
    for name, record in azurerm_private_dns_mx_record.main : name => record.id
  }
}

output "ptr_record_ids" {
  description = "Map of PTR record names to their IDs"
  value = {
    for name, record in azurerm_private_dns_ptr_record.main : name => record.id
  }
}

output "srv_record_ids" {
  description = "Map of SRV record names to their IDs"
  value = {
    for name, record in azurerm_private_dns_srv_record.main : name => record.id
  }
}

output "txt_record_ids" {
  description = "Map of TXT record names to their IDs"
  value = {
    for name, record in azurerm_private_dns_txt_record.main : name => record.id
  }
}

# Private Endpoint DNS Zone Group Outputs
output "private_endpoint_dns_zone_group_ids" {
  description = "Map of private endpoint DNS zone group names to their IDs"
  value = {
    for name, group in azurerm_private_dns_zone_group.main : name => group.id
  }
}

# DNS Resolver Outputs
output "dns_resolver_id" {
  description = "ID of the Private DNS Resolver"
  value       = var.enable_dns_resolver ? azurerm_private_dns_resolver.main[0].id : null
}

output "dns_resolver_name" {
  description = "Name of the Private DNS Resolver"
  value       = var.enable_dns_resolver ? azurerm_private_dns_resolver.main[0].name : null
}

output "dns_resolver_inbound_endpoint_id" {
  description = "ID of the DNS Resolver inbound endpoint"
  value       = var.enable_dns_resolver && var.enable_inbound_endpoint ? azurerm_private_dns_resolver_inbound_endpoint.main[0].id : null
}

output "dns_resolver_outbound_endpoint_id" {
  description = "ID of the DNS Resolver outbound endpoint"
  value       = var.enable_dns_resolver && var.enable_outbound_endpoint ? azurerm_private_dns_resolver_outbound_endpoint.main[0].id : null
}

# DNS Forwarding Ruleset Outputs
output "dns_forwarding_ruleset_ids" {
  description = "Map of DNS forwarding ruleset names to their IDs"
  value = {
    for name, ruleset in azurerm_private_dns_resolver_dns_forwarding_ruleset.main : name => ruleset.id
  }
}

output "dns_forwarding_rule_ids" {
  description = "Map of DNS forwarding rule names to their IDs"
  value = {
    for name, rule in azurerm_private_dns_resolver_forwarding_rule.main : name => rule.id
  }
}

output "dns_resolver_virtual_network_link_ids" {
  description = "Map of DNS resolver virtual network link names to their IDs"
  value = {
    for name, link in azurerm_private_dns_resolver_virtual_network_link.main : name => link.id
  }
}

# Complete module output for reference
output "private_dns_module" {
  description = "Complete Private DNS module output object"
  value = {
    dns_zone = {
      id   = azurerm_private_dns_zone.main.id
      name = azurerm_private_dns_zone.main.name
    }
    virtual_network_links = {
      for name, link in azurerm_private_dns_zone_virtual_network_link.main : name => {
        id   = link.id
        name = link.name
      }
    }
    dns_resolver = var.enable_dns_resolver ? {
      id                   = azurerm_private_dns_resolver.main[0].id
      name                 = azurerm_private_dns_resolver.main[0].name
      inbound_endpoint_id  = var.enable_inbound_endpoint ? azurerm_private_dns_resolver_inbound_endpoint.main[0].id : null
      outbound_endpoint_id = var.enable_outbound_endpoint ? azurerm_private_dns_resolver_outbound_endpoint.main[0].id : null
    } : null
    forwarding_rulesets = {
      for name, ruleset in azurerm_private_dns_resolver_dns_forwarding_ruleset.main : name => {
        id   = ruleset.id
        name = ruleset.name
      }
    }
  }
}
