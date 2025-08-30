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

module "storage" {
  source = "../../"

  # Resource Group
  create_resource_group = true
  resource_group_name   = "rg-storage-basic-example"
  location              = "West Europe"

  # Storage Account Configuration
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Hot"

  # Basic containers
  containers = [
    {
      name                  = "documents"
      container_access_type = "private"
    },
    {
      name                  = "public-assets"
      container_access_type = "blob"
      metadata = {
        purpose = "public-content"
      }
    },
    {
      name                  = "backup"
      container_access_type = "private"
      metadata = {
        purpose   = "backup-storage"
        retention = "30-days"
      }
    }
  ]

  # Basic file shares
  file_shares = [
    {
      name  = "shared-files"
      quota = 100
    },
    {
      name        = "department-files"
      quota       = 250
      access_tier = "Cool"
    }
  ]

  # Naming convention
  naming_convention = {
    prefix = "example"
    suffix = "basic"
  }

  tags = {
    Environment = "Development"
    Project     = "Storage-Example"
    Example     = "Basic"
  }
}
