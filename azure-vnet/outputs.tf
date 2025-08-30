# Azure VNet Module - Outputs
# Output values from the Azure VNet module

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

# Virtual Network Outputs
output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = azurerm_virtual_network.main.name
}

output "vnet_address_space" {
  description = "Address space of the Virtual Network"
  value       = azurerm_virtual_network.main.address_space
}

output "vnet_location" {
  description = "Location of the Virtual Network"
  value       = azurerm_virtual_network.main.location
}

output "vnet_guid" {
  description = "GUID of the Virtual Network"
  value       = azurerm_virtual_network.main.guid
}

# Subnet Outputs
output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value = {
    for name, subnet in azurerm_subnet.main : name => subnet.id
  }
}

output "subnet_names" {
  description = "List of subnet names"
  value       = [for subnet in azurerm_subnet.main : subnet.name]
}

output "subnet_address_prefixes" {
  description = "Map of subnet names to their address prefixes"
  value = {
    for name, subnet in azurerm_subnet.main : name => subnet.address_prefixes
  }
}

output "subnets" {
  description = "Map of subnet objects with all attributes"
  value = {
    for name, subnet in azurerm_subnet.main : name => {
      id                = subnet.id
      name              = subnet.name
      address_prefixes  = subnet.address_prefixes
      service_endpoints = subnet.service_endpoints
    }
  }
}

# Network Security Group Outputs
output "nsg_ids" {
  description = "Map of NSG names to their IDs"
  value = {
    for name, nsg in azurerm_network_security_group.subnet : name => nsg.id
  }
}

output "nsg_names" {
  description = "List of NSG names"
  value       = [for nsg in azurerm_network_security_group.subnet : nsg.name]
}

output "nsgs" {
  description = "Map of NSG objects with all attributes"
  value = {
    for name, nsg in azurerm_network_security_group.subnet : name => {
      id       = nsg.id
      name     = nsg.name
      location = nsg.location
    }
  }
}

# Route Table Outputs
output "route_table_ids" {
  description = "Map of route table names to their IDs"
  value = {
    for name, rt in azurerm_route_table.subnet : name => rt.id
  }
}

output "route_table_names" {
  description = "List of route table names"
  value       = [for rt in azurerm_route_table.subnet : rt.name]
}

output "route_tables" {
  description = "Map of route table objects with all attributes"
  value = {
    for name, rt in azurerm_route_table.subnet : name => {
      id       = rt.id
      name     = rt.name
      location = rt.location
    }
  }
}

# DDoS Protection Plan Outputs
output "ddos_protection_plan_id" {
  description = "ID of the DDoS protection plan"
  value       = var.enable_ddos_protection ? azurerm_network_ddos_protection_plan.main[0].id : null
}

output "ddos_protection_plan_name" {
  description = "Name of the DDoS protection plan"
  value       = var.enable_ddos_protection ? azurerm_network_ddos_protection_plan.main[0].name : null
}

# VNet Peering Outputs
output "vnet_peering_ids" {
  description = "Map of VNet peering names to their IDs"
  value = {
    for name, peering in azurerm_virtual_network_peering.main : name => peering.id
  }
}

output "vnet_peering_names" {
  description = "List of VNet peering names"
  value       = [for peering in azurerm_virtual_network_peering.main : peering.name]
}

# Flow Logs Outputs
output "flow_log_ids" {
  description = "Map of flow log names to their IDs"
  value = {
    for name, flow_log in azurerm_network_watcher_flow_log.main : name => flow_log.id
  }
}

output "flow_log_names" {
  description = "List of flow log names"
  value       = [for flow_log in azurerm_network_watcher_flow_log.main : flow_log.name]
}

# Association Outputs
output "subnet_nsg_associations" {
  description = "Map of subnet NSG associations"
  value = {
    for name, assoc in azurerm_subnet_network_security_group_association.main : name => assoc.id
  }
}

output "subnet_route_table_associations" {
  description = "Map of subnet route table associations"
  value = {
    for name, assoc in azurerm_subnet_route_table_association.main : name => assoc.id
  }
}

# Complete module output for reference
output "vnet_module" {
  description = "Complete VNet module output object"
  value = {
    vnet = {
      id            = azurerm_virtual_network.main.id
      name          = azurerm_virtual_network.main.name
      address_space = azurerm_virtual_network.main.address_space
      location      = azurerm_virtual_network.main.location
      guid          = azurerm_virtual_network.main.guid
    }
    subnets = {
      for name, subnet in azurerm_subnet.main : name => {
        id               = subnet.id
        name             = subnet.name
        address_prefixes = subnet.address_prefixes
      }
    }
    nsgs = {
      for name, nsg in azurerm_network_security_group.subnet : name => {
        id   = nsg.id
        name = nsg.name
      }
    }
    route_tables = {
      for name, rt in azurerm_route_table.subnet : name => {
        id   = rt.id
        name = rt.name
      }
    }
  }
}
