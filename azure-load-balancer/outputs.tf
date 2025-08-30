# Azure Load Balancer Module - Outputs
# Output values from the Azure Load Balancer module

# Resource Group Outputs
output "resource_group_name" {
  description = "Name of the resource group"
  value       = local.resource_group_name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = var.create_resource_group ? azurerm_resource_group.main[0].id : data.azurerm_resource_group.main[0].id
}

# Load Balancer Outputs
output "load_balancer_id" {
  description = "ID of the Load Balancer"
  value       = azurerm_lb.main.id
}

output "load_balancer_name" {
  description = "Name of the Load Balancer"
  value       = azurerm_lb.main.name
}

output "load_balancer_sku" {
  description = "SKU of the Load Balancer"
  value       = azurerm_lb.main.sku
}

output "load_balancer_private_ip_address" {
  description = "Private IP address of the Load Balancer"
  value       = azurerm_lb.main.private_ip_address
}

output "load_balancer_private_ip_addresses" {
  description = "List of private IP addresses of the Load Balancer"
  value       = azurerm_lb.main.private_ip_addresses
}

# Public IP Outputs
output "public_ip_ids" {
  description = "Map of public IP names to their IDs"
  value = {
    for name, pip in azurerm_public_ip.main : name => pip.id
  }
}

output "public_ip_addresses" {
  description = "Map of public IP names to their IP addresses"
  value = {
    for name, pip in azurerm_public_ip.main : name => pip.ip_address
  }
}

output "public_ip_fqdns" {
  description = "Map of public IP names to their FQDNs"
  value = {
    for name, pip in azurerm_public_ip.main : name => pip.fqdn
  }
}

# Frontend IP Configuration Outputs
output "frontend_ip_configuration_ids" {
  description = "List of frontend IP configuration IDs"
  value       = azurerm_lb.main.frontend_ip_configuration[*].id
}

output "frontend_ip_configuration_names" {
  description = "List of frontend IP configuration names"
  value       = azurerm_lb.main.frontend_ip_configuration[*].name
}

output "frontend_ip_configurations" {
  description = "Map of frontend IP configurations"
  value = {
    for config in azurerm_lb.main.frontend_ip_configuration : config.name => {
      id                   = config.id
      name                 = config.name
      private_ip_address   = config.private_ip_address
      public_ip_address_id = config.public_ip_address_id
      subnet_id            = config.subnet_id
    }
  }
}

# Backend Address Pool Outputs
output "backend_address_pool_ids" {
  description = "Map of backend address pool names to their IDs"
  value = {
    for name, pool in azurerm_lb_backend_address_pool.main : name => pool.id
  }
}

output "backend_address_pool_names" {
  description = "List of backend address pool names"
  value       = [for pool in azurerm_lb_backend_address_pool.main : pool.name]
}

output "backend_address_pools" {
  description = "Map of backend address pools"
  value = {
    for name, pool in azurerm_lb_backend_address_pool.main : name => {
      id               = pool.id
      name             = pool.name
      load_balancer_id = pool.loadbalancer_id
    }
  }
}

# Health Probe Outputs
output "health_probe_ids" {
  description = "Map of health probe names to their IDs"
  value = {
    for name, probe in azurerm_lb_probe.main : name => probe.id
  }
}

output "health_probe_names" {
  description = "List of health probe names"
  value       = [for probe in azurerm_lb_probe.main : probe.name]
}

output "health_probes" {
  description = "Map of health probes"
  value = {
    for name, probe in azurerm_lb_probe.main : name => {
      id           = probe.id
      name         = probe.name
      protocol     = probe.protocol
      port         = probe.port
      request_path = probe.request_path
    }
  }
}

# Load Balancing Rule Outputs
output "load_balancing_rule_ids" {
  description = "Map of load balancing rule names to their IDs"
  value = {
    for name, rule in azurerm_lb_rule.main : name => rule.id
  }
}

output "load_balancing_rule_names" {
  description = "List of load balancing rule names"
  value       = [for rule in azurerm_lb_rule.main : rule.name]
}

