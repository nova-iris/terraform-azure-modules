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
  features {}
}

# Create a virtual network for network rules demonstration
resource "azurerm_virtual_network" "example" {
  name                = "vnet-storage-example"
  address_space       = ["10.0.0.0/16"]
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    Environment = "Development"
    Purpose     = "Storage-Example"
  }
}

resource "azurerm_subnet" "storage" {
  name                 = "subnet-storage"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_resource_group" "example" {
  name     = "rg-storage-advanced-example"
  location = "West Europe"

  tags = {
    Environment = "Development"
    Example     = "Advanced"
  }
}

module "advanced_storage" {
  source = "../../"

  # Use existing resource group
  create_resource_group = false
  resource_group_name   = azurerm_resource_group.example.name

  # Storage Account Configuration
  storage_account_name     = null # Auto-generated
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  access_tier              = "Hot"

  # Security Configuration
  https_traffic_only_enabled        = true
  min_tls_version                   = "TLS1_2"
  allow_nested_items_to_be_public   = false
  public_network_access_enabled     = true # Set to false for production
  infrastructure_encryption_enabled = true
  shared_access_key_enabled         = true

  # Advanced Features
  is_hns_enabled                   = true # Enable Data Lake Gen2
  large_file_share_enabled         = true
  cross_tenant_replication_enabled = false

  # Identity Configuration
  identity = {
    type = "SystemAssigned"
  }

  # Network Rules - Restrict access
  network_rules = {
    default_action             = "Allow" # Use "Deny" for production
    bypass                     = ["AzureServices", "Metrics", "Logging"]
    ip_rules                   = ["203.0.113.0/24"] # Replace with your IP ranges
    virtual_network_subnet_ids = [azurerm_subnet.storage.id]
  }

  # Blob Properties with Advanced Features
  blob_properties = {
    versioning_enabled            = true
    change_feed_enabled           = true
    change_feed_retention_in_days = 30
    last_access_time_enabled      = true

    delete_retention_policy = {
      days                     = 30
      permanent_delete_enabled = false
    }

    container_delete_retention_policy = {
      days = 7
    }

    cors_rule = [
      {
        allowed_headers    = ["x-ms-blob-content-type", "x-ms-blob-content-disposition"]
        allowed_methods    = ["GET", "POST", "PUT"]
        allowed_origins    = ["https://example.com", "https://app.example.com"]
        exposed_headers    = ["x-ms-request-id"]
        max_age_in_seconds = 3600
      }
    ]
  }

  # Queue Properties with Metrics
  queue_properties = {
    cors_rule = [
      {
        allowed_headers    = ["*"]
        allowed_methods    = ["GET", "POST"]
        allowed_origins    = ["https://example.com"]
        exposed_headers    = ["*"]
        max_age_in_seconds = 1800
      }
    ]

    logging = {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 7
    }

    minute_metrics = {
      enabled               = true
      version               = "1.0"
      include_apis          = true
      retention_policy_days = 7
    }
  }

  # Share Properties with SMB configuration
  share_properties = {
    retention_policy = {
      days = 30
    }

    smb = {
      versions                        = ["SMB2.1", "SMB3.0", "SMB3.1.1"]
      authentication_types            = ["NTLMv2", "Kerberos"]
      kerberos_ticket_encryption_type = ["RC4-HMAC", "AES-256"]
      channel_encryption_type         = ["AES-128-CCM", "AES-128-GCM", "AES-256-GCM"]
      multichannel_enabled            = false
    }
  }

  # Advanced containers with metadata
  containers = [
    {
      name                  = "secure-documents"
      container_access_type = "private"
      metadata = {
        purpose        = "confidential-storage"
        classification = "restricted"
        department     = "finance"
      }
    },
    {
      name                  = "data-lake-raw"
      container_access_type = "private"
      metadata = {
        purpose = "data-lake-bronze"
        stage   = "raw-ingestion"
      }
    },
    {
      name                  = "data-lake-processed"
      container_access_type = "private"
      metadata = {
        purpose = "data-lake-silver"
        stage   = "processed-data"
      }
    },
    {
      name                  = "analytics-results"
      container_access_type = "private"
      metadata = {
        purpose = "data-lake-gold"
        stage   = "analytics-output"
      }
    }
  ]

  # File shares with access control
  file_shares = [
    {
      name             = "department-share"
      quota            = 500
      access_tier      = "Hot"
      enabled_protocol = "SMB"
      metadata = {
        department = "engineering"
        purpose    = "shared-development"
      }

      acl = [
        {
          id = "development-policy"
          access_policy = {
            permissions = "rwdl"
            start       = "2024-01-01T00:00:00Z"
            expiry      = "2024-12-31T23:59:59Z"
          }
        }
      ]
    },
    {
      name             = "backup-share"
      quota            = 1000
      access_tier      = "Cool"
      enabled_protocol = "SMB"
      metadata = {
        purpose   = "backup-storage"
        retention = "1-year"
      }
    }
  ]

  # SAS Policy for enhanced security
  sas_policy = {
    expiration_period = "30.00:00:00" # 30 days
    expiration_action = "Log"
  }

  # Naming convention
  naming_convention = {
    prefix = "adv"
    suffix = "demo"
  }

  tags = {
    Environment = "Development"
    Project     = "Storage-Advanced"
    Example     = "Advanced"
    Security    = "Enhanced"
    DataLake    = "Enabled"
    Compliance  = "GDPR"
  }

  depends_on = [azurerm_subnet.storage]
}
