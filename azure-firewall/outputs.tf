# Azure Firewall Module - Outputs
# Output values from the Azure Firewall module

# Resource Group Outputs
output "resource_group_name" {
  description = "Name of the resource group"
  value       = local.resource_group_name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = var.create_resource_group ? azurerm_resource_group.main[0].id : data.azurerm_resource_group.main[0].id
}

# Azure Firewall Outputs
output "firewall_id" {
  description = "ID of the Azure Firewall"
  value       = azurerm_firewall.main.id
}

output "firewall_name" {
  description = "Name of the Azure Firewall"
  value       = azurerm_firewall.main.name
}

output "firewall_ip_configuration" {
  description = "IP configuration of the Azure Firewall"
  value       = azurerm_firewall.main.ip_configuration
}

output "firewall_private_ip_address" {
  description = "Private IP address of the Azure Firewall"
  value       = length(azurerm_firewall.main.ip_configuration) > 0 ? azurerm_firewall.main.ip_configuration[0].private_ip_address : null
}

output "firewall_public_ip_addresses" {
  description = "List of public IP addresses of the Azure Firewall"
  value       = [for config in azurerm_firewall.main.ip_configuration : config.public_ip_address_id]
}

# Firewall Policy Outputs
output "firewall_policy_id" {
  description = "ID of the Firewall Policy"
  value       = var.create_firewall_policy ? azurerm_firewall_policy.main[0].id : var.existing_firewall_policy_id
}

output "firewall_policy_name" {
  description = "Name of the Firewall Policy"
  value       = var.create_firewall_policy ? azurerm_firewall_policy.main[0].name : null
}

output "firewall_policy_child_policies" {
  description = "List of child policies of the Firewall Policy"
  value       = var.create_firewall_policy ? azurerm_firewall_policy.main[0].child_policies : []
}

output "firewall_policy_firewalls" {
  description = "List of firewalls associated with the Firewall Policy"
  value       = var.create_firewall_policy ? azurerm_firewall_policy.main[0].firewalls : []
}

# Public IP Outputs
output "public_ip_ids" {
  description = "Map of public IP names to their IDs"
  value = {
    for name, pip in azurerm_public_ip.main : name => pip.id
  }
}

output "public_ip_addresses" {
  description = "Map of public IP names to their IP addresses"
  value = {
    for name, pip in azurerm_public_ip.main : name => pip.ip_address
  }
}

output "public_ip_fqdns" {
  description = "Map of public IP names to their FQDNs"
  value = {
    for name, pip in azurerm_public_ip.main : name => pip.fqdn
  }
}

# Rule Collection Group Outputs
output "rule_collection_group_ids" {
  description = "Map of rule collection group names to their IDs"
  value = {
    for name, group in azurerm_firewall_policy_rule_collection_group.main : name => group.id
  }
}

output "rule_collection_group_names" {
  description = "List of rule collection group names"
  value       = [for group in azurerm_firewall_policy_rule_collection_group.main : group.name]
}

output "rule_collection_groups" {
  description = "Map of rule collection groups"
  value = {
    for name, group in azurerm_firewall_policy_rule_collection_group.main : name => {
      id                 = group.id
      name               = group.name
      firewall_policy_id = group.firewall_policy_id
      priority           = group.priority
    }
  }
}

# IP Group Outputs
output "ip_group_ids" {
  description = "Map of IP group names to their IDs"
  value = {
    for name, group in azurerm_ip_group.main : name => group.id
  }
}

output "ip_group_names" {
  description = "List of IP group names"
  value       = [for group in azurerm_ip_group.main : group.name]
}

output "ip_groups" {
  description = "Map of IP groups"
  value = {
    for name, group in azurerm_ip_group.main : name => {
      id    = group.id
      name  = group.name
      cidrs = group.cidrs
    }
  }
}

# Diagnostic Settings Outputs
output "firewall_diagnostic_setting_id" {
  description = "ID of the firewall diagnostic setting"
  value       = var.enable_diagnostic_settings ? azurerm_monitor_diagnostic_setting.firewall[0].id : null
}

output "firewall_policy_diagnostic_setting_id" {
  description = "ID of the firewall policy diagnostic setting"
  value       = var.enable_diagnostic_settings && var.create_firewall_policy ? azurerm_monitor_diagnostic_setting.firewall_policy[0].id : null
}

# Complete module output for reference
output "firewall_module" {
  description = "Complete Firewall module output object"
  value = {
    firewall = {
      id                 = azurerm_firewall.main.id
      name               = azurerm_firewall.main.name
      private_ip_address = length(azurerm_firewall.main.ip_configuration) > 0 ? azurerm_firewall.main.ip_configuration[0].private_ip_address : null
      sku_name           = azurerm_firewall.main.sku_name
      sku_tier           = azurerm_firewall.main.sku_tier
    }
    firewall_policy = var.create_firewall_policy ? {
      id                       = azurerm_firewall_policy.main[0].id
      name                     = azurerm_firewall_policy.main[0].name
      sku                      = azurerm_firewall_policy.main[0].sku
      threat_intelligence_mode = azurerm_firewall_policy.main[0].threat_intelligence_mode
    } : null
    public_ips = {
      for name, pip in azurerm_public_ip.main : name => {
        id         = pip.id
        ip_address = pip.ip_address
        fqdn       = pip.fqdn
      }
    }
    ip_groups = {
      for name, group in azurerm_ip_group.main : name => {
        id    = group.id
        name  = group.name
        cidrs = group.cidrs
      }
    }
    rule_collection_groups = {
      for name, group in azurerm_firewall_policy_rule_collection_group.main : name => {
        id       = group.id
        name     = group.name
        priority = group.priority
      }
    }
  }
}
