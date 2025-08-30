# Azure Storage Module

This Terraform module creates and manages Azure Storage Accounts with comprehensive configuration options including containers, file shares, network rules, and advanced security features.

## Features

- **Storage Account Management**: Create and configure Azure Storage Accounts with all available options
- **Multiple Storage Types**: Support for Blob, File, Queue, Table, and Data Lake Storage
- **Containers & File Shares**: Automated creation and management of storage containers and file shares
- **Network Security**: Configure network rules, private endpoints, and access controls
- **Advanced Security**: Support for customer-managed keys, identity management, and immutability policies
- **Compliance Features**: SFTP, NFSv3, hierarchical namespace (Data Lake Gen2)
- **Flexible Configuration**: Comprehensive variable system for all Azure Storage features

## Usage

### Basic Storage Account

```hcl
module "storage" {
  source = "./azure-storage"

  # Resource Group
  create_resource_group = true
  resource_group_name   = "rg-storage-example"
  location              = "West Europe"

  # Storage Account Configuration
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Basic containers
  containers = [
    {
      name                  = "documents"
      container_access_type = "private"
    },
    {
      name                  = "public-assets"
      container_access_type = "blob"
    }
  ]

  # Basic file shares
  file_shares = [
    {
      name  = "shared-files"
      quota = 100
    }
  ]

  tags = {
    Environment = "Development"
    Project     = "MyProject"
  }
}
```

### Advanced Storage Account with Security Features

```hcl
module "advanced_storage" {
  source = "./azure-storage"

  # Resource Group
  create_resource_group = false
  resource_group_name   = "existing-rg"

  # Storage Account Configuration
  storage_account_name     = "mystorageaccount"
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  access_tier              = "Hot"

  # Security Configuration
  https_traffic_only_enabled         = true
  min_tls_version                    = "TLS1_2"
  allow_nested_items_to_be_public    = false
  public_network_access_enabled      = false
  infrastructure_encryption_enabled  = true

  # Identity Configuration
  identity = {
    type = "SystemAssigned"
  }

  # Network Rules
  network_rules = {
    default_action = "Deny"
    bypass         = ["AzureServices"]
    ip_rules       = ["203.0.113.0/24"]
    virtual_network_subnet_ids = [
      "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-main/subnets/subnet-storage"
    ]
  }

  # Blob Properties with Retention
  blob_properties = {
    versioning_enabled  = true
    change_feed_enabled = true
    
    delete_retention_policy = {
      days = 30
    }
    
    container_delete_retention_policy = {
      days = 7
    }

    cors_rule = [
      {
        allowed_headers    = ["*"]
        allowed_methods    = ["GET", "POST"]
        allowed_origins    = ["https://example.com"]
        exposed_headers    = ["*"]
        max_age_in_seconds = 3600
      }
    ]
  }

  # Advanced containers with metadata
  containers = [
    {
      name                  = "secure-documents"
      container_access_type = "private"
      metadata = {
        purpose = "confidential-storage"
        tier    = "premium"
      }
    }
  ]

  # File shares with access control
  file_shares = [
    {
      name             = "department-share"
      quota            = 500
      access_tier      = "Cool"
      enabled_protocol = "SMB"
      
      acl = [
        {
          id = "policy1"
          access_policy = {
            permissions = "rwdl"
            start       = "2024-01-01T00:00:00Z"
            expiry      = "2024-12-31T23:59:59Z"
          }
        }
      ]
    }
  ]

  tags = {
    Environment   = "Production"
    Compliance    = "SOC2"
    DataClass     = "Sensitive"
  }
}
```

### Data Lake Storage Gen2 Configuration

```hcl
module "data_lake_storage" {
  source = "./azure-storage"

  # Resource Group
  create_resource_group = true
  resource_group_name   = "rg-datalake"
  location              = "East US 2"

  # Data Lake Configuration
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "ZRS"
  is_hns_enabled          = true  # Hierarchical Namespace for Data Lake Gen2

  # Security for Data Lake
  https_traffic_only_enabled = true
  min_tls_version           = "TLS1_2"
  
  # Identity for Data Lake access
  identity = {
    type = "SystemAssigned"
  }

  # Containers for Data Lake
  containers = [
    {
      name                  = "raw-data"
      container_access_type = "private"
    },
    {
      name                  = "processed-data"
      container_access_type = "private"
    },
    {
      name                  = "analytics-results"
      container_access_type = "private"
    }
  ]

  tags = {
    Purpose     = "DataLake"
    Environment = "Analytics"
  }
}
```

### Premium Storage with SFTP

