# Azure Load Balancer Module - Local Values
# This file contains all local value computations

locals {
  resource_group_name = var.create_resource_group ? azurerm_resource_group.main[0].name : data.azurerm_resource_group.main[0].name

  # Flatten backend pool addresses
  backend_pool_addresses = flatten([
    for pool_name, pool in var.backend_address_pools : [
      for address in pool.addresses : {
        pool_name = pool_name
        address   = address
      }
    ]
  ])

  # Create backend pool addresses map
  backend_pool_addresses_map = {
    for item in local.backend_pool_addresses : "${item.pool_name}-${item.address.name}" => item
  }

  # Flatten backend pool network interface associations
  nic_backend_pool_associations = flatten([
    for pool_name, pool in var.backend_address_pools : [
      for association in pool.network_interface_associations : {
        backend_pool_name     = pool_name
        network_interface_id  = association.network_interface_id
        ip_configuration_name = association.ip_configuration_name
      }
    ]
  ])

  # Create backend pool network interface associations map
  nic_backend_pool_associations_map = {
    for item in local.nic_backend_pool_associations : "${item.backend_pool_name}-${basename(item.network_interface_id)}" => item
  }

  # Flatten NAT rule network interface associations
  nic_nat_rule_associations = flatten([
    for nat_rule_name, nat_rule in var.inbound_nat_rules : [
      for association in nat_rule.network_interface_associations : {
        nat_rule_name         = nat_rule_name
        network_interface_id  = association.network_interface_id
        ip_configuration_name = association.ip_configuration_name
      }
    ]
  ])

  # Create NAT rule network interface associations map
  nic_nat_rule_associations_map = {
    for item in local.nic_nat_rule_associations : "${item.nat_rule_name}-${basename(item.network_interface_id)}" => item
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
