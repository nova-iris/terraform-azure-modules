# Storage Account Information
output "storage_account_id" {
  description = "The ID of the Storage Account"
  value       = module.advanced_storage.storage_account_id
}

output "storage_account_name" {
  description = "The name of the Storage Account"
  value       = module.advanced_storage.storage_account_name
}

# Service Endpoints
output "primary_blob_endpoint" {
  description = "The primary blob endpoint"
  value       = module.advanced_storage.primary_blob_endpoint
}

output "primary_file_endpoint" {
  description = "The primary file endpoint"
  value       = module.advanced_storage.primary_file_endpoint
}

output "primary_dfs_endpoint" {
  description = "The primary DFS endpoint (Data Lake Gen2)"
  value       = module.advanced_storage.primary_dfs_endpoint
}

output "primary_queue_endpoint" {
  description = "The primary queue endpoint"
  value       = module.advanced_storage.primary_queue_endpoint
}

output "primary_table_endpoint" {
  description = "The primary table endpoint"
  value       = module.advanced_storage.primary_table_endpoint
}

# Secondary Endpoints (GRS replication)
output "secondary_blob_endpoint" {
  description = "The secondary blob endpoint"
  value       = module.advanced_storage.secondary_blob_endpoint
}

output "secondary_file_endpoint" {
  description = "The secondary file endpoint"
  value       = module.advanced_storage.secondary_file_endpoint
}

# Identity Information
output "storage_identity" {
  description = "The managed identity information for the storage account"
  value       = module.advanced_storage.identity
}

# Container Information
output "containers" {
  description = "Information about created containers"
  value       = module.advanced_storage.containers
}

# File Share Information
output "file_shares" {
  description = "Information about created file shares"
  value       = module.advanced_storage.file_shares
}

# Network Configuration
output "virtual_network_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.example.id
}

output "storage_subnet_id" {
  description = "The ID of the storage subnet"
  value       = azurerm_subnet.storage.id
}

# Access Information (sensitive)
output "primary_access_key" {
  description = "Primary access key for the storage account"
  value       = module.advanced_storage.primary_access_key
  sensitive   = true
}

output "primary_connection_string" {
  description = "Primary connection string for the storage account"
  value       = module.advanced_storage.primary_connection_string
  sensitive   = true
}

output "primary_blob_connection_string" {
  description = "Primary blob connection string"
  value       = module.advanced_storage.primary_blob_connection_string
  sensitive   = true
}
