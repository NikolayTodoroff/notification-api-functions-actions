resource "azurerm_storage_account" "function_storage" {
  name                     = "st${replace(var.prefix, "-", "")}func"
  resource_group_name     = var.resource_group_name
  location                = var.location
  account_tier            = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                      = var.tags
}

resource "azurerm_service_plan" "function_plan" {
  name                = "asp-${var.prefix}-func"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "Y1"
  tags                = var.tags
}

resource "azurerm_linux_function_app" "function_app" {
  name                = "func-${var.prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location

  storage_account_name       = azurerm_storage_account.function_storage.name
  storage_account_access_key = azurerm_storage_account.function_storage.primary_access_key
  service_plan_id            = azurerm_service_plan.function_plan.id

  https_only = true
  tags       = var.tags

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      dotnet_version              = "8.0"
      use_dotnet_isolated_runtime = true
    }
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"               = "dotnet-isolated"
    "APPLICATIONINSIGHTS_CONNECTION_STRING"  = var.app_insights_connection_string
    "KeyVaultUri"                            = var.key_vault_uri
    "AppConfigEndpoint"                      = var.app_configuration_endpoint
  }
}