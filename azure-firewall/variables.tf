# Azure Firewall Module - Variables
# Input variables for the Azure Firewall module

# General Configuration
variable "naming_convention" {
  description = "Configuration for Azure naming convention module (required for standardized resource naming)"
  type = object({
    prefix        = optional(list(string), [])
    suffix        = optional(list(string), [])
    unique_suffix = optional(string, "")
  })
  default = {}
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "create_resource_group" {
  description = "Whether to create a new resource group"
  type        = bool
  default     = true
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = ""
}

# Azure Firewall Configuration
variable "firewall_sku_name" {
  description = "SKU name of the Azure Firewall"
  type        = string
  default     = "AZFW_VNet"

  validation {
    condition     = contains(["AZFW_VNet", "AZFW_Hub"], var.firewall_sku_name)
    error_message = "Firewall SKU name must be AZFW_VNet or AZFW_Hub."
  }
}

variable "firewall_sku_tier" {
  description = "SKU tier of the Azure Firewall"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.firewall_sku_tier)
    error_message = "Firewall SKU tier must be Basic, Standard, or Premium."
  }
}

variable "firewall_zones" {
  description = "Availability zones for the Azure Firewall"
  type        = list(string)
  default     = []
}

variable "threat_intel_mode" {
  description = "Threat intelligence mode for the Azure Firewall"
  type        = string
  default     = "Alert"

  validation {
    condition     = contains(["Off", "Alert", "Deny"], var.threat_intel_mode)
    error_message = "Threat intelligence mode must be Off, Alert, or Deny."
  }
}

variable "dns_servers" {
  description = "List of DNS servers for the Azure Firewall"
  type        = list(string)
  default     = []
}

variable "firewall_private_ip_ranges" {
  description = "Private IP ranges for the Azure Firewall"
  type        = list(string)
  default     = []
}

# Public IP Configuration
variable "public_ips" {
  description = "Map of public IPs to create for the firewall"
  type = map(object({
    allocation_method = optional(string, "Static")
    sku               = optional(string, "Standard")
    zones             = optional(list(string), [])
    domain_name_label = optional(string)
  }))
  default = {}
}

# IP Configuration
variable "ip_configurations" {
  description = "List of IP configurations for the Azure Firewall"
  type = list(object({
    name                 = string
    subnet_id            = string
    public_ip_name       = optional(string) # Reference to public_ips map
    public_ip_address_id = optional(string) # Direct public IP ID
  }))
  default = []
}

variable "management_ip_configuration" {
  description = "Management IP configuration for forced tunneling"
  type = object({
    name                 = string
    subnet_id            = string
    public_ip_name       = optional(string) # Reference to public_ips map
    public_ip_address_id = optional(string) # Direct public IP ID
  })
  default = null
}

variable "virtual_hub_configuration" {
  description = "Virtual hub configuration for Secure Virtual Hub"
  type = object({
    virtual_hub_id  = string
    public_ip_count = optional(number, 1)
  })
  default = null
}

# Firewall Policy Configuration
variable "create_firewall_policy" {
  description = "Whether to create a new firewall policy"
  type        = bool
  default     = true
}

variable "existing_firewall_policy_id" {
  description = "ID of an existing firewall policy to use"
  type        = string
  default     = null
}

variable "firewall_policy_sku" {
  description = "SKU of the firewall policy"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.firewall_policy_sku)
    error_message = "Firewall policy SKU must be Basic, Standard, or Premium."
  }
}

variable "threat_intelligence_mode" {
  description = "Threat intelligence mode for the firewall policy"
  type        = string
  default     = "Alert"

  validation {
    condition     = contains(["Off", "Alert", "Deny"], var.threat_intelligence_mode)
    error_message = "Threat intelligence mode must be Off, Alert, or Deny."
  }
}

variable "base_policy_id" {
  description = "Base policy ID for the firewall policy"
  type        = string
  default     = null
}

variable "private_ip_ranges" {
  description = "Private IP ranges for the firewall policy"
  type        = list(string)
  default     = []
}

variable "auto_learn_private_ranges_enabled" {
  description = "Enable auto-learning of private ranges"
  type        = bool
  default     = false
}

# DNS Configuration
variable "dns_configuration" {
  description = "DNS configuration for the firewall policy"
  type = object({
    proxy_enabled = optional(bool, false)
    servers       = optional(list(string), [])
  })
  default = null
}

