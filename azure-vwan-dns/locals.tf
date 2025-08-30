# Azure Virtual WAN DNS Module - Locals
# Local value computations for the DNS VNet and Private DNS configuration

locals {
  # Resource group name selection
  resource_group_name = var.create_resource_group ? azurerm_resource_group.main[0].name : var.resource_group_name

  # Tags merging
  merged_tags = merge(
    var.tags,
    {
      "ManagedBy"   = "Terraform"
      "Module"      = "azure-vwan-dns"
      "CreatedDate" = formatdate("YYYY-MM-DD", timestamp())
    }
  )
}
