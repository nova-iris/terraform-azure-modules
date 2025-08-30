# Azure VNet Module - Main Configuration
# Creates a Virtual Network with subnets, NSGs, and associated resources

# Azure Naming Module for standardized naming conventions
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.4.0"
  prefix  = var.naming_convention.prefix
  suffix  = var.naming_convention.suffix
}

# Create resource group if specified
resource "azurerm_resource_group" "main" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Create DDoS Protection Plan if enabled
resource "azurerm_network_ddos_protection_plan" "main" {
  count               = var.enable_ddos_protection ? 1 : 0
  name                = module.naming.network_ddos_protection_plan.name
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = local.merged_tags
}

# Create Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = local.vnet_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = local.resource_group_name
  dns_servers         = var.dns_servers

  # DDoS Protection Plan
  dynamic "ddos_protection_plan" {
    for_each = var.enable_ddos_protection ? [1] : []
    content {
      id     = azurerm_network_ddos_protection_plan.main[0].id
      enable = true
    }
  }

  tags = local.merged_tags
}

# Create Network Security Groups for subnets
resource "azurerm_network_security_group" "subnet" {
  for_each = {
    for subnet_name, subnet in local.subnets_map : subnet_name => subnet
    if subnet.create_nsg
  }

  name                = "${module.naming.network_security_group.name}-${each.key}"
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = local.merged_tags
}

# Create NSG Security Rules
resource "azurerm_network_security_rule" "subnet_rules" {
  for_each = local.nsg_rules_map

  name                         = each.value.rule.name
  priority                     = each.value.rule.priority
  direction                    = each.value.rule.direction
  access                       = each.value.rule.access
  protocol                     = each.value.rule.protocol
  source_port_range            = each.value.rule.source_port_range
  destination_port_range       = each.value.rule.destination_port_range
  source_port_ranges           = each.value.rule.source_port_ranges
  destination_port_ranges      = each.value.rule.destination_port_ranges
  source_address_prefix        = each.value.rule.source_address_prefix
  destination_address_prefix   = each.value.rule.destination_address_prefix
  source_address_prefixes      = each.value.rule.source_address_prefixes
  destination_address_prefixes = each.value.rule.destination_address_prefixes
  resource_group_name          = local.resource_group_name
  network_security_group_name  = azurerm_network_security_group.subnet[each.value.subnet_name].name
}

# Create Route Tables for subnets
resource "azurerm_route_table" "subnet" {
  for_each = {
    for subnet_name, subnet in local.subnets_map : subnet_name => subnet
    if subnet.create_route_table
  }

  name                = "${module.naming.route_table.name}-${each.key}"
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = local.merged_tags
}

# Create custom routes
resource "azurerm_route" "subnet_routes" {
  for_each = {
    for route_key, route in flatten([
      for subnet_name, subnet in local.subnets_map : [
        for route in subnet.routes : {
          key         = "${subnet_name}-${route.name}"
          subnet_name = subnet_name
          route       = route
        }
      ] if subnet.create_route_table
    ]) : route_key => route
  }

  name                   = each.value.route.name
  resource_group_name    = local.resource_group_name
  route_table_name       = azurerm_route_table.subnet[each.value.subnet_name].name
  address_prefix         = each.value.route.address_prefix
  next_hop_type          = each.value.route.next_hop_type
  next_hop_in_ip_address = each.value.route.next_hop_in_ip_address
}

# Create Subnets
resource "azurerm_subnet" "main" {
  for_each = local.subnets_map

  name                 = "${module.naming.subnet.name}-${each.value.name}"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = each.value.service_endpoints

  # Service delegation
  dynamic "delegation" {
    for_each = each.value.delegations
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}

# Associate NSGs with Subnets
resource "azurerm_subnet_network_security_group_association" "main" {
  for_each = {
    for subnet_name, subnet in local.subnets_map : subnet_name => subnet
    if subnet.create_nsg
  }

  subnet_id                 = azurerm_subnet.main[each.key].id
  network_security_group_id = azurerm_network_security_group.subnet[each.key].id
}

# Associate Route Tables with Subnets
resource "azurerm_subnet_route_table_association" "main" {
  for_each = {
    for subnet_name, subnet in local.subnets_map : subnet_name => subnet
    if subnet.create_route_table
  }

  subnet_id      = azurerm_subnet.main[each.key].id
  route_table_id = azurerm_route_table.subnet[each.key].id
}

# VNet Peering (if specified)
resource "azurerm_virtual_network_peering" "main" {
  for_each = var.vnet_peerings

  name                         = "${module.naming.virtual_network_peering.name}-${each.key}"
  resource_group_name          = local.resource_group_name
  virtual_network_name         = azurerm_virtual_network.main.name
  remote_virtual_network_id    = each.value.remote_virtual_network_id
  allow_virtual_network_access = each.value.allow_virtual_network_access
  allow_forwarded_traffic      = each.value.allow_forwarded_traffic
  allow_gateway_transit        = each.value.allow_gateway_transit
  use_remote_gateways          = each.value.use_remote_gateways
}

# Network Watcher Flow Logs (if enabled)
resource "azurerm_network_watcher_flow_log" "main" {
  for_each = var.enable_flow_logs ? local.subnets_map : {}

  name                 = "${local.vnet_name}-${each.key}-flowlog"
  network_watcher_name = var.network_watcher_name
  resource_group_name  = var.network_watcher_resource_group_name

  target_resource_id = azurerm_network_security_group.subnet[each.key].id
  storage_account_id = var.flow_logs_storage_account_id
  enabled            = true
  version            = 2

  retention_policy {
    enabled = var.flow_logs_retention_enabled
    days    = var.flow_logs_retention_days
  }

  dynamic "traffic_analytics" {
    for_each = var.enable_traffic_analytics ? [1] : []
    content {
      enabled               = true
      workspace_id          = var.log_analytics_workspace_id
      workspace_region      = var.location
      workspace_resource_id = var.log_analytics_workspace_resource_id
      interval_in_minutes   = var.traffic_analytics_interval
    }
  }

  tags = local.merged_tags
}
