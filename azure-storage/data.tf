# Data source to get Azure naming module for standardized resource naming
data "azurerm_client_config" "current" {}

# Data source for the resource group if not creating it
data "azurerm_resource_group" "main" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

# Data source for subnet IDs used in network rules
data "azurerm_subnet" "network_rules" {
  for_each = toset(var.network_rules != null ? var.network_rules.virtual_network_subnet_ids : [])

  name                 = split("/", each.value)[10]
  virtual_network_name = split("/", each.value)[8]
  resource_group_name  = split("/", each.value)[4]
}
