# TFLint Configuration for Terraform Azure Modules
# This configuration provides comprehensive linting for Azure Terraform modules

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "azurerm" {
  enabled = true
  version = "0.27.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

# General Terraform rules
rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_deprecated_index" {
  enabled = true
}

rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_standard_module_structure" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_unused_required_providers" {
  enabled = true
}

# Azure-specific rules
rule "azurerm_application_gateway_listener_https_preferred" {
  enabled = true
}

rule "azurerm_application_gateway_redirect_configuration_https_preferred" {
  enabled = true
}

rule "azurerm_cosmosdb_account_public_access_disabled" {
  enabled = true
}

rule "azurerm_key_vault_public_access_disabled" {
  enabled = true
}

rule "azurerm_kubernetes_cluster_addon_profile_oms_agent_enabled" {
  enabled = true
}

rule "azurerm_kubernetes_cluster_network_policy_enabled" {
  enabled = true
}

rule "azurerm_kubernetes_cluster_rbac_enabled" {
  enabled = true
}

rule "azurerm_mysql_server_ssl_enforcement_enabled" {
  enabled = true
}

rule "azurerm_postgresql_server_ssl_enforcement_enabled" {
  enabled = true
}

rule "azurerm_redis_cache_ssl_enabled" {
  enabled = true
}

rule "azurerm_storage_account_https_traffic_only_enabled" {
  enabled = true
}

rule "azurerm_storage_account_public_access_disabled" {
  enabled = true
}

rule "azurerm_virtual_machine_data_disk_encryption_enabled" {
  enabled = true
}

rule "azurerm_virtual_machine_disk_encryption_enabled" {
  enabled = true
}

# Disable certain rules that might be too strict for modules
rule "terraform_workspace_remote" {
  enabled = false
}
