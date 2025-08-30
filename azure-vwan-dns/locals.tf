# Azure Virtual WAN DNS Module - Locals
# Local value computations for the DNS VNet and Private DNS Resolver configuration

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

  # DNS forwarding rules flattened map for iteration
  dns_forwarding_rules_map = merge([
    for ruleset_name, ruleset in var.dns_forwarding_rulesets : {
      for rule_name, rule in ruleset.forwarding_rules : "${ruleset_name}-${rule_name}" => {
        ruleset_name = ruleset_name
        rule         = rule
      }
    }
  ]...)

  # DNS resolver virtual network links flattened map for iteration
  dns_resolver_vnet_links_map = merge([
    for ruleset_name, ruleset in var.dns_forwarding_rulesets : {
      for link_name, link in ruleset.virtual_network_links : "${ruleset_name}-${link_name}" => {
        ruleset_name = ruleset_name
        link         = link
      }
    }
  ]...)

  # Common subnet configuration for DNS resolver
  dns_resolver_subnet_config = {
    inbound = {
      name      = var.dns_resolver_inbound_subnet_name
      cidr      = var.dns_resolver_inbound_subnet_cidr
      subnet_id = module.dns_vnet.subnet_ids[var.dns_resolver_inbound_subnet_name]
    }
    outbound = {
      name      = var.dns_resolver_outbound_subnet_name
      cidr      = var.dns_resolver_outbound_subnet_cidr
      subnet_id = module.dns_vnet.subnet_ids[var.dns_resolver_outbound_subnet_name]
    }
  }

  # Virtual WAN Hub connectivity configuration
  hub_connectivity = {
    enabled                  = var.hub_virtual_network_id != null
    hub_virtual_network_id   = var.hub_virtual_network_id
    hub_resource_group_name  = var.hub_resource_group_name
    hub_virtual_network_name = var.hub_virtual_network_name
    use_hub_gateway          = var.use_hub_gateway
  }

  # DNS zone configuration summary
  dns_zones_summary = {
    primary = {
      name = var.primary_dns_zone
      type = "primary"
    }
    additional = {
      for zone_name, zone_config in var.additional_dns_zones : zone_name => {
        name = zone_config.name
        type = "additional"
      }
    }
  }
}
