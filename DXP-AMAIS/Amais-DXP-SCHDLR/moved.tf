# TODO: Remove after resources have been moved
moved {
  from = module.avm-res-managedidentity-userassignedidentity-app.azurerm_user_assigned_identity.this
  to   = module.dxp-appservice.module.avm-res-managedidentity-userassignedidentity-app.azurerm_user_assigned_identity.this
}

moved {
  from = module.avm-res-managedidentity-userassignedidentity-app.azurerm_management_lock.this[0]
  to   = module.dxp-appservice.module.avm-res-managedidentity-userassignedidentity-app.azurerm_management_lock.this[0]
}

moved {
  from = module.avm-res-managedidentity-userassignedidentity-app-staging.azurerm_user_assigned_identity.this
  to   = module.dxp-appservice.module.avm-res-managedidentity-userassignedidentity-app-staging.azurerm_user_assigned_identity.this
}

moved {
  from = module.avm-res-managedidentity-userassignedidentity-app-staging.azurerm_management_lock.this[0]
  to   = module.dxp-appservice.module.avm-res-managedidentity-userassignedidentity-app-staging.azurerm_management_lock.this[0]
}

moved {
  from = azurerm_role_assignment.main_kv_app_secret_user
  to   = module.dxp-appservice.azurerm_role_assignment.shared_kv_app_secret_user
}

moved {
  from = azurerm_role_assignment.main_kv_app_secret_user_staging
  to   = module.dxp-appservice.azurerm_role_assignment.shared_kv_app_secret_user_staging
}

moved {
  from = azurerm_windows_web_app.main
  to   = module.dxp-appservice.azurerm_windows_web_app.main
}

moved {
  from = azapi_update_resource.main_webapp_properties
  to   = module.dxp-appservice.azapi_update_resource.main_webapp_properties
}

moved {
  from = azurerm_monitor_diagnostic_setting.main_webapp
  to   = module.dxp-appservice.azurerm_monitor_diagnostic_setting.main_webapp
}

moved {
  from = azurerm_windows_web_app_slot.main_staging
  to   = module.dxp-appservice.azurerm_windows_web_app_slot.main_staging
}

moved {
  from = azapi_update_resource.main_webapp_staging_properties
  to   = module.dxp-appservice.azapi_update_resource.main_webapp_staging_properties
}

moved {
  from = azurerm_monitor_diagnostic_setting.main_webapp_staging
  to   = module.dxp-appservice.azurerm_monitor_diagnostic_setting.main_webapp_staging
}
