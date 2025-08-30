# Azure Private DNS Module - Data Sources
# This file contains all data source configurations

# Data source for current client configuration
data "azurerm_client_config" "current" {}

# Data source for resource group (if not creating one)
data "azurerm_resource_group" "main" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}
