# Basic example does not require additional variables beyond the module
# This file is included for completeness and to show how variables could be customized

variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
  default     = "Development"
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "Storage-Example"
}
