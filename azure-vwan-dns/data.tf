# Azure Virtual WAN DNS Module - Data Sources
# Data sources for retrieving existing Azure resources

# Get current Azure client configuration
data "azurerm_client_config" "current" {}

# Get existing resource group if not creating a new one
data "azurerm_resource_group" "main" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

# Get hub virtual network information if hub connectivity is enabled
data "azurerm_virtual_network" "hub" {
  count               = var.hub_virtual_network_id != null ? 1 : 0
  name                = var.hub_virtual_network_name
  resource_group_name = var.hub_resource_group_name
}

# Get available DNS forwarding services for the region
# Placeholder for future DNS resolver capabilities
