# Azure Private DNS Module - Local Values
# This file contains all local value computations

locals {
  resource_group_name = var.create_resource_group ? azurerm_resource_group.main[0].name : data.azurerm_resource_group.main[0].name

  # Flatten DNS forwarding rules for all rulesets
  dns_forwarding_rules = flatten([
    for ruleset_name, ruleset in var.dns_forwarding_rulesets : [
      for rule in ruleset.forwarding_rules : {
        ruleset_name = ruleset_name
        rule_name    = rule.name
        rule         = rule
      }
    ]
  ])

  # Create DNS forwarding rules map
  dns_forwarding_rules_map = {
    for item in local.dns_forwarding_rules : "${item.ruleset_name}-${item.rule_name}" => item
  }

  # Flatten DNS resolver virtual network links for all rulesets
  dns_resolver_vnet_links = flatten([
    for ruleset_name, ruleset in var.dns_forwarding_rulesets : [
      for link in ruleset.virtual_network_links : {
        ruleset_name = ruleset_name
        link_name    = link.name
        link         = link
      }
    ]
  ])

  # Create DNS resolver virtual network links map
  dns_resolver_vnet_links_map = {
    for item in local.dns_resolver_vnet_links : "${item.ruleset_name}-${item.link_name}" => item
  }

  # Default tags
  default_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
  }

  # Merge default tags with user-provided tags
  merged_tags = merge(local.default_tags, var.tags)
}
