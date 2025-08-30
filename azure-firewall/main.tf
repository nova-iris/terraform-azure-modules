# Azure Firewall Module - Main Configuration
# Creates Azure Firewall with policies, rules, and monitoring

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

# Create Public IP for Azure Firewall
resource "azurerm_public_ip" "main" {
  for_each = var.public_ips

  name                = "${module.naming.public_ip.name}-${each.key}"
  location            = var.location
  resource_group_name = local.resource_group_name
  allocation_method   = each.value.allocation_method
  sku                 = each.value.sku
  zones               = each.value.zones
  domain_name_label   = each.value.domain_name_label
  tags                = local.merged_tags
}

# Create Azure Firewall Policy
resource "azurerm_firewall_policy" "main" {
  count = var.create_firewall_policy ? 1 : 0

  name                              = module.naming.firewall_policy.name
  resource_group_name               = local.resource_group_name
  location                          = var.location
  sku                               = var.firewall_policy_sku
  threat_intelligence_mode          = var.threat_intelligence_mode
  base_policy_id                    = var.base_policy_id
  private_ip_ranges                 = var.private_ip_ranges
  auto_learn_private_ranges_enabled = var.auto_learn_private_ranges_enabled
  tags                              = local.merged_tags

  # DNS Configuration
  dynamic "dns" {
    for_each = var.dns_configuration != null ? [var.dns_configuration] : []
    content {
      proxy_enabled = dns.value.proxy_enabled
      servers       = dns.value.servers
    }
  }

  # Threat Intelligence Allowlist
  dynamic "threat_intelligence_allowlist" {
    for_each = var.threat_intelligence_allowlist != null ? [var.threat_intelligence_allowlist] : []
    content {
      ip_addresses = threat_intelligence_allowlist.value.ip_addresses
      fqdns        = threat_intelligence_allowlist.value.fqdns
    }
  }

  # Intrusion Detection
  dynamic "intrusion_detection" {
    for_each = var.intrusion_detection != null ? [var.intrusion_detection] : []
    content {
      mode           = intrusion_detection.value.mode
      private_ranges = intrusion_detection.value.private_ranges

      dynamic "signature_overrides" {
        for_each = intrusion_detection.value.signature_overrides
        content {
          id    = signature_overrides.value.id
          state = signature_overrides.value.state
        }
      }

      dynamic "traffic_bypass" {
        for_each = intrusion_detection.value.traffic_bypass
        content {
          name                  = traffic_bypass.value.name
          protocol              = traffic_bypass.value.protocol
          description           = traffic_bypass.value.description
          destination_addresses = traffic_bypass.value.destination_addresses
          destination_ip_groups = traffic_bypass.value.destination_ip_groups
          destination_ports     = traffic_bypass.value.destination_ports
          source_addresses      = traffic_bypass.value.source_addresses
          source_ip_groups      = traffic_bypass.value.source_ip_groups
        }
      }
    }
  }

  # TLS Certificate
  dynamic "tls_certificate" {
    for_each = var.tls_certificate != null ? [var.tls_certificate] : []
    content {
      key_vault_secret_id = tls_certificate.value.key_vault_secret_id
      name                = tls_certificate.value.name
    }
  }

  # Identity
  dynamic "identity" {
    for_each = var.firewall_policy_identity != null ? [var.firewall_policy_identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }
}

# Create Firewall Policy Rule Collection Groups
resource "azurerm_firewall_policy_rule_collection_group" "main" {
  for_each = var.rule_collection_groups

  name               = each.value.name
  firewall_policy_id = var.create_firewall_policy ? azurerm_firewall_policy.main[0].id : var.existing_firewall_policy_id
  priority           = each.value.priority

  # Application Rule Collections
  dynamic "application_rule_collection" {
    for_each = each.value.application_rule_collections
    content {
      name     = application_rule_collection.value.name
      priority = application_rule_collection.value.priority
      action   = application_rule_collection.value.action

      dynamic "rule" {
        for_each = application_rule_collection.value.rules
        content {
          name                  = rule.value.name
          description           = rule.value.description
          source_addresses      = rule.value.source_addresses
          source_ip_groups      = rule.value.source_ip_groups
          destination_addresses = rule.value.destination_addresses
          destination_urls      = rule.value.destination_urls
          destination_fqdns     = rule.value.destination_fqdns
          destination_fqdn_tags = rule.value.destination_fqdn_tags
          terminate_tls         = rule.value.terminate_tls
          web_categories        = rule.value.web_categories

          dynamic "protocols" {
            for_each = rule.value.protocols
            content {
              type = protocols.value.type
              port = protocols.value.port
            }
          }

          dynamic "http_headers" {
            for_each = rule.value.http_headers
            content {
              name  = http_headers.value.name
              value = http_headers.value.value
            }
          }
        }
      }
    }
  }

  # Network Rule Collections
  dynamic "network_rule_collection" {
    for_each = each.value.network_rule_collections
    content {
      name     = network_rule_collection.value.name
      priority = network_rule_collection.value.priority
      action   = network_rule_collection.value.action

      dynamic "rule" {
        for_each = network_rule_collection.value.rules
        content {
          name                  = rule.value.name
          description           = rule.value.description
          protocols             = rule.value.protocols
          source_addresses      = rule.value.source_addresses
          source_ip_groups      = rule.value.source_ip_groups
          destination_addresses = rule.value.destination_addresses
          destination_ip_groups = rule.value.destination_ip_groups
          destination_fqdns     = rule.value.destination_fqdns
          destination_ports     = rule.value.destination_ports
        }
      }
    }
  }

  # NAT Rule Collections
  dynamic "nat_rule_collection" {
    for_each = each.value.nat_rule_collections
    content {
      name     = nat_rule_collection.value.name
      priority = nat_rule_collection.value.priority
      action   = nat_rule_collection.value.action

      dynamic "rule" {
        for_each = nat_rule_collection.value.rules
        content {
          name                = rule.value.name
          description         = rule.value.description
          protocols           = rule.value.protocols
          source_addresses    = rule.value.source_addresses
          source_ip_groups    = rule.value.source_ip_groups
          destination_address = rule.value.destination_address
          destination_ports   = rule.value.destination_ports
          translated_address  = rule.value.translated_address
          translated_port     = rule.value.translated_port
        }
      }
    }
  }
}

# Create IP Groups
resource "azurerm_ip_group" "main" {
  for_each = var.ip_groups

  name                = each.value.name
  location            = var.location
  resource_group_name = local.resource_group_name
  cidrs               = each.value.cidrs
  tags                = local.merged_tags
}

# Create Azure Firewall
resource "azurerm_firewall" "main" {
  name                = module.naming.firewall.name
  location            = var.location
  resource_group_name = local.resource_group_name
  sku_name            = var.firewall_sku_name
  sku_tier            = var.firewall_sku_tier
  firewall_policy_id  = var.create_firewall_policy ? azurerm_firewall_policy.main[0].id : var.existing_firewall_policy_id
  zones               = var.firewall_zones
  threat_intel_mode   = var.threat_intel_mode
  dns_servers         = var.dns_servers
  private_ip_ranges   = var.firewall_private_ip_ranges
  tags                = local.merged_tags

  # IP Configuration
  dynamic "ip_configuration" {
    for_each = var.ip_configurations
    content {
      name                 = ip_configuration.value.name
      subnet_id            = ip_configuration.value.subnet_id
      public_ip_address_id = ip_configuration.value.public_ip_name != null ? azurerm_public_ip.main[ip_configuration.value.public_ip_name].id : ip_configuration.value.public_ip_address_id
    }
  }

  # Management IP Configuration (for forced tunneling)
  dynamic "management_ip_configuration" {
    for_each = var.management_ip_configuration != null ? [var.management_ip_configuration] : []
    content {
      name                 = management_ip_configuration.value.name
      subnet_id            = management_ip_configuration.value.subnet_id
      public_ip_address_id = management_ip_configuration.value.public_ip_name != null ? azurerm_public_ip.main[management_ip_configuration.value.public_ip_name].id : management_ip_configuration.value.public_ip_address_id
    }
  }

  # Virtual Hub (for Secure Virtual Hub)
  dynamic "virtual_hub" {
    for_each = var.virtual_hub_configuration != null ? [var.virtual_hub_configuration] : []
    content {
      virtual_hub_id  = virtual_hub.value.virtual_hub_id
      public_ip_count = virtual_hub.value.public_ip_count
    }
  }
}

# Create Diagnostic Settings for Firewall
resource "azurerm_monitor_diagnostic_setting" "firewall" {
  count = var.enable_diagnostic_settings ? 1 : 0

  name                       = "${azurerm_firewall.main.name}-diagnostics"
  target_resource_id         = azurerm_firewall.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  storage_account_id         = var.diagnostic_storage_account_id

  dynamic "enabled_log" {
    for_each = var.firewall_logs
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = var.firewall_metrics
    content {
      category = metric.value
      enabled  = true
    }
  }
}

# Create Diagnostic Settings for Firewall Policy
resource "azurerm_monitor_diagnostic_setting" "firewall_policy" {
  count = var.enable_diagnostic_settings && var.create_firewall_policy ? 1 : 0

  name                       = "${azurerm_firewall_policy.main[0].name}-diagnostics"
  target_resource_id         = azurerm_firewall_policy.main[0].id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  storage_account_id         = var.diagnostic_storage_account_id

  dynamic "enabled_log" {
    for_each = var.firewall_policy_logs
    content {
      category = enabled_log.value
    }
  }
}
