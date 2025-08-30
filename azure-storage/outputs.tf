# Storage Account Outputs
output "storage_account_id" {
  description = "The ID of the Storage Account."
  value       = azurerm_storage_account.main.id
}

output "storage_account_name" {
  description = "The name of the Storage Account."
  value       = azurerm_storage_account.main.name
}

output "storage_account_primary_location" {
  description = "The primary location of the storage account."
  value       = azurerm_storage_account.main.primary_location
}

output "storage_account_secondary_location" {
  description = "The secondary location of the storage account."
  value       = azurerm_storage_account.main.secondary_location
}

# Blob Service Outputs
output "primary_blob_endpoint" {
  description = "The endpoint URL for blob storage in the primary location."
  value       = azurerm_storage_account.main.primary_blob_endpoint
}

output "primary_blob_host" {
  description = "The hostname with port if applicable for blob storage in the primary location."
  value       = azurerm_storage_account.main.primary_blob_host
}

output "secondary_blob_endpoint" {
  description = "The endpoint URL for blob storage in the secondary location."
  value       = azurerm_storage_account.main.secondary_blob_endpoint
}

output "secondary_blob_host" {
  description = "The hostname with port if applicable for blob storage in the secondary location."
  value       = azurerm_storage_account.main.secondary_blob_host
}

# Queue Service Outputs
output "primary_queue_endpoint" {
  description = "The endpoint URL for queue storage in the primary location."
  value       = azurerm_storage_account.main.primary_queue_endpoint
}

output "primary_queue_host" {
  description = "The hostname with port if applicable for queue storage in the primary location."
  value       = azurerm_storage_account.main.primary_queue_host
}

output "secondary_queue_endpoint" {
  description = "The endpoint URL for queue storage in the secondary location."
  value       = azurerm_storage_account.main.secondary_queue_endpoint
}

output "secondary_queue_host" {
  description = "The hostname with port if applicable for queue storage in the secondary location."
  value       = azurerm_storage_account.main.secondary_queue_host
}

# Table Service Outputs
output "primary_table_endpoint" {
  description = "The endpoint URL for table storage in the primary location."
  value       = azurerm_storage_account.main.primary_table_endpoint
}

output "primary_table_host" {
  description = "The hostname with port if applicable for table storage in the primary location."
  value       = azurerm_storage_account.main.primary_table_host
}

output "secondary_table_endpoint" {
  description = "The endpoint URL for table storage in the secondary location."
  value       = azurerm_storage_account.main.secondary_table_endpoint
}

output "secondary_table_host" {
  description = "The hostname with port if applicable for table storage in the secondary location."
  value       = azurerm_storage_account.main.secondary_table_host
}

# File Service Outputs
output "primary_file_endpoint" {
  description = "The endpoint URL for file storage in the primary location."
  value       = azurerm_storage_account.main.primary_file_endpoint
}

output "primary_file_host" {
  description = "The hostname with port if applicable for file storage in the primary location."
  value       = azurerm_storage_account.main.primary_file_host
}

output "secondary_file_endpoint" {
  description = "The endpoint URL for file storage in the secondary location."
  value       = azurerm_storage_account.main.secondary_file_endpoint
}

output "secondary_file_host" {
  description = "The hostname with port if applicable for file storage in the secondary location."
  value       = azurerm_storage_account.main.secondary_file_host
}

# DFS (Data Lake) Outputs
output "primary_dfs_endpoint" {
  description = "The endpoint URL for DFS storage in the primary location."
  value       = azurerm_storage_account.main.primary_dfs_endpoint
}

output "primary_dfs_host" {
  description = "The hostname with port if applicable for DFS storage in the primary location."
  value       = azurerm_storage_account.main.primary_dfs_host
}

output "secondary_dfs_endpoint" {
  description = "The endpoint URL for DFS storage in the secondary location."
  value       = azurerm_storage_account.main.secondary_dfs_endpoint
}

output "secondary_dfs_host" {
  description = "The hostname with port if applicable for DFS storage in the secondary location."
  value       = azurerm_storage_account.main.secondary_dfs_host
}

# Web Service Outputs
output "primary_web_endpoint" {
  description = "The endpoint URL for web storage in the primary location."
  value       = azurerm_storage_account.main.primary_web_endpoint
}

output "primary_web_host" {
  description = "The hostname with port if applicable for web storage in the primary location."
  value       = azurerm_storage_account.main.primary_web_host
}

