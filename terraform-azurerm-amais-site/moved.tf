### Web app resources moved from non-count to count-indexed resources

moved {
  from = azurerm_windows_web_app.main
  to   = azurerm_windows_web_app.main[0]
}

moved {
  from = azapi_update_resource.main_webapp_properties
  to   = azapi_update_resource.main_webapp_properties[0]
}

### SQL firewall rules moved from count-indexed resources to for_each resources

moved {
  from = azurerm_mssql_firewall_rule.main_secure_access_gw[0]
  to   = azurerm_mssql_firewall_rule.main_secure_access_gw["pip-ng-uks-hub-01-01"]
}

moved {
  from = azurerm_mssql_firewall_rule.main_secure_access_gw[1]
  to   = azurerm_mssql_firewall_rule.main_secure_access_gw["pip-ng-inc-hub-01-01"]
}

### Remove old public container but leave existing resources
removed {
  from = module.avm-res-storage-storageaccount.azapi_resource.containers
  lifecycle {
    destroy = false
  }
}

### Stage migration for Azure/avm-res-storage-storageaccount/azurerm module update to 0.7.0
moved {
  from = module.avm-res-storage-storageaccount.azapi_resource.containers["main_priv"]
  to   = module.avm-res-storage-storageaccount.module.containers["main_priv"].azapi_resource.this
}

moved {
  from = module.avm-res-storage-storageaccount.azurerm_role_assignment.storage_account["main_st_app_blob_contributor"]
  to   = azurerm_role_assignment.main_st_app_blob_contributor
}

moved {
  from = module.avm-res-storage-storageaccount.azurerm_role_assignment.storage_account["main_st_sql_blob_contributor"]
  to   = azurerm_role_assignment.main_st_sql_blob_contributor
}

moved {
  from = module.avm-res-storage-storageaccount.azurerm_storage_account_customer_managed_key.this[0]
  to   = azurerm_storage_account_customer_managed_key.main
}
