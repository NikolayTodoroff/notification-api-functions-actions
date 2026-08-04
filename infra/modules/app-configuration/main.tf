data "azurerm_client_config" "current" {}

resource "azurerm_app_configuration" "config" {
  name                = "appcs-${var.prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "free"
  local_auth_enabled  = false
  tags                = var.tags
}

resource "azurerm_role_assignment" "config_data_owner" {
  scope                = azurerm_app_configuration.config.id
  role_definition_name = "App Configuration Data Owner"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_app_configuration_feature" "priority_routing" {
  configuration_store_id = azurerm_app_configuration.config.id
  name                    = "EnablePriorityRouting"
  label                   = "notification-api"
  enabled                 = true

  depends_on = [azurerm_role_assignment.config_data_owner]
}