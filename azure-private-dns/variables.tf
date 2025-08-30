# Azure Private DNS Module - Variables
# Input variables for the Azure Private DNS module

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

# Private DNS Zone Configuration
variable "private_dns_zone_name" {
  description = "Name of the private DNS zone"
  type        = string
}

# Virtual Network Links
variable "virtual_network_links" {
  description = "Map of virtual network links to create"
  type = map(object({
    virtual_network_id   = string
    registration_enabled = optional(bool, false)
  }))
  default = {}
}

# DNS Records Configuration
variable "a_records" {
  description = "Map of A records to create"
  type = map(object({
    name    = string
    ttl     = optional(number, 300)
    records = list(string)
  }))
  default = {}
}

variable "aaaa_records" {
  description = "Map of AAAA records to create"
  type = map(object({
    name    = string
    ttl     = optional(number, 300)
    records = list(string)
  }))
  default = {}
}

variable "cname_records" {
  description = "Map of CNAME records to create"
  type = map(object({
    name   = string
    ttl    = optional(number, 300)
    record = string
  }))
  default = {}
}

variable "mx_records" {
  description = "Map of MX records to create"
  type = map(object({
    name = string
    ttl  = optional(number, 300)
    records = list(object({
      preference = number
      exchange   = string
    }))
  }))
  default = {}
}

variable "ptr_records" {
  description = "Map of PTR records to create"
  type = map(object({
    name    = string
    ttl     = optional(number, 300)
    records = list(string)
  }))
  default = {}
}

variable "srv_records" {
  description = "Map of SRV records to create"
  type = map(object({
    name = string
    ttl  = optional(number, 300)
    records = list(object({
      priority = number
      weight   = number
      port     = number
      target   = string
    }))
  }))
  default = {}
}

variable "txt_records" {
  description = "Map of TXT records to create"
  type = map(object({
    name    = string
    ttl     = optional(number, 300)
    records = list(string)
  }))
  default = {}
}

# Note: Private Endpoint DNS Zone Groups are not supported in current AzureRM provider version
# These should be configured directly on the private endpoint resource

# DNS Resolver Configuration
variable "enable_dns_resolver" {
  description = "Enable Private DNS Resolver"
  type        = bool
  default     = false
}

variable "dns_resolver_virtual_network_id" {
  description = "Virtual network ID for the DNS resolver"
  type        = string
  default     = ""
}

variable "enable_inbound_endpoint" {
  description = "Enable inbound endpoint for DNS resolver"
  type        = bool
  default     = false
}

variable "inbound_endpoint_ip_configurations" {
  description = "IP configurations for inbound endpoint"
  type = list(object({
    private_ip_allocation_method = optional(string, "Dynamic")
    subnet_id                    = string
    private_ip_address           = optional(string)
  }))
  default = []
}

variable "enable_outbound_endpoint" {
  description = "Enable outbound endpoint for DNS resolver"
  type        = bool
  default     = false
}

variable "outbound_endpoint_subnet_id" {
  description = "Subnet ID for outbound endpoint"
  type        = string
  default     = ""
}

# DNS Forwarding Configuration
variable "dns_forwarding_rulesets" {
  description = "Map of DNS forwarding rulesets to create"
  type = map(object({
    name                  = string
    outbound_endpoint_ids = optional(list(string), [])

    # Forwarding rules for this ruleset
    forwarding_rules = optional(list(object({
      name        = string
      domain_name = string
      enabled     = optional(bool, true)
      metadata    = optional(map(string), {})
      target_dns_servers = list(object({
        ip_address = string
        port       = optional(number, 53)
      }))
    })), [])

    # Virtual network links for this ruleset
    virtual_network_links = optional(list(object({
      name               = string
      virtual_network_id = string
      metadata           = optional(map(string), {})
    })), [])
  }))
  default = {}
}

# Tagging
variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
