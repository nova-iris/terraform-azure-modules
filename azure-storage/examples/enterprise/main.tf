terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.42.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

# Data source for current client config
data "azurerm_client_config" "current" {}

# Create resource group
resource "azurerm_resource_group" "enterprise" {
  name     = "rg-storage-enterprise-example"
  location = "West Europe"

  tags = {
    Environment = "Production"
    Example     = "Enterprise"
    Compliance  = "SOC2"
  }
}

# Create virtual network with multiple subnets
resource "azurerm_virtual_network" "enterprise" {
  name                = "vnet-enterprise-storage"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.enterprise.location
  resource_group_name = azurerm_resource_group.enterprise.name

  tags = {
    Environment = "Production"
    Purpose     = "Enterprise-Storage"
  }
}

resource "azurerm_subnet" "storage" {
  name                 = "subnet-storage"
  resource_group_name  = azurerm_resource_group.enterprise.name
  virtual_network_name = azurerm_virtual_network.enterprise.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.KeyVault"]
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "subnet-private-endpoints"
  resource_group_name  = azurerm_resource_group.enterprise.name
  virtual_network_name = azurerm_virtual_network.enterprise.name
  address_prefixes     = ["10.0.2.0/24"]

  private_endpoint_network_policies = "Disabled"
}

# Create Key Vault for customer-managed keys
resource "azurerm_key_vault" "enterprise" {
  name                       = "kv-storage-enterprise-${random_string.kv_suffix.result}"
  location                   = azurerm_resource_group.enterprise.location
  resource_group_name        = azurerm_resource_group.enterprise.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "premium"
  purge_protection_enabled   = true
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create", "Delete", "Get", "List", "Update", "Purge", "Recover"
    ]
  }

  # Access policy for storage account managed identity (will be added after storage creation)
  network_acls {
    default_action = "Allow" # Change to Deny for production
    bypass         = "AzureServices"
  }

  tags = {
    Environment = "Production"
    Purpose     = "Storage-CMK"
  }
}

resource "random_string" "kv_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Create key for customer-managed encryption
resource "azurerm_key_vault_key" "storage_key" {
  name         = "storage-encryption-key"
  key_vault_id = azurerm_key_vault.enterprise.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"
  ]

  depends_on = [azurerm_key_vault.enterprise]
}

# Create User Assigned Managed Identity for CMK
resource "azurerm_user_assigned_identity" "storage_cmk" {
  name                = "id-storage-cmk"
  location            = azurerm_resource_group.enterprise.location
  resource_group_name = azurerm_resource_group.enterprise.name
}

# Grant access to Key Vault for the managed identity
resource "azurerm_key_vault_access_policy" "storage_cmk" {
  key_vault_id = azurerm_key_vault.enterprise.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.storage_cmk.principal_id

  key_permissions = [
    "Get", "UnwrapKey", "WrapKey"
  ]

  depends_on = [azurerm_user_assigned_identity.storage_cmk]
}

# Enterprise Storage Account with maximum security
module "enterprise_storage" {
  source = "../../"

  # Use existing resource group
  create_resource_group = false
  resource_group_name   = azurerm_resource_group.enterprise.name

  # Storage Account Configuration
  storage_account_name     = null # Auto-generated
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "GZRS" # Geo-zone-redundant for maximum availability
  access_tier              = "Hot"

  # Maximum Security Configuration
  https_traffic_only_enabled        = true
  min_tls_version                   = "TLS1_2"
  allow_nested_items_to_be_public   = false
  public_network_access_enabled     = false # Private access only
  infrastructure_encryption_enabled = true
  shared_access_key_enabled         = false # Use Azure AD only
  default_to_oauth_authentication   = true

  # Advanced Features for Enterprise
  is_hns_enabled                   = true # Data Lake Gen2
  sftp_enabled                     = true # SFTP access
  large_file_share_enabled         = true
  cross_tenant_replication_enabled = false # Security requirement
  queue_encryption_key_type        = "Account"
  table_encryption_key_type        = "Account"