output "secondary_web_endpoint" {
  description = "The endpoint URL for web storage in the secondary location."
  value       = azurerm_storage_account.main.secondary_web_endpoint
}

output "secondary_web_host" {
  description = "The hostname with port if applicable for web storage in the secondary location."
  value       = azurerm_storage_account.main.secondary_web_host
}

# Access Keys (sensitive)
output "primary_access_key" {
  description = "The primary access key for the storage account."
  value       = azurerm_storage_account.main.primary_access_key
  sensitive   = true
}

output "secondary_access_key" {
  description = "The secondary access key for the storage account."
  value       = azurerm_storage_account.main.secondary_access_key
  sensitive   = true
}

# Connection Strings (sensitive)
output "primary_connection_string" {
  description = "The connection string associated with the primary location."
  value       = azurerm_storage_account.main.primary_connection_string
  sensitive   = true
}

output "secondary_connection_string" {
  description = "The connection string associated with the secondary location."
  value       = azurerm_storage_account.main.secondary_connection_string
  sensitive   = true
}

output "primary_blob_connection_string" {
  description = "The connection string associated with the primary blob location."
  value       = azurerm_storage_account.main.primary_blob_connection_string
  sensitive   = true
}

output "secondary_blob_connection_string" {
  description = "The connection string associated with the secondary blob location."
  value       = azurerm_storage_account.main.secondary_blob_connection_string
  sensitive   = true
}

# Identity Outputs
output "identity" {
  description = "The identity information for the Storage Account."
  value = var.identity != null ? {
    type         = azurerm_storage_account.main.identity[0].type
    principal_id = azurerm_storage_account.main.identity[0].principal_id
    tenant_id    = azurerm_storage_account.main.identity[0].tenant_id
  } : null
}

# Container Outputs
output "containers" {
  description = "The information about created storage containers."
  value = {
    for name, container in azurerm_storage_container.containers : name => {
      id                      = container.id
      name                    = container.name
      has_immutability_policy = container.has_immutability_policy
      has_legal_hold          = container.has_legal_hold
      resource_manager_id     = container.resource_manager_id
    }
  }
}

# File Share Outputs
output "file_shares" {
  description = "The information about created file shares."
  value = {
    for name, share in azurerm_storage_share.file_shares : name => {
      id                  = share.id
      name                = share.name
      url                 = share.url
      resource_manager_id = share.resource_manager_id
    }
  }
}

# Resource Group Outputs
output "resource_group_name" {
  description = "The name of the resource group."
  value       = local.resource_group_name
}

output "resource_group_location" {
  description = "The location of the resource group."
  value       = local.resource_group_location
}

# Internet and Microsoft Routing Endpoints (when routing is configured)
output "primary_blob_internet_endpoint" {
  description = "The internet routing endpoint URL for blob storage in the primary location."
  value       = azurerm_storage_account.main.primary_blob_internet_endpoint
}

output "primary_blob_microsoft_endpoint" {
  description = "The microsoft routing endpoint URL for blob storage in the primary location."
  value       = azurerm_storage_account.main.primary_blob_microsoft_endpoint
}

output "primary_file_internet_endpoint" {
  description = "The internet routing endpoint URL for file storage in the primary location."
  value       = azurerm_storage_account.main.primary_file_internet_endpoint
}

output "primary_file_microsoft_endpoint" {
  description = "The microsoft routing endpoint URL for file storage in the primary location."
  value       = azurerm_storage_account.main.primary_file_microsoft_endpoint
}

output "primary_dfs_internet_endpoint" {
  description = "The internet routing endpoint URL for DFS storage in the primary location."
  value       = azurerm_storage_account.main.primary_dfs_internet_endpoint
}

output "primary_dfs_microsoft_endpoint" {
  description = "The microsoft routing endpoint URL for DFS storage in the primary location."
  value       = azurerm_storage_account.main.primary_dfs_microsoft_endpoint
}

output "primary_web_internet_endpoint" {
  description = "The internet routing endpoint URL for web storage in the primary location."
  value       = azurerm_storage_account.main.primary_web_internet_endpoint
}

output "primary_web_microsoft_endpoint" {
  description = "The microsoft routing endpoint URL for web storage in the primary location."
  value       = azurerm_storage_account.main.primary_web_microsoft_endpoint
}
