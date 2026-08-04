output "app_configuration_id" {
  description = "App Configuration resource ID"
  value       = azurerm_app_configuration.config.id
}

output "app_configuration_endpoint" {
  description = "App Configuration endpoint URL"
  value       = azurerm_app_configuration.config.endpoint
}