  # Managed Identity Configuration (System + User Assigned for CMK)
  identity = {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.storage_cmk.id]
  }

  # Customer Managed Key for encryption
  customer_managed_key = {
    key_vault_key_id          = azurerm_key_vault_key.storage_key.id
    user_assigned_identity_id = azurerm_user_assigned_identity.storage_cmk.id
  }

  # Restrictive Network Rules
  network_rules = {
    default_action             = "Deny"
    bypass                     = ["AzureServices", "Metrics", "Logging"]
    ip_rules                   = [] # No public IP access
    virtual_network_subnet_ids = [azurerm_subnet.storage.id]

    private_link_access = [
      {
        endpoint_resource_id = azurerm_virtual_network.enterprise.id
        endpoint_tenant_id   = data.azurerm_client_config.current.tenant_id
      }
    ]
  }

  # Advanced Blob Properties for Compliance
  blob_properties = {
    versioning_enabled            = true
    change_feed_enabled           = true
    change_feed_retention_in_days = 365 # 1 year retention
    last_access_time_enabled      = true

    delete_retention_policy = {
      days                     = 90 # 90 days retention
      permanent_delete_enabled = false
    }

    restore_policy = {
      days = 30 # Point-in-time restore for 30 days
    }

    container_delete_retention_policy = {
      days = 30
    }

    # CORS for approved origins only
    cors_rule = [
      {
        allowed_headers    = ["x-ms-blob-content-type", "x-ms-blob-content-disposition"]
        allowed_methods    = ["GET", "POST", "PUT"]
        allowed_origins    = ["https://enterprise.example.com"]
        exposed_headers    = ["x-ms-request-id"]
        max_age_in_seconds = 1800
      }
    ]
  }

  # Queue Properties with Full Logging
  queue_properties = {
    logging = {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 365
    }

    minute_metrics = {
      enabled               = true
      version               = "1.0"
      include_apis          = true
      retention_policy_days = 365
    }

    hour_metrics = {
      enabled               = true
      version               = "1.0"
      include_apis          = true
      retention_policy_days = 365
    }
  }

  # Share Properties with Enhanced Security
  share_properties = {
    retention_policy = {
      days = 365
    }

    smb = {
      versions                        = ["SMB3.1.1"] # Most secure version only
      authentication_types            = ["Kerberos"] # Kerberos only
      kerberos_ticket_encryption_type = ["AES-256"]
      channel_encryption_type         = ["AES-256-GCM"]
      multichannel_enabled            = false
    }
  }

  # Immutability Policy for Compliance
  immutability_policy = {
    allow_protected_append_writes = false
    state                         = "Unlocked" # Can be locked for compliance
    period_since_creation_in_days = 2555       # 7 years
  }

  # SAS Policy with Short Expiration
  sas_policy = {
    expiration_period = "1.00:00:00" # 1 day maximum
    expiration_action = "Log"
  }

  # Enterprise Containers with Metadata
  containers = [
    {
      name                  = "financial-records"
      container_access_type = "private"
      metadata = {
        classification = "confidential"
        department     = "finance"
        retention      = "7-years"
        compliance     = "sox"
      }
    },
    {
      name                  = "customer-data"
      container_access_type = "private"
      metadata = {
        classification = "personal-data"
        department     = "customer-service"
        compliance     = "gdpr"
        encryption     = "customer-managed"
      }
    },
    {
      name                  = "audit-logs"
      container_access_type = "private"
      metadata = {
        purpose   = "audit-trail"
        retention = "10-years"
        immutable = "true"
      }
    },
    {
      name                  = "data-lake-bronze"
      container_access_type = "private"
      metadata = {
        tier      = "bronze"
        purpose   = "raw-data-ingestion"
        analytics = "enabled"
      }
    },
    {
      name                  = "data-lake-silver"
      container_access_type = "private"
      metadata = {
        tier      = "silver"
        purpose   = "processed-data"
        analytics = "enabled"
      }
    },
    {
      name                  = "data-lake-gold"
      container_access_type = "private"
      metadata = {
        tier      = "gold"
        purpose   = "analytics-ready"
        analytics = "enabled"
      }
    }
  ]

  # Enterprise File Shares
  file_shares = [
    {
      name             = "executive-share"
      quota            = 1000
      access_tier      = "Premium"
      enabled_protocol = "SMB"
      metadata = {
        department     = "executive"
        classification = "confidential"
      }

      acl = [
        {
          id = "executive-policy"
          access_policy = {
            permissions = "rwdl"
            start       = "2024-01-01T00:00:00Z"
            expiry      = "2024-12-31T23:59:59Z"
          }
        }
      ]
    },
    {
      name             = "compliance-archive"
      quota            = 5000
      access_tier      = "Cool"
      enabled_protocol = "SMB"
      metadata = {
        purpose        = "compliance-archive"
        retention      = "10-years"
        classification = "restricted"
      }
    }
  ]

  # Naming convention
  naming_convention = {
    prefix = "ent"
    suffix = "prod"
  }

  tags = {
    Environment    = "Production"
    Project        = "Enterprise-Storage"
    Example        = "Enterprise"
    Classification = "Confidential"
    Compliance     = "SOC2-GDPR-SOX"
    Encryption     = "CustomerManaged"
    Network        = "Private"
    Monitoring     = "Enhanced"
    Backup         = "GeoRedundant"
  }

  depends_on = [
    azurerm_key_vault_access_policy.storage_cmk,
    azurerm_subnet.storage
  ]
}
