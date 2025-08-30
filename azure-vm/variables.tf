# Azure VM Module - Variables
# Input variables for the Azure VM module

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

# Virtual Machine Configuration
variable "virtual_machines" {
  description = "Map of virtual machines to create"
  type = map(object({
    # Basic VM Configuration
    vm_size                         = string
    os_type                         = string # "Linux" or "Windows"
    computer_name                   = optional(string)
    admin_username                  = string
    admin_password                  = optional(string)     # For Windows VMs
    disable_password_authentication = optional(bool, true) # For Linux VMs

    # SSH Configuration (Linux)
    generate_ssh_key = optional(bool, false)
    ssh_public_keys  = optional(list(string), [])

    # Windows Configuration
    provision_vm_agent        = optional(bool, true)
    enable_automatic_upgrades = optional(bool, false)
    winrm_listeners = optional(list(object({
      protocol        = string
      certificate_url = optional(string)
    })), [])
    additional_unattend_configs = optional(list(object({
      pass         = string
      component    = string
      setting_name = string
      content      = string
    })), [])

    # Image Configuration
    image_reference = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })

    # Storage Configuration
    os_disk = object({
      caching              = optional(string, "ReadWrite")
      storage_account_type = optional(string, "Premium_LRS")
      disk_size_gb         = optional(number)
    })

    data_disks = optional(list(object({
      lun                  = number
      disk_size_gb         = number
      storage_account_type = optional(string, "Premium_LRS")
      caching              = optional(string, "ReadWrite")
    })), [])

    # Network Configuration
    subnet_id                     = string
    private_ip_address_allocation = optional(string, "Dynamic")
    private_ip_address            = optional(string)
    enable_accelerated_networking = optional(bool, false)
    enable_ip_forwarding          = optional(bool, false)

    # Public IP Configuration
    create_public_ip            = optional(bool, false)
    public_ip_allocation_method = optional(string, "Static")
    public_ip_sku               = optional(string, "Standard")
    public_ip_domain_name_label = optional(string)

    # Security Configuration
    create_nsg = optional(bool, true)
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

    # High Availability
    availability_zones = optional(list(string), [])

    # Boot Diagnostics
    enable_boot_diagnostics              = optional(bool, false)
    boot_diagnostics_storage_account_uri = optional(string)

    # VM Identity
    identity = optional(object({
      type         = optional(string) # "SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"
      identity_ids = optional(list(string), [])
    }), {})

    # VM Extensions
    extensions = optional(list(object({
      name                       = string
      publisher                  = string
      type                       = string
      type_handler_version       = string
      auto_upgrade_minor_version = optional(bool, true)
      settings                   = optional(string)
      protected_settings         = optional(string)
    })), [])

    # Disk Management
    delete_os_disk_on_termination    = optional(bool, true)
    delete_data_disks_on_termination = optional(bool, true)

    # Custom Data
    custom_data = optional(string)
  }))
  default = {}
}

# Availability Set Configuration
variable "create_availability_set" {
  description = "Whether to create an availability set"
  type        = bool
  default     = false
}

variable "availability_set_fault_domain_count" {
  description = "Number of fault domains for the availability set"
  type        = number
  default     = 2

  validation {
    condition     = var.availability_set_fault_domain_count >= 1 && var.availability_set_fault_domain_count <= 3
    error_message = "Fault domain count must be between 1 and 3."
  }
}

variable "availability_set_update_domain_count" {
  description = "Number of update domains for the availability set"
  type        = number
  default     = 5

  validation {
    condition     = var.availability_set_update_domain_count >= 1 && var.availability_set_update_domain_count <= 20
    error_message = "Update domain count must be between 1 and 20."
  }
}

# Key Vault Configuration
variable "create_key_vault" {
  description = "Whether to create a Key Vault for storing VM secrets"
  type        = bool
  default     = false
}

variable "key_vault_sku" {
  description = "SKU for the Key Vault"
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku)
    error_message = "Key Vault SKU must be either 'standard' or 'premium'."
  }
}

variable "key_vault_soft_delete_retention_days" {
  description = "Number of days to retain deleted Key Vault"
  type        = number
  default     = 7

  validation {
    condition     = var.key_vault_soft_delete_retention_days >= 7 && var.key_vault_soft_delete_retention_days <= 90
    error_message = "Soft delete retention days must be between 7 and 90."
  }
}

variable "key_vault_purge_protection_enabled" {
  description = "Enable purge protection for Key Vault"
  type        = bool
  default     = false
}

# Tagging
variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
