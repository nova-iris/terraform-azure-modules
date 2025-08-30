# Naming conventions for standardized resource names
locals {
  # Resource naming using Azure naming module
  naming = module.naming.storage_account

  # Location mapping for short names
  location_short = {
    "West Europe"         = "weu"
    "East US"             = "eus"
    "East US 2"           = "eus2"
    "Central US"          = "cus"
    "North Central US"    = "ncus"
    "South Central US"    = "scus"
    "West US"             = "wus"
    "West US 2"           = "wus2"
    "Canada Central"      = "cac"
    "Canada East"         = "cae"
    "Brazil South"        = "brs"
    "UK South"            = "uks"
    "UK West"             = "ukw"
    "West Central US"     = "wcus"
    "North Europe"        = "neu"
    "Southeast Asia"      = "sea"
    "East Asia"           = "eas"
    "Australia East"      = "aue"
    "Australia Southeast" = "ause"
  }

  # Get the resource group to use
  resource_group_name     = var.create_resource_group ? azurerm_resource_group.main[0].name : data.azurerm_resource_group.main[0].name
  resource_group_location = var.create_resource_group ? azurerm_resource_group.main[0].location : data.azurerm_resource_group.main[0].location

  # Generate unique storage account name based on naming convention
  storage_account_name = var.storage_account_name != null ? var.storage_account_name : lower(replace("${local.naming.name}${local.location_short[local.resource_group_location]}${random_string.storage_suffix.result}", "-", ""))

  # Process containers with defaults
  containers = {
    for container in var.containers : container.name => {
      name                  = container.name
      container_access_type = container.container_access_type != null ? container.container_access_type : "private"
      metadata              = container.metadata != null ? container.metadata : {}
    }
  }

  # Process file shares with defaults
  file_shares = {
    for share in var.file_shares : share.name => {
      name             = share.name
      quota            = share.quota
      access_tier      = share.access_tier != null ? share.access_tier : "Hot"
      enabled_protocol = share.enabled_protocol != null ? share.enabled_protocol : "SMB"
      metadata         = share.metadata != null ? share.metadata : {}
      acl              = share.acl != null ? share.acl : []
    }
  }

  # Process network rules if provided
  network_rules_config = var.network_rules != null ? {
    default_action             = var.network_rules.default_action
    bypass                     = var.network_rules.bypass != null ? var.network_rules.bypass : ["AzureServices"]
    ip_rules                   = var.network_rules.ip_rules != null ? var.network_rules.ip_rules : []
    virtual_network_subnet_ids = var.network_rules.virtual_network_subnet_ids != null ? var.network_rules.virtual_network_subnet_ids : []
    private_link_access        = var.network_rules.private_link_access != null ? var.network_rules.private_link_access : []
  } : null

  # Validate storage account tier and replication combinations
  validate_tier_replication = var.account_tier == "Premium" && contains(["LRS", "ZRS"], var.account_replication_type) ? true : var.account_tier == "Standard" ? true : false

  # Tags to apply to all resources
  common_tags = merge(
    var.tags,
    {
      Module    = "azure-storage"
      CreatedBy = "terraform"
    }
  )
}
