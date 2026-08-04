# Workflow SP — needs Key Vault Administrator during terraform apply
resource "azurerm_role_assignment" "kv_workflow_sp" {
  scope                = module.key_vault.key_vault_id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.workflow_sp_object_id
}

# Function App MI — needs to read secrets at runtime
resource "azurerm_role_assignment" "kv_function_secrets_user" {
  scope                = module.key_vault.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.function_app.function_app_principal_id
}

# Function App MI — needs to read feature flags at runtime
resource "azurerm_role_assignment" "function_app_config_reader" {
  scope                = module.app_configuration.app_configuration_id
  role_definition_name = "App Configuration Data Reader"
  principal_id         = module.function_app.function_app_principal_id
}