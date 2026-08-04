output "function_app_name" {
  description = "Function App name"
  value       = module.function_app.function_app_name
}

output "function_app_url" {
  description = "Function App default hostname"
  value       = "https://${module.function_app.function_app_default_hostname}"
}

output "key_vault_name" {
  description = "Key Vault name"
  value       = module.key_vault.key_vault_name
}

output "app_configuration_endpoint" {
  description = "App Configuration endpoint"
  value       = module.app_configuration.app_configuration_endpoint
}

output "app_insights_connection_string" {
  description = "Application Insights connection string"
  value       = module.monitoring.app_insights_connection_string
  sensitive   = true
}