# Variables for existing WAN example

variable "existing_wan_id" {
  description = "ID of the existing Virtual WAN"
  type        = string
  default     = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/central-wan-rg/providers/Microsoft.Network/virtualWans/corporate-wan"
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  default     = "12345678-1234-1234-1234-123456789012"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}
