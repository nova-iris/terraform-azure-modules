# Resource Group Variables
variable "create_resource_group" {
  description = "Whether to create a new resource group or use an existing one."
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "The name of the resource group where the storage account will be created."
  type        = string
}

variable "location" {
  description = "The Azure region where the storage account will be created."
  type        = string
  default     = "West Europe"
}

# Storage Account Basic Configuration
variable "storage_account_name" {
  description = "The name of the storage account. If not provided, a name will be generated using the naming module."
  type        = string
  default     = null
}

variable "account_kind" {
  description = "The kind of storage account. Valid options are 'BlobStorage', 'BlockBlobStorage', 'FileStorage', 'Storage' and 'StorageV2'."
  type        = string
  default     = "StorageV2"
  validation {
    condition     = contains(["BlobStorage", "BlockBlobStorage", "FileStorage", "Storage", "StorageV2"], var.account_kind)
    error_message = "Account kind must be one of: BlobStorage, BlockBlobStorage, FileStorage, Storage, StorageV2."
  }
}

variable "account_tier" {
  description = "The tier to use for this storage account. Valid options are 'Standard' and 'Premium'."
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Account tier must be either 'Standard' or 'Premium'."
  }
}

variable "account_replication_type" {
  description = "The type of replication to use for this storage account. Valid options are 'LRS', 'GRS', 'RAGRS', 'ZRS', 'GZRS' and 'RAGZRS'."
  type        = string
  default     = "LRS"
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "Account replication type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "access_tier" {
  description = "The access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are 'Hot', 'Cool', 'Cold' and 'Premium'."
  type        = string
  default     = "Hot"
  validation {
    condition     = contains(["Hot", "Cool", "Cold", "Premium"], var.access_tier)
    error_message = "Access tier must be one of: Hot, Cool, Cold, Premium."
  }
}

# Security and Access Configuration
variable "https_traffic_only_enabled" {
  description = "Boolean flag which forces HTTPS if enabled."
  type        = bool
  default     = true
}

variable "min_tls_version" {
  description = "The minimum supported TLS version for the storage account."
  type        = string
  default     = "TLS1_2"
  validation {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2"], var.min_tls_version)
    error_message = "Min TLS version must be one of: TLS1_0, TLS1_1, TLS1_2."
  }
}

variable "allow_nested_items_to_be_public" {
  description = "Allow or disallow nested items within this Account to opt into being public."
  type        = bool
  default     = false
}

variable "shared_access_key_enabled" {
  description = "Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key."
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Whether the public network access is enabled."
  type        = bool
  default     = true
}

variable "default_to_oauth_authentication" {
  description = "Default to Azure Active Directory authorization in the Azure portal when accessing the Storage Account."
  type        = bool
  default     = false
}

# Advanced Features
variable "is_hns_enabled" {
  description = "Is Hierarchical Namespace enabled? This can be used with Azure Data Lake Storage Gen 2."
  type        = bool
  default     = false
}

variable "nfsv3_enabled" {
  description = "Is NFSv3 protocol enabled? Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "sftp_enabled" {
  description = "Boolean, enable SFTP for the storage account."
  type        = bool
  default     = false
}

variable "large_file_share_enabled" {
  description = "Are Large File Shares Enabled?"
  type        = bool
  default     = false
}

variable "local_user_enabled" {
  description = "Is Local User Enabled?"
  type        = bool
  default     = true
}

variable "cross_tenant_replication_enabled" {
  description = "Should cross Tenant replication be enabled?"
  type        = bool
  default     = false
}

variable "infrastructure_encryption_enabled" {
  description = "Is infrastructure encryption enabled? Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "queue_encryption_key_type" {
  description = "The encryption type of the queue service. Possible values are 'Service' and 'Account'."
  type        = string
  default     = "Service"
  validation {
    condition     = contains(["Service", "Account"], var.queue_encryption_key_type)
    error_message = "Queue encryption key type must be either 'Service' or 'Account'."
  }
}

variable "table_encryption_key_type" {
  description = "The encryption type of the table service. Possible values are 'Service' and 'Account'."
  type        = string
  default     = "Service"
  validation {
    condition     = contains(["Service", "Account"], var.table_encryption_key_type)
    error_message = "Table encryption key type must be either 'Service' or 'Account'."
  }
}

variable "dns_endpoint_type" {
  description = "Specifies which DNS endpoint type to use. Possible values are 'Standard' and 'AzureDnsZone'."
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "AzureDnsZone"], var.dns_endpoint_type)
    error_message = "DNS endpoint type must be either 'Standard' or 'AzureDnsZone'."
  }
}

variable "allowed_copy_scope" {
  description = "Restrict copy to and from Storage Accounts within an AAD tenant or with Private Links to the same VNet. Possible values are 'AAD' and 'PrivateLink'."
  type        = string
  default     = null
}

# Identity Configuration
variable "identity" {
  description = "Managed Service Identity configuration for the Storage Account."
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = null
}

# Customer Managed Key Configuration
variable "customer_managed_key" {
  description = "Customer managed key configuration for the Storage Account."
  type = object({
    key_vault_key_id          = optional(string)
    managed_hsm_key_id        = optional(string)
    user_assigned_identity_id = string
  })
  default = null
}

# Network Rules Configuration
variable "network_rules" {
  description = "Network rules configuration for the Storage Account."
  type = object({
    default_action             = string
    bypass                     = optional(list(string))
    ip_rules                   = optional(list(string))
    virtual_network_subnet_ids = optional(list(string))
    private_link_access = optional(list(object({
      endpoint_resource_id = string
      endpoint_tenant_id   = optional(string)
    })))
  })
  default = null
}

