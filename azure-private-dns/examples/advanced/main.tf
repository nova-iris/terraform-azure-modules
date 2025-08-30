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

# Create multiple virtual networks for demonstration
resource "azurerm_resource_group" "example" {
  name     = "rg-private-dns-advanced-example"
  location = "West Europe"
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    Environment = "Development"
    Project     = "Private-DNS-Example"
    Type        = "Hub"
  }
}

resource "azurerm_virtual_network" "spoke1" {
  name                = "vnet-spoke1"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    Environment = "Development"
    Project     = "Private-DNS-Example"
    Type        = "Spoke1"
  }
}

resource "azurerm_virtual_network" "spoke2" {
  name                = "vnet-spoke2"
  address_space       = ["10.2.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    Environment = "Development"
    Project     = "Private-DNS-Example"
    Type        = "Spoke2"
  }
}

# Create subnets for DNS resolver
resource "azurerm_subnet" "dns_resolver" {
  name                 = "snet-dns-resolver"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "dns-resolver-delegation"
    service_delegation {
      name = "Microsoft.Network/dnsResolvers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

resource "azurerm_subnet" "dns_outbound" {
  name                 = "snet-dns-outbound"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "dns-outbound-delegation"
    service_delegation {
      name = "Microsoft.Network/dnsResolvers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

# Advanced Private DNS Zone module usage with DNS Resolver
module "private_dns" {
  source = "../../"

  # Advanced configuration
  location                = azurerm_resource_group.example.location
  resource_group_name     = azurerm_resource_group.example.name
  create_resource_group   = false
  private_dns_zone_name   = "corp.internal"
  environment            = "production"
  project_name           = "corporate-infrastructure"

  # Multiple virtual network links
  virtual_network_links = {
    "hub-vnet" = {
      virtual_network_id   = azurerm_virtual_network.hub.id
      registration_enabled = true
    }
    "spoke1-vnet" = {
      virtual_network_id   = azurerm_virtual_network.spoke1.id
      registration_enabled = false
    }
    "spoke2-vnet" = {
      virtual_network_id   = azurerm_virtual_network.spoke2.id
      registration_enabled = false
    }
  }

  # DNS Resolver configuration
  enable_dns_resolver              = true
  dns_resolver_virtual_network_id  = azurerm_virtual_network.hub.id
  enable_inbound_endpoint          = true
  enable_outbound_endpoint         = true
  outbound_endpoint_subnet_id      = azurerm_subnet.dns_outbound.id

  inbound_endpoint_ip_configurations = [
    {
      subnet_id                    = azurerm_subnet.dns_resolver.id
      private_ip_allocation_method = "Dynamic"
    }
  ]

  # DNS Forwarding Rules
  dns_forwarding_rulesets = {
    "external-dns" = {
      name = "external-dns-ruleset"

      forwarding_rules = [
        {
          name        = "azure-rule"
          domain_name = "azure.com."
          target_dns_servers = [
            {
              ip_address = "8.8.8.8"
              port       = 53
            },
            {
              ip_address = "8.8.4.4"
              port       = 53
            }
          ]
        },
        {
          name        = "corporate-rule"
          domain_name = "corp.external."
          target_dns_servers = [
            {
              ip_address = "192.168.1.10"
              port       = 53
            }
          ]
        }
      ]

      virtual_network_links = [
        {
          name               = "hub-link"
          virtual_network_id = azurerm_virtual_network.hub.id
        },
        {
          name               = "spoke1-link"
          virtual_network_id = azurerm_virtual_network.spoke1.id
        }
      ]
    }
  }

  # Comprehensive DNS records
  a_records = {
    "dc1" = {
      name    = "dc1"
      ttl     = 300
      records = ["10.0.1.10"]
    }
    "dc2" = {
      name    = "dc2"
      ttl     = 300
      records = ["10.0.1.11"]
    }
    "web-cluster" = {
      name    = "web-cluster"
      ttl     = 60
      records = ["10.1.1.10", "10.1.1.11", "10.1.1.12"]
    }
  }

  aaaa_records = {
    "ipv6-server" = {
      name    = "ipv6"
      ttl     = 300
      records = ["2001:db8::1"]
    }
  }

  cname_records = {
    "www" = {
      name   = "www"
      ttl    = 300
      record = "web-cluster.corp.internal"
    }
    "api" = {
      name   = "api"
      ttl    = 300
      record = "web-cluster.corp.internal"
    }
  }

  mx_records = {
    "mail-exchange" = {
      name = "@"
      ttl  = 3600
      records = [
        {
          preference = 10
          exchange   = "mail1.corp.internal"
        },
        {
          preference = 20
          exchange   = "mail2.corp.internal"
        }
      ]
    }
  }

  srv_records = {
    "sip-service" = {
      name = "_sip._tcp"
      ttl  = 300
      records = [
        {
          priority = 10
          weight   = 5
          port     = 5060
          target   = "sip1.corp.internal"
        },
        {
          priority = 10
          weight   = 5
          port     = 5060
          target   = "sip2.corp.internal"
        }
      ]
    }
  }

  txt_records = {
    "domain-verification" = {
      name    = "@"
      ttl     = 300
      records = ["v=spf1 include:_spf.corp.internal ~all"]
    }
    "dkim-selector" = {
      name    = "selector1._domainkey"
      ttl     = 300
      records = ["k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC..."]
    }
  }

  # Naming convention
  naming_convention = {
    prefix = ["corp"]
    suffix = ["prod"]
  }

  tags = {
    Environment   = "Production"
    Project       = "Corporate-Infrastructure"
    Example       = "Advanced"
    CostCenter    = "IT"
    Owner         = "Platform-Team"
    Compliance    = "SOC2"
  }
}
