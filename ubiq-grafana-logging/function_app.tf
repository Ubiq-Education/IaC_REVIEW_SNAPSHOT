module "function-app-flex" {
  for_each = local.regions

  providers                       = { azurerm = azurerm, azurerm.shared = azurerm.shared }
  source                          = "api.controlmonkey.io/o-26drsisx9g/function-app-flex/azurerm"
  version                         = "~>3.0"
  az_long_region                  = azurerm_resource_group.main[each.key].location
  resource_group_id               = azurerm_resource_group.main[each.key].id
  sp_zone_balancing_enabled       = false
  function_app_name               = "func-${module.short-region-lookup[each.key].short_region}-grafana-forwarder-01-${var.environment}"
  function_app_subnet_id          = data.azurerm_subnet.amais_central_functions_05[each.key].id
  function_app_runtime            = { name = "python", version = "3.13" }
  function_app_max_instance_count = 200
  function_app_identity_roles = {
    eventhub_receiver = {
      scope                = module.eventhub[each.key].azurerm_eventhub_namespace.id
      role_definition_name = "Azure Event Hubs Data Receiver"
    }
  }
  function_app_ip_restrictions     = local.all_ip_restrictions
  function_app_scm_ip_restrictions = local.all_scm_ip_restrictions
  function_app_environment_variables = [
    {
      name  = "EVENTHUB_NAME"
      value = "evh-logevents"
    },
    {
      name  = "LOKI_ENDPOINT"
      value = "https://logs-prod-013.grafana.net/loki/api/v1/push"
    },
    {
      name  = "LOKI_USERNAME"
      value = "1390556"
    },
    {
      name  = "LOKI_PASSWORD"
      value = "@Microsoft.KeyVault(VaultName=${module.avm-res-keyvault-vault[each.key].name};SecretName=loki-password)"
    }
  ]
  function_app_eventhub_connection = {
    enabled               = true
    eventhub_namespace_id = module.eventhub[each.key].azurerm_eventhub_namespace.id
  }
  additional_storage_account_allowed_subnet_ids = [
    data.azurerm_subnet.hub_centralindia_tg.id,
    data.azurerm_subnet.hub_uksouth_tg.id,
    data.azurerm_subnet.hub_uksouth_tf.id,
    data.azurerm_subnet.hub_uksouth_devops_01.id,
    data.azurerm_subnet.hub_uksouth_devops_02.id
  ]
  key_vault_id               = module.avm-res-keyvault-vault[each.key].resource_id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.shared.id
  diagnostics_destinations = {
    log_analytics = { enabled = true }
  }
  storage_account_diagnostics_enabled                   = false
  function_app_application_insights_tracing_enabled     = false
  function_app_diagnostics_max_failures_alert_enabled   = false
  function_app_diagnostics_max_failures_threshold       = 5
  function_app_diagnostics_max_inactivity_alert_enabled = var.environment != "staging" ? true : false
  tags                                                  = local.tags
}
