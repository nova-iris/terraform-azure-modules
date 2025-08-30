# Variables for multi-hub VWAN example

variable "primary_location" {
  description = "Primary Azure region"
  type        = string
  default     = "East US"
}

variable "secondary_location" {
  description = "Secondary Azure region"
  type        = string
  default     = "West US"
}

variable "tertiary_location" {
  description = "Tertiary Azure region"
  type        = string
  default     = "West Europe"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "global-connectivity"
}
