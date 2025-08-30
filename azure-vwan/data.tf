# Azure VWAN Module - Data Sources
# This file contains all data source configurations

# Data source for current client configuration
data "azurerm_client_config" "current" {}

# Data source for resource group (if not creating one)
data "azurerm_resource_group" "main" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

# Data source for existing Virtual WAN (if not creating one)
data "azurerm_virtual_wan" "existing" {
  count = var.create_virtual_wan ? 0 : 1

  # Extract WAN name and resource group from the ID
  name                = split("/", var.existing_virtual_wan_id)[8]
  resource_group_name = split("/", var.existing_virtual_wan_id)[4]
}
