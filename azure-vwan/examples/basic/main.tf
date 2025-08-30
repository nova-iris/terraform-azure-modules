# Basic Azure Virtual WAN Example
# This example creates a simple Virtual WAN with one virtual hub

module "basic_vwan" {
  source = "../.."

  name                = "basic-vwan"
  location            = "East US"
  resource_group_name = "basic-vwan-rg"
  wan_type            = "Standard"

  # Azure naming convention configuration
  naming_convention = {
    prefix = ["basic"]
    suffix = ["001"]
  }

  virtual_hubs = [
    {
      name           = "hub-eastus"
      location       = "East US"
      address_prefix = "10.0.0.0/23"

      # Basic VPN Gateway
      vpn_gateway = {
        enable     = true
        scale_unit = 1
      }
    }
  ]

  tags = {
    Environment = "dev"
    Project     = "basic-vwan-test"
    CostCenter  = "IT-Dev"
  }
}

# Outputs
output "vwan_id" {
  description = "ID of the Virtual WAN"
  value       = module.basic_vwan.vwan_id
}

output "virtual_hub_ids" {
  description = "Virtual Hub IDs"
  value       = module.basic_vwan.virtual_hub_ids
}

output "vpn_gateway_ids" {
  description = "VPN Gateway IDs"
  value       = module.basic_vwan.vpn_gateway_ids
}
