variable "prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "key_vault_uri" {
  description = "Key Vault URI for app settings"
  type        = string
}

variable "app_insights_connection_string" {
  description = "Application Insights connection string"
  type        = string
  sensitive   = true
}

variable "app_configuration_endpoint" {
  description = "Azure App Configuration endpoint for feature flags"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}