# Storage Account Information
output "storage_account_id" {
  description = "The ID of the Storage Account"
  value       = module.storage.storage_account_id
}

output "storage_account_name" {
  description = "The name of the Storage Account"
  value       = module.storage.storage_account_name
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint"
  value       = module.storage.primary_blob_endpoint
}

output "primary_file_endpoint" {
  description = "The primary file endpoint"
  value       = module.storage.primary_file_endpoint
}

# Container Information
output "containers" {
  description = "Information about created containers"
  value       = module.storage.containers
}

# File Share Information
output "file_shares" {
  description = "Information about created file shares"
  value       = module.storage.file_shares
}

# Resource Group Information
output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.storage.resource_group_name
}

# Connection String (for testing - sensitive)
output "connection_string" {
  description = "Primary connection string for the storage account"
  value       = module.storage.primary_connection_string
  sensitive   = true
}
