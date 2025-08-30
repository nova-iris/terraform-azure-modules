# Azure VNet Module - Variables
# Input variables for the Azure VNet module

# General Configuration
variable "name" {
  description = "Name of the Virtual Network"
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

# Virtual Network Configuration
variable "address_space" {
  description = "The address space that is used the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "dns_servers" {
  description = "List of IP addresses of DNS servers"
  type        = list(string)
  default     = []
}

# DDoS Protection
variable "enable_ddos_protection" {
  description = "Enable DDoS protection plan"
  type        = bool
  default     = false
}

# Subnets Configuration
variable "subnets" {
  description = "List of subnets to create"
  type = list(object({
    name                                          = string
    address_prefixes                              = list(string)
    service_endpoints                             = optional(list(string), [])
    private_endpoint_network_policies_enabled     = optional(bool, true)
    private_link_service_network_policies_enabled = optional(bool, true)
    create_nsg                                    = optional(bool, true)
    create_route_table                            = optional(bool, false)
    disable_bgp_route_propagation                 = optional(bool, false)

    # Service delegations
    delegations = optional(list(object({
      name = string
      service_delegation = object({
        name    = string
        actions = list(string)
      })
    })), [])

    # NSG Security Rules
    security_rules = optional(list(object({
      name                         = string
      priority                     = number
      direction                    = string
      access                       = string
      protocol                     = string
      source_port_range            = optional(string)
      destination_port_range       = optional(string)
      source_port_ranges           = optional(list(string))
      destination_port_ranges      = optional(list(string))
      source_address_prefix        = optional(string)
      destination_address_prefix   = optional(string)
      source_address_prefixes      = optional(list(string))
      destination_address_prefixes = optional(list(string))
    })), [])

    # Route Table Routes
    routes = optional(list(object({
      name                   = string
      address_prefix         = string
      next_hop_type          = string
      next_hop_in_ip_address = optional(string)
    })), [])
  }))
  default = []
}

# VNet Peering Configuration
variable "vnet_peerings" {
  description = "Map of VNet peerings to create"
  type = map(object({
    name                         = string
    remote_virtual_network_id    = string
    allow_virtual_network_access = optional(bool, true)
    allow_forwarded_traffic      = optional(bool, false)
    allow_gateway_transit        = optional(bool, false)
    use_remote_gateways          = optional(bool, false)
  }))
  default = {}
}

# Flow Logs Configuration
variable "enable_flow_logs" {
  description = "Enable Network Security Group flow logs"
  type        = bool
  default     = false
}

variable "network_watcher_name" {
  description = "Name of the Network Watcher"
  type        = string
  default     = ""
}

variable "network_watcher_resource_group_name" {
  description = "Resource group name of the Network Watcher"
  type        = string
  default     = ""
}

variable "flow_logs_storage_account_id" {
  description = "Storage account ID for flow logs"
  type        = string
  default     = ""
}

variable "flow_logs_retention_enabled" {
  description = "Enable flow logs retention"
  type        = bool
  default     = true
}

variable "flow_logs_retention_days" {
  description = "Number of days to retain flow logs"
  type        = number
  default     = 30
}

# Traffic Analytics Configuration
variable "enable_traffic_analytics" {
  description = "Enable traffic analytics for flow logs"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for traffic analytics"
  type        = string
  default     = ""
}

variable "log_analytics_workspace_resource_id" {
  description = "Log Analytics workspace resource ID for traffic analytics"
  type        = string
  default     = ""
}

variable "traffic_analytics_interval" {
  description = "Traffic analytics interval in minutes (10 or 60)"
  type        = number
  default     = 60

  validation {
    condition     = contains([10, 60], var.traffic_analytics_interval)
    error_message = "Traffic analytics interval must be either 10 or 60 minutes."
  }
}

# Tagging
variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
