# Azure Load Balancer Module - Main Configuration
# Creates Azure Load Balancers with frontend IPs, backend pools, rules, and health probes

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

# Create Public IPs for external load balancers
resource "azurerm_public_ip" "main" {
  for_each = {
    for ip_name, ip in var.public_ips : ip_name => ip
  }

  name                = "${module.naming.public_ip.name}-${each.key}"
  location            = var.location
  resource_group_name = local.resource_group_name
  allocation_method   = each.value.allocation_method
  sku                 = each.value.sku
  zones               = each.value.zones
  domain_name_label   = each.value.domain_name_label
  tags                = local.merged_tags
}

# Create Load Balancer
resource "azurerm_lb" "main" {
  name                = module.naming.lb.name
  location            = var.location
  resource_group_name = local.resource_group_name
  sku                 = var.load_balancer_sku
  sku_tier            = var.load_balancer_sku_tier
  tags                = local.merged_tags

  # Frontend IP Configurations
  dynamic "frontend_ip_configuration" {
    for_each = var.frontend_ip_configurations
    content {
      name                          = frontend_ip_configuration.value.name
      public_ip_address_id          = frontend_ip_configuration.value.public_ip_name != null ? azurerm_public_ip.main[frontend_ip_configuration.value.public_ip_name].id : frontend_ip_configuration.value.public_ip_address_id
      subnet_id                     = frontend_ip_configuration.value.subnet_id
      private_ip_address            = frontend_ip_configuration.value.private_ip_address
      private_ip_address_allocation = frontend_ip_configuration.value.private_ip_address_allocation
      private_ip_address_version    = frontend_ip_configuration.value.private_ip_address_version
      zones                         = frontend_ip_configuration.value.zones
    }
  }
}

# Create Backend Address Pools
resource "azurerm_lb_backend_address_pool" "main" {
  for_each = var.backend_address_pools

  name            = each.value.name
  loadbalancer_id = azurerm_lb.main.id
}

# Create Backend Address Pool Addresses
resource "azurerm_lb_backend_address_pool_address" "main" {
  for_each = local.backend_pool_addresses_map

  name                    = each.value.address.name
  backend_address_pool_id = azurerm_lb_backend_address_pool.main[each.value.pool_name].id
  virtual_network_id      = each.value.address.virtual_network_id
  ip_address              = each.value.address.ip_address
}

# Associate Network Interfaces with Backend Pools
resource "azurerm_network_interface_backend_address_pool_association" "main" {
  for_each = local.nic_backend_pool_associations_map

  network_interface_id    = each.value.network_interface_id
  ip_configuration_name   = each.value.ip_configuration_name
  backend_address_pool_id = azurerm_lb_backend_address_pool.main[each.value.backend_pool_name].id
}

# Create Health Probes
resource "azurerm_lb_probe" "main" {
  for_each = var.health_probes

  name                = each.value.name
  loadbalancer_id     = azurerm_lb.main.id
  protocol            = each.value.protocol
  port                = each.value.port
  request_path        = each.value.request_path
  interval_in_seconds = each.value.interval_in_seconds
  number_of_probes    = each.value.number_of_probes
  probe_threshold     = each.value.probe_threshold
}

# Create Load Balancing Rules
resource "azurerm_lb_rule" "main" {
  for_each = var.load_balancing_rules

  name                           = each.value.name
  loadbalancer_id                = azurerm_lb.main.id
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  backend_address_pool_ids       = [for pool_name in each.value.backend_address_pool_names : azurerm_lb_backend_address_pool.main[pool_name].id]
  probe_id                       = each.value.probe_name != null ? azurerm_lb_probe.main[each.value.probe_name].id : null
  enable_floating_ip             = each.value.enable_floating_ip
  idle_timeout_in_minutes        = each.value.idle_timeout_in_minutes
  load_distribution              = each.value.load_distribution
  disable_outbound_snat          = each.value.disable_outbound_snat
  enable_tcp_reset               = each.value.enable_tcp_reset
}

# Create Inbound NAT Rules
resource "azurerm_lb_nat_rule" "main" {
  for_each = var.inbound_nat_rules

  name                           = each.value.name
  resource_group_name            = local.resource_group_name
  loadbalancer_id                = azurerm_lb.main.id
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  enable_floating_ip             = each.value.enable_floating_ip
  idle_timeout_in_minutes        = each.value.idle_timeout_in_minutes
  enable_tcp_reset               = each.value.enable_tcp_reset
}

# Associate Network Interfaces with NAT Rules
resource "azurerm_network_interface_nat_rule_association" "main" {
  for_each = local.nic_nat_rule_associations_map

  network_interface_id  = each.value.network_interface_id
  ip_configuration_name = each.value.ip_configuration_name
  nat_rule_id           = azurerm_lb_nat_rule.main[each.value.nat_rule_name].id
}

# Create Inbound NAT Pools
resource "azurerm_lb_nat_pool" "main" {
  for_each = var.inbound_nat_pools

  name                           = each.value.name
  resource_group_name            = local.resource_group_name
  loadbalancer_id                = azurerm_lb.main.id
  protocol                       = each.value.protocol
  frontend_port_start            = each.value.frontend_port_start
  frontend_port_end              = each.value.frontend_port_end
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  idle_timeout_in_minutes        = each.value.idle_timeout_in_minutes
  floating_ip_enabled            = each.value.floating_ip_enabled
  tcp_reset_enabled              = each.value.tcp_reset_enabled
}

# Create Outbound Rules (for Standard SKU)
resource "azurerm_lb_outbound_rule" "main" {
  for_each = var.outbound_rules

  name                     = each.value.name
  loadbalancer_id          = azurerm_lb.main.id
  protocol                 = each.value.protocol
  backend_address_pool_id  = azurerm_lb_backend_address_pool.main[each.value.backend_address_pool_name].id
  allocated_outbound_ports = each.value.allocated_outbound_ports
  idle_timeout_in_minutes  = each.value.idle_timeout_in_minutes
  enable_tcp_reset         = each.value.enable_tcp_reset

  dynamic "frontend_ip_configuration" {
    for_each = each.value.frontend_ip_configurations
    content {
      name = frontend_ip_configuration.value.name
    }
  }
}