# Threat Intelligence Allowlist
variable "threat_intelligence_allowlist" {
  description = "Threat intelligence allowlist configuration"
  type = object({
    ip_addresses = optional(list(string), [])
    fqdns        = optional(list(string), [])
  })
  default = null
}

# Intrusion Detection
variable "intrusion_detection" {
  description = "Intrusion detection configuration"
  type = object({
    mode           = string
    private_ranges = optional(list(string), [])

    signature_overrides = optional(list(object({
      id    = string
      state = string
    })), [])

    traffic_bypass = optional(list(object({
      name                  = string
      protocol              = string
      description           = optional(string)
      destination_addresses = optional(list(string), [])
      destination_ip_groups = optional(list(string), [])
      destination_ports     = optional(list(string), [])
      source_addresses      = optional(list(string), [])
      source_ip_groups      = optional(list(string), [])
    })), [])
  })
  default = null
}

# TLS Certificate
variable "tls_certificate" {
  description = "TLS certificate configuration"
  type = object({
    key_vault_secret_id = string
    name                = string
  })
  default = null
}

# Firewall Policy Identity
variable "firewall_policy_identity" {
  description = "Identity configuration for firewall policy"
  type = object({
    type         = string
    identity_ids = optional(list(string), [])
  })
  default = null
}

# Rule Collection Groups
variable "rule_collection_groups" {
  description = "Map of rule collection groups to create"
  type = map(object({
    name     = string
    priority = number

    # Application Rule Collections
    application_rule_collections = optional(list(object({
      name     = string
      priority = number
      action   = string

      rules = list(object({
        name                  = string
        description           = optional(string)
        source_addresses      = optional(list(string), [])
        source_ip_groups      = optional(list(string), [])
        destination_addresses = optional(list(string), [])
        destination_urls      = optional(list(string), [])
        destination_fqdns     = optional(list(string), [])
        destination_fqdn_tags = optional(list(string), [])
        terminate_tls         = optional(bool, false)
        web_categories        = optional(list(string), [])

        protocols = list(object({
          type = string
          port = number
        }))

        http_headers = optional(list(object({
          name  = string
          value = string
        })), [])
      }))
    })), [])

    # Network Rule Collections
    network_rule_collections = optional(list(object({
      name     = string
      priority = number
      action   = string

      rules = list(object({
        name                  = string
        description           = optional(string)
        protocols             = list(string)
        source_addresses      = optional(list(string), [])
        source_ip_groups      = optional(list(string), [])
        destination_addresses = optional(list(string), [])
        destination_ip_groups = optional(list(string), [])
        destination_fqdns     = optional(list(string), [])
        destination_ports     = list(string)
      }))
    })), [])

    # NAT Rule Collections
    nat_rule_collections = optional(list(object({
      name     = string
      priority = number
      action   = string

      rules = list(object({
        name                = string
        description         = optional(string)
        protocols           = list(string)
        source_addresses    = optional(list(string), [])
        source_ip_groups    = optional(list(string), [])
        destination_address = string
        destination_ports   = list(string)
        translated_address  = string
        translated_port     = string
      }))
    })), [])
  }))
  default = {}
}

# IP Groups
variable "ip_groups" {
  description = "Map of IP groups to create"
  type = map(object({
    name  = string
    cidrs = list(string)
  }))
  default = {}
}

# Diagnostic Settings
variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings for the firewall"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostic settings"
  type        = string
  default     = null
}

variable "diagnostic_storage_account_id" {
  description = "Storage account ID for diagnostic settings"
  type        = string
  default     = null
}

variable "firewall_logs" {
  description = "List of firewall log categories to enable"
  type        = list(string)
  default = [
    "AzureFirewallApplicationRule",
    "AzureFirewallNetworkRule",
    "AzureFirewallDnsProxy"
  ]
}

variable "firewall_metrics" {
  description = "List of firewall metrics to enable"
  type        = list(string)
  default     = ["AllMetrics"]
}

variable "firewall_policy_logs" {
  description = "List of firewall policy log categories to enable"
  type        = list(string)
  default     = ["AzureFirewallApplicationRule", "AzureFirewallNetworkRule"]
}

# Tagging
variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
