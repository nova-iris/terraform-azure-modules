# Azure Load Balancer Module - Variables
# Input variables for the Azure Load Balancer module

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

# Load Balancer Configuration
variable "load_balancer_sku" {
  description = "SKU of the Load Balancer"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Gateway"], var.load_balancer_sku)
    error_message = "Load Balancer SKU must be Basic, Standard, or Gateway."
  }
}

variable "load_balancer_sku_tier" {
  description = "SKU tier of the Load Balancer"
  type        = string
  default     = "Regional"

  validation {
    condition     = contains(["Regional", "Global"], var.load_balancer_sku_tier)
    error_message = "Load Balancer SKU tier must be Regional or Global."
  }
}

# Public IP Configuration
variable "public_ips" {
  description = "Map of public IPs to create for the load balancer"
  type = map(object({
    allocation_method = optional(string, "Static")
    sku               = optional(string, "Standard")
    zones             = optional(list(string), [])
    domain_name_label = optional(string)
  }))
  default = {}
}

# Frontend IP Configuration
variable "frontend_ip_configurations" {
  description = "List of frontend IP configurations"
  type = list(object({
    name                          = string
    public_ip_name                = optional(string) # Reference to public_ips map
    public_ip_address_id          = optional(string) # Direct public IP ID
    subnet_id                     = optional(string) # For internal load balancer
    private_ip_address            = optional(string)
    private_ip_address_allocation = optional(string, "Dynamic")
    private_ip_address_version    = optional(string, "IPv4")
    zones                         = optional(list(string), [])
  }))
  default = []
}

# Backend Address Pool Configuration
variable "backend_address_pools" {
  description = "Map of backend address pools to create"
  type = map(object({
    name = string

    # Addresses to add to the pool
    addresses = optional(list(object({
      name               = string
      virtual_network_id = string
      ip_address         = string
    })), [])

    # Network interface associations
    network_interface_associations = optional(list(object({
      network_interface_id  = string
      ip_configuration_name = optional(string, "internal")
    })), [])
  }))
  default = {}
}

# Health Probe Configuration
variable "health_probes" {
  description = "Map of health probes to create"
  type = map(object({
    name                = string
    protocol            = string # Http, Https, Tcp
    port                = number
    request_path        = optional(string) # Required for Http/Https
    interval_in_seconds = optional(number, 15)
    number_of_probes    = optional(number, 2)
    probe_threshold     = optional(number, 1)
  }))
  default = {}
}

# Load Balancing Rules Configuration
variable "load_balancing_rules" {
  description = "Map of load balancing rules to create"
  type = map(object({
    name                           = string
    protocol                       = string # Tcp, Udp, All
    frontend_port                  = number
    backend_port                   = number
    frontend_ip_configuration_name = string
    backend_address_pool_names     = list(string)     # References to backend_address_pools
    probe_name                     = optional(string) # Reference to health_probes
    enable_floating_ip             = optional(bool, false)
    idle_timeout_in_minutes        = optional(number, 4)
    load_distribution              = optional(string, "Default") # Default, SourceIP, SourceIPProtocol
    disable_outbound_snat          = optional(bool, false)
    enable_tcp_reset               = optional(bool, false)
  }))
  default = {}
}

# Inbound NAT Rules Configuration
variable "inbound_nat_rules" {
  description = "Map of inbound NAT rules to create"
  type = map(object({
    name                           = string
    protocol                       = string # Tcp, Udp, All
    frontend_port                  = number
    backend_port                   = number
    frontend_ip_configuration_name = string
    enable_floating_ip             = optional(bool, false)
    idle_timeout_in_minutes        = optional(number, 4)
    enable_tcp_reset               = optional(bool, false)

    # Network interface associations
    network_interface_associations = optional(list(object({
      network_interface_id  = string
      ip_configuration_name = optional(string, "internal")
    })), [])
  }))
  default = {}
}

# Inbound NAT Pools Configuration
variable "inbound_nat_pools" {
  description = "Map of inbound NAT pools to create"
  type = map(object({
    name                           = string
    protocol                       = string # Tcp, Udp, All
    frontend_port_start            = number
    frontend_port_end              = number
    backend_port                   = number
    frontend_ip_configuration_name = string
    idle_timeout_in_minutes        = optional(number, 4)
    floating_ip_enabled            = optional(bool, false)
    tcp_reset_enabled              = optional(bool, false)
  }))
  default = {}
}

# Outbound Rules Configuration (Standard SKU only)
variable "outbound_rules" {
  description = "Map of outbound rules to create"
  type = map(object({
    name                      = string
    protocol                  = string # Tcp, Udp, All
    backend_address_pool_name = string # Reference to backend_address_pools
    allocated_outbound_ports  = optional(number)
    idle_timeout_in_minutes   = optional(number, 4)
    enable_tcp_reset          = optional(bool, false)

    frontend_ip_configurations = list(object({
      name = string # Reference to frontend_ip_configurations
    }))
  }))
  default = {}
}

# Tagging
variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
