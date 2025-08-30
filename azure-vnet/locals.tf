# Azure VNet Module - Local Values
# This file contains all local value computations

locals {
  resource_group_name = var.create_resource_group ? azurerm_resource_group.main[0].name : data.azurerm_resource_group.main[0].name

  # Generate standardized names using naming module
  vnet_name = module.naming.virtual_network.name

  # Create subnet map for easier management
  subnets_map = {
    for subnet in var.subnets : subnet.name => subnet
  }

  # Flatten NSG rules for all subnets
  nsg_rules = flatten([
    for subnet_name, subnet in local.subnets_map : [
      for rule in subnet.security_rules : {
        subnet_name = subnet_name
        rule_name   = rule.name
        rule        = rule
      }
    ] if subnet.create_nsg
  ])

  # Create NSG rules map
  nsg_rules_map = {
    for item in local.nsg_rules : "${item.subnet_name}-${item.rule_name}" => item
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
