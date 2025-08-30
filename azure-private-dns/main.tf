# Azure Private DNS Module - Main Configuration
# Creates Private DNS zones, virtual network links, and DNS records

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

# Create Private DNS Zone
resource "azurerm_private_dns_zone" "main" {
  name                = var.private_dns_zone_name
  resource_group_name = local.resource_group_name
  tags                = local.merged_tags
}

# Create Virtual Network Links
resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  for_each = var.virtual_network_links

  name                  = "${module.naming.private_dns_zone_virtual_network_link.name}-${each.key}"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.main.name
  virtual_network_id    = each.value.virtual_network_id
  registration_enabled  = each.value.registration_enabled
  tags                  = local.merged_tags
}

# Create A Records
resource "azurerm_private_dns_a_record" "main" {
  for_each = var.a_records

  name                = each.value.name
  zone_name           = azurerm_private_dns_zone.main.name
  resource_group_name = local.resource_group_name
  ttl                 = each.value.ttl
  records             = each.value.records
  tags                = local.merged_tags
}

# Create AAAA Records
resource "azurerm_private_dns_aaaa_record" "main" {
  for_each = var.aaaa_records

  name                = each.value.name
  zone_name           = azurerm_private_dns_zone.main.name
  resource_group_name = local.resource_group_name
  ttl                 = each.value.ttl
  records             = each.value.records
  tags                = local.merged_tags
}

# Create CNAME Records
resource "azurerm_private_dns_cname_record" "main" {
  for_each = var.cname_records

  name                = each.value.name
  zone_name           = azurerm_private_dns_zone.main.name
  resource_group_name = local.resource_group_name
  ttl                 = each.value.ttl
  record              = each.value.record
  tags                = local.merged_tags
}

# Create MX Records
resource "azurerm_private_dns_mx_record" "main" {
  for_each = var.mx_records

  name                = each.value.name
  zone_name           = azurerm_private_dns_zone.main.name
  resource_group_name = local.resource_group_name
  ttl                 = each.value.ttl
  tags                = local.merged_tags

  dynamic "record" {
    for_each = each.value.records
    content {
      preference = record.value.preference
      exchange   = record.value.exchange
    }
  }
}

# Create PTR Records
resource "azurerm_private_dns_ptr_record" "main" {
  for_each = var.ptr_records

  name                = each.value.name
  zone_name           = azurerm_private_dns_zone.main.name
  resource_group_name = local.resource_group_name
  ttl                 = each.value.ttl
  records             = each.value.records
  tags                = local.merged_tags
}

# Create SRV Records
resource "azurerm_private_dns_srv_record" "main" {
  for_each = var.srv_records

  name                = each.value.name
  zone_name           = azurerm_private_dns_zone.main.name
  resource_group_name = local.resource_group_name
  ttl                 = each.value.ttl
  tags                = local.merged_tags

  dynamic "record" {
    for_each = each.value.records
    content {
      priority = record.value.priority
      weight   = record.value.weight
      port     = record.value.port
      target   = record.value.target
    }
  }
}

# Create TXT Records
resource "azurerm_private_dns_txt_record" "main" {
  for_each = var.txt_records

  name                = each.value.name
  zone_name           = azurerm_private_dns_zone.main.name
  resource_group_name = local.resource_group_name
  ttl                 = each.value.ttl
  tags                = local.merged_tags

  dynamic "record" {
    for_each = each.value.records
    content {
      value = record.value
    }
  }
}

# Private Endpoint DNS Zone Groups (for Private Link services)
resource "azurerm_private_dns_zone_group" "main" {
  for_each = var.private_endpoint_dns_zone_groups

  name                = each.value.name
  resource_group_name = local.resource_group_name
  private_endpoint_id = each.value.private_endpoint_id

  dynamic "private_dns_zone_config" {
    for_each = each.value.private_dns_zone_configs
    content {
      name                = private_dns_zone_config.value.name
      private_dns_zone_id = private_dns_zone_config.value.private_dns_zone_id != null ? private_dns_zone_config.value.private_dns_zone_id : azurerm_private_dns_zone.main.id
    }
  }
}

# Private DNS Resolver (if enabled)
resource "azurerm_private_dns_resolver" "main" {
  count = var.enable_dns_resolver ? 1 : 0

  name                = module.naming.private_dns_resolver.name
  resource_group_name = local.resource_group_name
  location            = var.location
  virtual_network_id  = var.dns_resolver_virtual_network_id
  tags                = local.merged_tags
}

# DNS Resolver Inbound Endpoint
resource "azurerm_private_dns_resolver_inbound_endpoint" "main" {
  count = var.enable_dns_resolver && var.enable_inbound_endpoint ? 1 : 0

  name                    = module.naming.private_dns_resolver_inbound_endpoint.name
  private_dns_resolver_id = azurerm_private_dns_resolver.main[0].id
  location                = var.location
  tags                    = local.merged_tags

  dynamic "ip_configurations" {
    for_each = var.inbound_endpoint_ip_configurations
    content {
      private_ip_allocation_method = ip_configurations.value.private_ip_allocation_method
      subnet_id                    = ip_configurations.value.subnet_id
      private_ip_address           = ip_configurations.value.private_ip_address
    }
  }
}

# DNS Resolver Outbound Endpoint
resource "azurerm_private_dns_resolver_outbound_endpoint" "main" {
  count = var.enable_dns_resolver && var.enable_outbound_endpoint ? 1 : 0

  name                    = module.naming.private_dns_resolver_outbound_endpoint.name
  private_dns_resolver_id = azurerm_private_dns_resolver.main[0].id
  location                = var.location
  subnet_id               = var.outbound_endpoint_subnet_id
  tags                    = local.merged_tags
}

# DNS Forwarding Rulesets
resource "azurerm_private_dns_resolver_dns_forwarding_ruleset" "main" {
  for_each = var.dns_forwarding_rulesets

  name                                       = each.value.name
  resource_group_name                        = local.resource_group_name
  location                                   = var.location
  private_dns_resolver_outbound_endpoint_ids = var.enable_dns_resolver && var.enable_outbound_endpoint ? [azurerm_private_dns_resolver_outbound_endpoint.main[0].id] : each.value.outbound_endpoint_ids
  tags                                       = local.merged_tags
}

# DNS Forwarding Rules
resource "azurerm_private_dns_resolver_forwarding_rule" "main" {
  for_each = local.dns_forwarding_rules_map

  name                      = each.value.rule.name
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.main[each.value.ruleset_name].id
  domain_name               = each.value.rule.domain_name
  enabled                   = each.value.rule.enabled
  metadata                  = each.value.rule.metadata

  dynamic "target_dns_servers" {
    for_each = each.value.rule.target_dns_servers
    content {
      ip_address = target_dns_servers.value.ip_address
      port       = target_dns_servers.value.port
    }
  }
}

# Virtual Network Links for DNS Forwarding Rulesets
resource "azurerm_private_dns_resolver_virtual_network_link" "main" {
  for_each = local.dns_resolver_vnet_links_map

  name                      = each.value.link.name
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.main[each.value.ruleset_name].id
  virtual_network_id        = each.value.link.virtual_network_id
  metadata                  = each.value.link.metadata
}
