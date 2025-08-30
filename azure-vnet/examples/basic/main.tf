# Basic Azure VNet Example
# This example demonstrates a simple VNet setup with basic subnets and NSGs

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.42.0"
    }
  }
}

provider "azurerm" {
  features {}

  resource_provider_registrations = "none"

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

module "basic_vnet" {
  source = "../../"

  # Basic Configuration
  name                  = "basic-vnet"
  location              = var.location
  resource_group_name   = var.resource_group_name
  create_resource_group = false # Use existing resource group
  address_space         = ["10.0.0.0/16"]

  # Azure naming convention configuration
  naming_convention = {
    prefix = ["dev"]
    suffix = ["001"]
  }

  # Simple subnet configuration
  subnets = [
    {
      name             = "web-subnet"
      address_prefixes = ["10.0.1.0/24"]
      create_nsg       = true

      security_rules = [
        {
          name                       = "allow-http"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "allow-https"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    },
    {
      name             = "app-subnet"
      address_prefixes = ["10.0.2.0/24"]
      create_nsg       = true
    },
    {
      name              = "db-subnet"
      address_prefixes  = ["10.0.3.0/24"]
      create_nsg        = true
      service_endpoints = ["Microsoft.Sql"]
    }
  ]

  tags = {
    Environment = "development"
    Project     = "basic-webapp"
    Owner       = "dev-team"
  }
}

# Outputs
output "vnet_id" {
  description = "ID of the created VNet"
  value       = module.basic_vnet.vnet_id
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value       = module.basic_vnet.subnet_ids
}

output "nsg_ids" {
  description = "Map of NSG names to IDs"
  value       = module.basic_vnet.nsg_ids
}
