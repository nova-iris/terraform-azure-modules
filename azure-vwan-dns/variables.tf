# Azure Virtual WAN DNS Module - Variables
# Variables for creating dedicated DNS VNet with Private DNS Resolver for Virtual WAN hub-spoke architecture

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where DNS resources will be created"
  type        = string
}

variable "create_resource_group" {
  description = "Whether to create a new resource group for DNS resources"
  type        = bool
  default     = false
}

variable "naming_convention" {
  description = "Naming convention configuration for Azure resources"
  type = object({
    prefix = optional(list(string), [])
    suffix = optional(list(string), [])
  })
  default = {
    prefix = []
    suffix = []
  }
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

# DNS VNet Configuration
variable "dns_vnet_name" {
  description = "Name of the dedicated DNS VNet"
  type        = string
  default     = "vnet-dns"
}

variable "dns_vnet_address_space" {
  description = "Address space for the DNS VNet"
  type        = list(string)
  default     = ["10.100.0.0/24"]
}

variable "dns_resolver_inbound_subnet_name" {
  description = "Name of the inbound DNS resolver subnet"
  type        = string
  default     = "snet-dns-inbound"
}

variable "dns_resolver_inbound_subnet_cidr" {
  description = "CIDR block for the inbound DNS resolver subnet"
  type        = string
  default     = "10.100.0.0/28"
}

variable "dns_resolver_outbound_subnet_name" {
  description = "Name of the outbound DNS resolver subnet"
  type        = string
  default     = "snet-dns-outbound"
}

variable "dns_resolver_outbound_subnet_cidr" {
  description = "CIDR block for the outbound DNS resolver subnet"
  type        = string
  default     = "10.100.0.16/28"
}

# DNS Configuration
variable "primary_dns_zone" {
  description = "Primary private DNS zone name"
  type        = string
  default     = "internal.company.com"
}

variable "additional_dns_zones" {
  description = "Additional private DNS zones to create with their configurations"
  type = map(object({
    name                 = string
    registration_enabled = optional(bool, true)
    spoke_vnet_links = optional(map(object({
      virtual_network_id   = string
      registration_enabled = optional(bool, false)
    })), {})
    a_records = optional(map(object({
      name    = string
      ttl     = optional(number, 300)
      records = list(string)
    })), {})
    aaaa_records = optional(map(object({
      name    = string
      ttl     = optional(number, 300)
      records = list(string)
    })), {})
    cname_records = optional(map(object({
      name   = string
      ttl    = optional(number, 300)
      record = string
    })), {})
    mx_records = optional(map(object({
      name = string
      ttl  = optional(number, 300)
      records = list(object({
        preference = number
        exchange   = string
      }))
    })), {})
    ptr_records = optional(map(object({
      name    = string
      ttl     = optional(number, 300)
      records = list(string)
    })), {})
    srv_records = optional(map(object({
      name = string
      ttl  = optional(number, 300)
      records = list(object({
        priority = number
        weight   = number
        port     = number
        target   = string
      }))
    })), {})
    txt_records = optional(map(object({
      name    = string
      ttl     = optional(number, 300)
      records = list(string)
    })), {})
  }))
  default = {}
}

# DNS Forwarding Configuration
variable "dns_forwarding_rulesets" {
  description = "DNS forwarding rulesets for hybrid connectivity"
  type = map(object({
    name                  = string
    outbound_endpoint_ids = optional(list(string), [])
    virtual_network_links = optional(map(object({
      name               = string
      virtual_network_id = string
      metadata           = optional(map(string), {})
    })), {})
    forwarding_rules = optional(map(object({
      name        = string
      domain_name = string
      enabled     = optional(bool, true)
      metadata    = optional(map(string), {})
      target_dns_servers = list(object({
        ip_address = string
        port       = optional(number, 53)
      }))
    })), {})
  }))
  default = {}
}

# Virtual WAN Hub Connectivity
variable "hub_virtual_network_id" {
  description = "Resource ID of the Virtual WAN Hub VNet for peering (optional)"
  type        = string
  default     = null
}

variable "hub_resource_group_name" {
  description = "Resource group name of the Virtual WAN Hub (required if hub_virtual_network_id is provided)"
  type        = string
  default     = null
}

variable "hub_virtual_network_name" {
  description = "Name of the Virtual WAN Hub VNet (required if hub_virtual_network_id is provided)"
  type        = string
  default     = null
}

variable "use_hub_gateway" {
  description = "Whether to use the hub gateway for connectivity"
  type        = bool
  default     = false
}

# DDoS Protection
variable "enable_ddos_protection" {
  description = "Enable DDoS protection for the DNS VNet"
  type        = bool
  default     = false
}