output "load_balancing_rules" {
  description = "Map of load balancing rules"
  value = {
    for name, rule in azurerm_lb_rule.main : name => {
      id                             = rule.id
      name                           = rule.name
      protocol                       = rule.protocol
      frontend_port                  = rule.frontend_port
      backend_port                   = rule.backend_port
      frontend_ip_configuration_name = rule.frontend_ip_configuration_name
    }
  }
}

# Inbound NAT Rule Outputs
output "inbound_nat_rule_ids" {
  description = "Map of inbound NAT rule names to their IDs"
  value = {
    for name, rule in azurerm_lb_nat_rule.main : name => rule.id
  }
}

output "inbound_nat_rule_names" {
  description = "List of inbound NAT rule names"
  value       = [for rule in azurerm_lb_nat_rule.main : rule.name]
}

output "inbound_nat_rules" {
  description = "Map of inbound NAT rules"
  value = {
    for name, rule in azurerm_lb_nat_rule.main : name => {
      id                             = rule.id
      name                           = rule.name
      protocol                       = rule.protocol
      frontend_port                  = rule.frontend_port
      backend_port                   = rule.backend_port
      frontend_ip_configuration_name = rule.frontend_ip_configuration_name
    }
  }
}

# Inbound NAT Pool Outputs
output "inbound_nat_pool_ids" {
  description = "Map of inbound NAT pool names to their IDs"
  value = {
    for name, pool in azurerm_lb_nat_pool.main : name => pool.id
  }
}

output "inbound_nat_pool_names" {
  description = "List of inbound NAT pool names"
  value       = [for pool in azurerm_lb_nat_pool.main : pool.name]
}

output "inbound_nat_pools" {
  description = "Map of inbound NAT pools"
  value = {
    for name, pool in azurerm_lb_nat_pool.main : name => {
      id                             = pool.id
      name                           = pool.name
      protocol                       = pool.protocol
      frontend_port_start            = pool.frontend_port_start
      frontend_port_end              = pool.frontend_port_end
      backend_port                   = pool.backend_port
      frontend_ip_configuration_name = pool.frontend_ip_configuration_name
    }
  }
}

# Outbound Rule Outputs
output "outbound_rule_ids" {
  description = "Map of outbound rule names to their IDs"
  value = {
    for name, rule in azurerm_lb_outbound_rule.main : name => rule.id
  }
}

output "outbound_rule_names" {
  description = "List of outbound rule names"
  value       = [for rule in azurerm_lb_outbound_rule.main : rule.name]
}

output "outbound_rules" {
  description = "Map of outbound rules"
  value = {
    for name, rule in azurerm_lb_outbound_rule.main : name => {
      id                      = rule.id
      name                    = rule.name
      protocol                = rule.protocol
      backend_address_pool_id = rule.backend_address_pool_id
    }
  }
}

# Complete module output for reference
output "load_balancer_module" {
  description = "Complete Load Balancer module output object"
  value = {
    load_balancer = {
      id                 = azurerm_lb.main.id
      name               = azurerm_lb.main.name
      sku                = azurerm_lb.main.sku
      private_ip_address = azurerm_lb.main.private_ip_address
    }
    public_ips = {
      for name, pip in azurerm_public_ip.main : name => {
        id         = pip.id
        ip_address = pip.ip_address
        fqdn       = pip.fqdn
      }
    }
    backend_pools = {
      for name, pool in azurerm_lb_backend_address_pool.main : name => {
        id   = pool.id
        name = pool.name
      }
    }
    health_probes = {
      for name, probe in azurerm_lb_probe.main : name => {
        id       = probe.id
        name     = probe.name
        protocol = probe.protocol
        port     = probe.port
      }
    }
    load_balancing_rules = {
      for name, rule in azurerm_lb_rule.main : name => {
        id            = rule.id
        name          = rule.name
        frontend_port = rule.frontend_port
        backend_port  = rule.backend_port
      }
    }
  }
}
