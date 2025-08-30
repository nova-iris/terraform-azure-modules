# Azure Firewall Module - Local Values
# This file contains all local value computations

locals {
  resource_group_name = var.create_resource_group ? azurerm_resource_group.main[0].name : data.azurerm_resource_group.main[0].name

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