# Custom Domain Configuration
variable "custom_domain" {
  description = "Custom domain configuration for the Storage Account."
  type = object({
    name          = string
    use_subdomain = optional(bool, false)
  })
  default = null
}

# Static Website Configuration
variable "static_website" {
  description = "Static website configuration for the Storage Account."
  type = object({
    index_document     = optional(string)
    error_404_document = optional(string)
  })
  default = null
}

# Blob Properties Configuration
variable "blob_properties" {
  description = "Blob properties configuration for the Storage Account."
  type = object({
    versioning_enabled            = optional(bool, false)
    change_feed_enabled           = optional(bool, false)
    change_feed_retention_in_days = optional(number)
    default_service_version       = optional(string)
    last_access_time_enabled      = optional(bool, false)

    delete_retention_policy = optional(object({
      days                     = optional(number, 7)
      permanent_delete_enabled = optional(bool, false)
    }))

    restore_policy = optional(object({
      days = number
    }))

    container_delete_retention_policy = optional(object({
      days = optional(number, 7)
    }))

    cors_rule = optional(list(object({
      allowed_headers    = list(string)
      allowed_methods    = list(string)
      allowed_origins    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    })))
  })
  default = null
}

# Queue Properties Configuration
variable "queue_properties" {
  description = "Queue properties configuration for the Storage Account."
  type = object({
    cors_rule = optional(list(object({
      allowed_headers    = list(string)
      allowed_methods    = list(string)
      allowed_origins    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    })))

    logging = optional(object({
      delete                = bool
      read                  = bool
      write                 = bool
      version               = string
      retention_policy_days = optional(number)
    }))

    minute_metrics = optional(object({
      enabled               = bool
      version               = string
      include_apis          = optional(bool)
      retention_policy_days = optional(number)
    }))

    hour_metrics = optional(object({
      enabled               = bool
      version               = string
      include_apis          = optional(bool)
      retention_policy_days = optional(number)
    }))
  })
  default = null
}

# Share Properties Configuration
variable "share_properties" {
  description = "Share properties configuration for the Storage Account."
  type = object({
    cors_rule = optional(list(object({
      allowed_headers    = list(string)
      allowed_methods    = list(string)
      allowed_origins    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    })))

    retention_policy = optional(object({
      days = optional(number, 7)
    }))

    smb = optional(object({
      versions                        = optional(list(string))
      authentication_types            = optional(list(string))
      kerberos_ticket_encryption_type = optional(list(string))
      channel_encryption_type         = optional(list(string))
      multichannel_enabled            = optional(bool, false)
    }))
  })
  default = null
}

# Azure Files Authentication Configuration
variable "azure_files_authentication" {
  description = "Azure Files authentication configuration for the Storage Account."
  type = object({
    directory_type = string

    active_directory = optional(object({
      domain_name         = string
      domain_guid         = string
      domain_sid          = optional(string)
      storage_sid         = optional(string)
      forest_name         = optional(string)
      netbios_domain_name = optional(string)
    }))

    default_share_level_permission = optional(string)
  })
  default = null
}

# Routing Configuration
variable "routing" {
  description = "Routing configuration for the Storage Account."
  type = object({
    publish_internet_endpoints  = optional(bool, false)
    publish_microsoft_endpoints = optional(bool, false)
    choice                      = optional(string, "MicrosoftRouting")
  })
  default = null
}

# SAS Policy Configuration
variable "sas_policy" {
  description = "SAS policy configuration for the Storage Account."
  type = object({
    expiration_period = string
    expiration_action = optional(string, "Log")
  })
  default = null
}

# Immutability Policy Configuration
variable "immutability_policy" {
  description = "Immutability policy configuration for the Storage Account."
  type = object({
    allow_protected_append_writes = bool
    state                         = string
    period_since_creation_in_days = number
  })
  default = null
}

# Containers Configuration
variable "containers" {
  description = "List of containers to create in the storage account."
  type = list(object({
    name                  = string
    container_access_type = optional(string, "private")
    metadata              = optional(map(string), {})
  }))
  default = []
  validation {
    condition = alltrue([
      for container in var.containers :
      contains(["blob", "container", "private"], container.container_access_type)
    ])
    error_message = "Container access type must be one of: blob, container, private."
  }
}

# File Shares Configuration
variable "file_shares" {
  description = "List of file shares to create in the storage account."
  type = list(object({
    name             = string
    quota            = number
    access_tier      = optional(string, "Hot")
    enabled_protocol = optional(string, "SMB")
    metadata         = optional(map(string), {})

    acl = optional(list(object({
      id = string
      access_policy = optional(object({
        permissions = string
        start       = optional(string)
        expiry      = optional(string)
      }))
    })), [])
  }))
  default = []
  validation {
    condition = alltrue([
      for share in var.file_shares :
      contains(["Hot", "Cool", "TransactionOptimized", "Premium"], share.access_tier) &&
      contains(["SMB", "NFS"], share.enabled_protocol) &&
      share.quota >= 1
    ])
    error_message = "File share access tier must be Hot, Cool, TransactionOptimized, or Premium; enabled protocol must be SMB or NFS; quota must be >= 1."
  }
}

# Naming Configuration
variable "naming_convention" {
  description = "Naming convention configuration for the module."
  type = object({
    prefix = optional(string, "")
    suffix = optional(string, "")
  })
  default = {}
}

# Tags
variable "tags" {
  description = "A mapping of tags to assign to all resources."
  type        = map(string)
  default     = {}
}
