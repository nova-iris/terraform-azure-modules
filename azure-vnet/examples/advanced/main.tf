# Advanced Azure VNet Example
# This example demonstrates all features including DDoS protection, flow logs, and traffic analytics

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Storage account for flow logs
resource "azurerm_storage_account" "flow_logs" {
  name                     = "flowlogssa${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Log Analytics Workspace for traffic analytics
resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_resource_group" "main" {
  name     = "advanced-vnet-rg"
  location = "East US"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

module "advanced_vnet" {
  source = "../../"

  # Basic Configuration
  name                  = "advanced-vnet"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  create_resource_group = false
  address_space         = ["10.0.0.0/16"]
  dns_servers           = ["8.8.8.8", "8.8.4.4"]

  # Azure naming convention configuration
  naming_convention = {
    prefix = ["prod"]
    suffix = ["eastus"]
  }

  # Enable DDoS Protection
  enable_ddos_protection = true

  # Advanced subnet configuration
  subnets = [
    {
      name               = "web-subnet"
      address_prefixes   = ["10.0.1.0/24"]
      service_endpoints  = ["Microsoft.Storage", "Microsoft.KeyVault"]
      create_nsg         = true
      create_route_table = true

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
        },
        {
          name                       = "deny-all-inbound"
          priority                   = 4000
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]

      routes = [
        {
          name           = "to-internet"
          address_prefix = "0.0.0.0/0"
          next_hop_type  = "Internet"
        }
      ]
    },
    {
      name              = "app-subnet"
      address_prefixes  = ["10.0.2.0/24"]
      create_nsg        = true
      service_endpoints = ["Microsoft.Sql", "Microsoft.Storage"]

      delegations = [
        {
          name = "aci-delegation"
          service_delegation = {
            name = "Microsoft.ContainerInstance/containerGroups"
            actions = [
              "Microsoft.Network/virtualNetworks/subnets/action"
            ]
          }
        }
      ]

      security_rules = [
        {
          name                       = "allow-app-traffic"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_ranges    = ["8080", "8443"]
          source_address_prefix      = "10.0.1.0/24"
          destination_address_prefix = "*"
        }
      ]
    },
    {
      name              = "db-subnet"
      address_prefixes  = ["10.0.3.0/24"]
      create_nsg        = true
      service_endpoints = ["Microsoft.Sql"]

      security_rules = [
        {
          name                       = "allow-sql"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "1433"
          source_address_prefix      = "10.0.2.0/24"
          destination_address_prefix = "*"
        },
        {
          name                       = "deny-all-inbound"
          priority                   = 4000
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }
  ]

  # Flow Logs and Traffic Analytics
  enable_flow_logs                    = true
  network_watcher_name                = "NetworkWatcher_eastus"
  network_watcher_resource_group_name = "NetworkWatcherRG"
  flow_logs_storage_account_id        = azurerm_storage_account.flow_logs.id
  flow_logs_retention_enabled         = true
  flow_logs_retention_days            = 90

  enable_traffic_analytics            = true
  log_analytics_workspace_id          = azurerm_log_analytics_workspace.main.workspace_id
  log_analytics_workspace_resource_id = azurerm_log_analytics_workspace.main.id

  tags = {
    Environment = "production"
    Project     = "enterprise-app"
    CostCenter  = "IT-001"
    Owner       = "infrastructure-team"
    Backup      = "required"
    Monitoring  = "enabled"
  }
}

# Outputs
output "vnet_module_complete" {
  description = "Complete VNet module output"
  value       = module.advanced_vnet.vnet_module
}

output "storage_account_id" {
  description = "Storage account ID for flow logs"
  value       = azurerm_storage_account.flow_logs.id
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  value       = azurerm_log_analytics_workspace.main.id
}
