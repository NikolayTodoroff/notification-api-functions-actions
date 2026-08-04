output "function_app_id" {
  description = "Function App resource ID"
  value       = azurerm_linux_function_app.function_app.id
}

output "function_app_name" {
  description = "Function App name"
  value       = azurerm_linux_function_app.function_app.name
}

output "function_app_principal_id" {
  description = "Function App system-assigned managed identity principal ID"
  value       = azurerm_linux_function_app.function_app.identity[0].principal_id
}

output "function_app_default_hostname" {
  description = "Default hostname of the Function App"
  value       = azurerm_linux_function_app.function_app.default_hostname
}