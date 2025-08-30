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

# Create a virtual network for demonstration
resource "azurerm_resource_group" "example" {
  name     = "rg-private-dns-basic-example"
  location = "West Europe"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-private-dns-example"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    Environment = "Development"
    Project     = "Private-DNS-Example"
  }
}

# Basic Private DNS Zone module usage
module "private_dns" {
  source = "../../"

  # Basic configuration
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  create_resource_group = false
  private_dns_zone_name = "example.internal"

  # Virtual network links
  virtual_network_links = {
    "primary-vnet" = {
      virtual_network_id   = azurerm_virtual_network.example.id
      registration_enabled = true
    }
  }

  # Basic DNS records
  a_records = {
    "web-server" = {
      name    = "web"
      ttl     = 300
      records = ["10.0.1.10"]
    }
    "api-server" = {
      name    = "api"
      ttl     = 300
      records = ["10.0.1.20"]
    }
  }

  cname_records = {
    "www-alias" = {
      name   = "www"
      ttl    = 300
      record = "web.example.internal"
    }
  }

  # Naming convention
  naming_convention = {
    prefix = ["example"]
    suffix = ["basic"]
  }

  tags = {
    Environment = "Development"
    Project     = "Private-DNS-Example"
    Example     = "Basic"
  }
}
