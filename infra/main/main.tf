data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg_main" {
  name     = "rg-main-${local.prefix}"
  location = var.location

  lifecycle {
    prevent_destroy = true
  }
}

module "key_vault" {
  source = "../modules/key-vault"

  prefix              = local.prefix
  resource_group_name = azurerm_resource_group.rg_main.name
  location            = azurerm_resource_group.rg_main.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  tags                = local.common_tags
}

module "monitoring" {
  source = "../modules/monitoring"

  prefix                       = local.prefix
  resource_group_name          = azurerm_resource_group.rg_main.name
  location                     = azurerm_resource_group.rg_main.location
  log_analytics_sku            = var.log_analytics_sku
  log_analytics_retention_days = var.log_analytics_retention_days
  tags                         = local.common_tags
}

module "app_configuration" {
  source = "../modules/app-configuration"

  prefix              = local.prefix
  resource_group_name = azurerm_resource_group.rg_main.name
  location            = azurerm_resource_group.rg_main.location
  tags                = local.common_tags
}

module "function_app" {
  source = "../modules/function-app"

  prefix              = local.prefix
  resource_group_name = azurerm_resource_group.rg_main.name
  location            = azurerm_resource_group.rg_main.location

  key_vault_uri                   = module.key_vault.key_vault_uri
  app_insights_connection_string  = module.monitoring.app_insights_connection_string
  app_configuration_endpoint      = module.app_configuration.app_configuration_endpoint

  tags = local.common_tags
}