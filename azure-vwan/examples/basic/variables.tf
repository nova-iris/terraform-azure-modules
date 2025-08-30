# Variables for basic VWAN example

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "basic-vwan-rg"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
