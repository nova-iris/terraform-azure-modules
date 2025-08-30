# Azure VM Module - Local Values
# This file contains all local value computations

locals {
  resource_group_name = var.create_resource_group ? azurerm_resource_group.main[0].name : data.azurerm_resource_group.main[0].name

  # Create VMs map for easier management
  vms_map = var.virtual_machines

  # Flatten NSG rules for all VMs
  nsg_rules = flatten([
    for vm_name, vm in local.vms_map : [
      for rule in vm.security_rules : {
        vm_name   = vm_name
        rule_name = rule.name
        rule      = rule
      }
    ] if vm.create_nsg
  ])

  # Create NSG rules map
  nsg_rules_map = {
    for item in local.nsg_rules : "${item.vm_name}-${item.rule_name}" => item
  }

  # Flatten VM extensions for all VMs
  vm_extensions = flatten([
    for vm_name, vm in local.vms_map : [
      for extension in vm.extensions : {
        vm_name        = vm_name
        extension_name = extension.name
        extension      = extension
      }
    ]
  ])

  # Create VM extensions map
  vm_extensions_map = {
    for item in local.vm_extensions : "${item.vm_name}-${item.extension_name}" => item
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
