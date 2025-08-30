# Azure VWAN Module - Local Values
# This file contains all local value computations

locals {
  resource_group_name = var.create_resource_group ? azurerm_resource_group.main[0].name : data.azurerm_resource_group.main[0].name

  # Virtual WAN ID - either from created WAN or existing WAN
  virtual_wan_id = var.create_virtual_wan ? azurerm_virtual_wan.main[0].id : var.existing_virtual_wan_id

  # Validation: ensure existing_virtual_wan_id is provided when create_virtual_wan is false
  validate_existing_wan = var.create_virtual_wan ? true : (
    var.existing_virtual_wan_id != "" ? true :
    tobool("ERROR: existing_virtual_wan_id must be provided when create_virtual_wan is false")
  )

  # Generate standardized names using naming module
  vwan_name = var.name != "" ? var.name : module.naming.virtual_wan.name

  # Create virtual hubs map for easier management
  virtual_hubs_map = {
    for hub in var.virtual_hubs : hub.name => hub
  }

  # Flatten hub routes for all virtual hubs
  hub_routes = flatten([
    for hub_name, hub in local.virtual_hubs_map : [
      for route in hub.routes : {
        hub_name = hub_name
        route    = route
      }
    ]
  ])

  # Create hub routes map
  hub_routes_map = {
    for item in local.hub_routes : "${item.hub_name}-${join("-", item.route.address_prefixes)}" => item
  }

  # Flatten VNet connections for all virtual hubs
  vnet_connections = flatten([
    for hub_name, hub in local.virtual_hubs_map : [
      for conn_name, connection in hub.vnet_connections : {
        hub_name        = hub_name
        connection_name = conn_name
        connection      = connection
      }
    ]
  ])

  # Create VNet connections map
  vnet_connections_map = {
    for item in local.vnet_connections : "${item.hub_name}-${item.connection_name}" => item
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
