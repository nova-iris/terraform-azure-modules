# Azure VWAN Module - Variables
# Input variables for the Azure VWAN module

# General Configuration
variable "name" {
  description = "Name of the Virtual WAN"
  type        = string
}

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

# Virtual WAN Configuration
variable "create_virtual_wan" {
  description = "Whether to create a new Virtual WAN. Set to false if you want to use an existing WAN"
  type        = bool
  default     = true
}

variable "existing_virtual_wan_id" {
  description = "ID of an existing Virtual WAN to use. Required when create_virtual_wan is false. Format: /subscriptions/{subscription-id}/resourceGroups/{rg-name}/providers/Microsoft.Network/virtualWans/{wan-name}"
  type        = string
  default     = ""
}

variable "wan_type" {
  description = "Specifies the Virtual WAN type. Possible Values include: Basic and Standard. Only used when create_virtual_wan is true"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard"], var.wan_type)
    error_message = "Virtual WAN type must be either 'Basic' or 'Standard'."
  }
}

variable "disable_vpn_encryption" {
  description = "Boolean flag to specify whether VPN encryption is disabled. Only used when create_virtual_wan is true"
  type        = bool
  default     = false
}

variable "allow_branch_to_branch_traffic" {
  description = "Boolean flag to specify whether branch to branch traffic is allowed. Only used when create_virtual_wan is true"
  type        = bool
  default     = true
}

variable "office365_local_breakout_category" {
  description = "Specifies the Office365 local breakout category. Possible values include: Optimize, OptimizeAndAllow, All, None. Only used when create_virtual_wan is true"
  type        = string
  default     = "None"

  validation {
    condition     = contains(["Optimize", "OptimizeAndAllow", "All", "None"], var.office365_local_breakout_category)
    error_message = "Office365 local breakout category must be one of: Optimize, OptimizeAndAllow, All, None."
  }
}

# Virtual Hubs Configuration
variable "virtual_hubs" {
  description = "List of virtual hubs to create within the Virtual WAN"
  type = list(object({
    name                                   = string
    location                               = string
    address_prefix                         = optional(string)
    sku                                    = optional(string, "Standard")
    branch_to_branch_traffic_enabled       = optional(bool, false)
    hub_routing_preference                 = optional(string, "ExpressRoute")
    virtual_router_auto_scale_min_capacity = optional(number, 2)

    # Static routes for the virtual hub
    routes = optional(list(object({
      address_prefixes    = list(string)
      next_hop_ip_address = string
    })), [])

    # VNet connections to this hub
    vnet_connections = optional(map(object({
      remote_virtual_network_id = string
      internet_security_enabled = optional(bool, false)

      # Routing configuration
      routing = optional(object({
        associated_route_table_id = optional(string)
        propagated_route_table = optional(object({
          labels          = optional(list(string))
          route_table_ids = optional(list(string))
        }))
        static_vnet_route = optional(list(object({
          name                = string
          address_prefixes    = list(string)
          next_hop_ip_address = string
        })))
      }))
    })), {})

    # VPN Gateway configuration
    vpn_gateway = optional(object({
      enable                                = bool
      routing_preference                    = optional(string, "Microsoft Network")
      scale_unit                            = optional(number, 1)
      bgp_route_translation_for_nat_enabled = optional(bool, false)

      # BGP settings
      bgp_settings = optional(object({
        asn         = number
        peer_weight = optional(number, 0)
        instance_0_bgp_peering_address = optional(object({
          custom_ips = list(string)
        }))
        instance_1_bgp_peering_address = optional(object({
          custom_ips = list(string)
        }))
      }))
    }))

    # ExpressRoute Gateway configuration
    expressroute_gateway = optional(object({
      enable     = bool
      scale_unit = optional(number, 1)
    }))

    # Point-to-Site VPN Gateway configuration
    p2s_vpn_gateway = optional(object({
      enable                      = bool
      scale_unit                  = optional(number, 1)
      vpn_server_configuration_id = string
      connection_configuration = list(object({
        name = string
        vpn_client_address_pool = object({
          address_prefixes = list(string)
        })
        route = optional(object({
          associated_route_table_id = string
          propagated_route_table = optional(object({
            ids    = list(string)
            labels = list(string)
          }))
        }))
        internet_security_enabled = optional(bool, false)
      }))
    }))

    # Azure Firewall configuration
    azure_firewall = optional(object({
      enable             = bool
      sku_name           = optional(string, "AZFW_Hub")
      sku_tier           = optional(string, "Standard")
      public_ip_count    = optional(number, 1)
      firewall_policy_id = optional(string)

      # Firewall management IP configuration
      management_ip_configuration = optional(object({
        name                 = string
        subnet_id            = string
        public_ip_address_id = string
      }))

      # Virtual Hub IP configuration
      virtual_hub_ip_configuration = optional(object({
        name                 = string
        public_ip_address_id = optional(string)
        private_ip_address   = optional(string)
      }))
    }))
  }))
  default = []
}

# Tagging
variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
