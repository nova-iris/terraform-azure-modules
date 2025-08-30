# Azure Service Principal Configuration
variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Azure tenant ID"
  type        = string
}

variable "client_id" {
  description = "Azure service principal client ID"
  type        = string
}

variable "client_secret" {
  description = "Azure service principal client secret"
  type        = string
  sensitive   = true
}

# ================================================================== #

# Hub Resource Group Configuration
variable "hub_resource_group_name" {
  description = "Name of the hub resource group"
  type        = string
}

variable "hub_location" {
  description = "Azure region for hub resources"
  type        = string
  default     = "eastus"
}

# Spoke 1 Resource Group Configuration
variable "spoke1_resource_group_name" {
  description = "Name of the spoke1 resource group"
  type        = string
}

variable "spoke1_location" {
  description = "Azure region for spoke1 resources"
  type        = string
  default     = "eastus"
}

# Spoke 2 Resource Group Configuration
variable "spoke2_resource_group_name" {
  description = "Name of the spoke2 resource group"
  type        = string
}

variable "spoke2_location" {
  description = "Azure region for spoke2 resources"
  type        = string
  default     = "eastus"
}
