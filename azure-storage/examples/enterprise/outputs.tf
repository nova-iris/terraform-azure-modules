# Storage Account Information
output "storage_account_id" {
  description = "The ID of the Storage Account"
  value       = module.enterprise_storage.storage_account_id
}

output "storage_account_name" {
  description = "The name of the Storage Account"
  value       = module.enterprise_storage.storage_account_name
}

# Service Endpoints
output "primary_blob_endpoint" {
  description = "The primary blob endpoint"
  value       = module.enterprise_storage.primary_blob_endpoint
}

output "primary_file_endpoint" {
  description = "The primary file endpoint"
  value       = module.enterprise_storage.primary_file_endpoint
}

output "primary_dfs_endpoint" {
  description = "The primary DFS endpoint (Data Lake Gen2)"
  value       = module.enterprise_storage.primary_dfs_endpoint
}

output "primary_queue_endpoint" {
  description = "The primary queue endpoint"
  value       = module.enterprise_storage.primary_queue_endpoint
}

output "primary_table_endpoint" {
  description = "The primary table endpoint"
  value       = module.enterprise_storage.primary_table_endpoint
}

# Geo-Redundant Secondary Endpoints
output "secondary_blob_endpoint" {
  description = "The secondary blob endpoint (GZRS)"
  value       = module.enterprise_storage.secondary_blob_endpoint
}

output "secondary_file_endpoint" {
  description = "The secondary file endpoint (GZRS)"
  value       = module.enterprise_storage.secondary_file_endpoint
}

output "secondary_dfs_endpoint" {
  description = "The secondary DFS endpoint (GZRS)"
  value       = module.enterprise_storage.secondary_dfs_endpoint
}

# Identity Information
output "storage_identity" {
  description = "The managed identity information for the storage account"
  value       = module.enterprise_storage.identity
}

# Security Infrastructure
output "key_vault_id" {
  description = "The ID of the Key Vault used for customer-managed keys"
  value       = azurerm_key_vault.enterprise.id
}

output "customer_managed_key_id" {
  description = "The ID of the customer-managed encryption key"
  value       = azurerm_key_vault_key.storage_key.id
}

output "user_assigned_identity_id" {
  description = "The ID of the user-assigned managed identity for CMK"
  value       = azurerm_user_assigned_identity.storage_cmk.id
}

# Network Infrastructure
output "virtual_network_id" {
  description = "The ID of the enterprise virtual network"
  value       = azurerm_virtual_network.enterprise.id
}

output "storage_subnet_id" {
  description = "The ID of the storage subnet"
  value       = azurerm_subnet.storage.id
}

output "private_endpoints_subnet_id" {
  description = "The ID of the private endpoints subnet"
  value       = azurerm_subnet.private_endpoints.id
}

# Container Information
output "containers" {
  description = "Information about created enterprise containers"
  value       = module.enterprise_storage.containers
}

# File Share Information
output "file_shares" {
  description = "Information about created enterprise file shares"
  value       = module.enterprise_storage.file_shares
}

# Resource Group Information
output "resource_group_name" {
  description = "The name of the enterprise resource group"
  value       = azurerm_resource_group.enterprise.name
}

output "resource_group_location" {
  description = "The location of the enterprise resource group"
  value       = azurerm_resource_group.enterprise.location
}

# Compliance and Security Status
output "security_features" {
  description = "Summary of enabled security features"
  value = {
    https_only                = true
    min_tls_version           = "TLS1_2"
    public_access_disabled    = true
    infrastructure_encryption = true
    customer_managed_keys     = true
    shared_key_disabled       = true
    network_access_restricted = true
    blob_versioning           = true
    blob_change_feed          = true
    immutability_policy       = true
    audit_logging             = true
  }
}

output "compliance_features" {
  description = "Summary of compliance features enabled"
  value = {
    data_lake_gen2             = true
    sftp_enabled               = true
    geo_redundancy             = "GZRS"
    backup_retention_days      = 90
    audit_retention_days       = 365
    immutability_period_years  = 7
    point_in_time_restore_days = 30
  }
}