```hcl
module "premium_storage" {
  source = "./azure-storage"

  # Resource Group
  create_resource_group = true
  resource_group_name   = "rg-premium-storage"
  location              = "West Europe"

  # Premium Configuration
  account_kind             = "BlockBlobStorage"
  account_tier             = "Premium"
  account_replication_type = "LRS"
  
  # Advanced Features
  is_hns_enabled = true
  sftp_enabled   = true

  # Security
  identity = {
    type = "SystemAssigned"
  }

  containers = [
    {
      name                  = "high-performance"
      container_access_type = "private"
    }
  ]

  tags = {
    Performance = "Premium"
    Protocol    = "SFTP"
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 4.42.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 4.42.0 |
| random | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| naming | Azure/naming/azurerm | 0.4.2 |

## Resources

| Name | Type |
|------|------|
| azurerm_storage_account.main | resource |
| azurerm_storage_container.containers | resource |
| azurerm_storage_share.file_shares | resource |
| azurerm_resource_group.main | resource |
| random_string.storage_suffix | resource |
| azurerm_client_config.current | data source |
| azurerm_resource_group.main | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_group_name | The name of the resource group where the storage account will be created | `string` | n/a | yes |
| create_resource_group | Whether to create a new resource group or use an existing one | `bool` | `true` | no |
| location | The Azure region where the storage account will be created | `string` | `"West Europe"` | no |
| storage_account_name | The name of the storage account. If not provided, a name will be generated | `string` | `null` | no |
| account_kind | The kind of storage account | `string` | `"StorageV2"` | no |
| account_tier | The tier to use for this storage account | `string` | `"Standard"` | no |
| account_replication_type | The type of replication to use for this storage account | `string` | `"LRS"` | no |
| access_tier | The access tier for BlobStorage, FileStorage and StorageV2 accounts | `string` | `"Hot"` | no |
| containers | List of containers to create in the storage account | `list(object)` | `[]` | no |
| file_shares | List of file shares to create in the storage account | `list(object)` | `[]` | no |
| network_rules | Network rules configuration for the Storage Account | `object` | `null` | no |
| blob_properties | Blob properties configuration for the Storage Account | `object` | `null` | no |
| queue_properties | Queue properties configuration for the Storage Account | `object` | `null` | no |
| share_properties | Share properties configuration for the Storage Account | `object` | `null` | no |
| identity | Managed Service Identity configuration for the Storage Account | `object` | `null` | no |
| customer_managed_key | Customer managed key configuration for the Storage Account | `object` | `null` | no |
| tags | A mapping of tags to assign to all resources | `map(string)` | `{}` | no |

See [variables.tf](./variables.tf) for the complete list of input variables.

## Outputs

| Name | Description |
|------|-------------|
| storage_account_id | The ID of the Storage Account |
| storage_account_name | The name of the Storage Account |
| primary_blob_endpoint | The endpoint URL for blob storage in the primary location |
| primary_file_endpoint | The endpoint URL for file storage in the primary location |
| primary_access_key | The primary access key for the storage account (sensitive) |
| containers | Information about created storage containers |
| file_shares | Information about created file shares |
| identity | The identity information for the Storage Account |

See [outputs.tf](./outputs.tf) for the complete list of outputs.

## Examples

- [Basic](./examples/basic) - Basic storage account with containers and file shares
- [Advanced](./examples/advanced) - Advanced configuration with security features
- [Enterprise](./examples/enterprise) - Enterprise-grade setup with compliance features

## Storage Account Naming

The module automatically generates unique storage account names using the Azure naming module and a random suffix. You can override this by providing a `storage_account_name` variable.

Storage account names must:
- Be between 3 and 24 characters long
- Contain only lowercase letters and numbers
- Be globally unique across Azure

## Network Security

The module supports comprehensive network security configuration:

- **Network Rules**: Control access by IP ranges and virtual network subnets
- **Private Endpoints**: Support for private link access
- **Firewall Rules**: IP-based access control
- **Service Endpoints**: Secure access from virtual networks

## Advanced Features

### Data Lake Storage Gen2
Enable hierarchical namespace with `is_hns_enabled = true` for Data Lake Storage Gen2 capabilities.

### SFTP Support
Enable SFTP access with `sftp_enabled = true` (requires hierarchical namespace).

### Customer Managed Keys
Configure customer-managed encryption keys for enhanced security.

### Immutability Policies
Configure time-based retention and legal hold policies for compliance.

## Security Best Practices

1. **Always use HTTPS**: Set `https_traffic_only_enabled = true`
2. **Minimum TLS Version**: Use `min_tls_version = "TLS1_2"`
3. **Network Access**: Restrict with `public_network_access_enabled = false`
4. **Shared Key Access**: Consider disabling with `shared_access_key_enabled = false`
5. **Blob Public Access**: Disable with `allow_nested_items_to_be_public = false`

## License

This module is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.
<!-- END_TF_DOCS -->
