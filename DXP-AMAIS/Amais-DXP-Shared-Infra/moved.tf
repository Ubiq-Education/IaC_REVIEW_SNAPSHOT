moved {
  from = azurerm_management_lock.main_kv_uk
  to   = module.dxp_keyvault_uk.azurerm_management_lock.main
}

moved {
  from = azurerm_management_lock.main_kv_us
  to   = module.dxp_keyvault_us.azurerm_management_lock.main
}

moved {
  from = azurerm_monitor_diagnostic_setting.main_kv_uk
  to   = module.dxp_keyvault_uk.azurerm_monitor_diagnostic_setting.main
}

moved {
  from = azurerm_monitor_diagnostic_setting.main_kv_us
  to   = module.dxp_keyvault_us.azurerm_monitor_diagnostic_setting.main
}

moved {
  from = module.avm-res-keyvault-vault-uk.azurerm_key_vault.this
  to   = module.dxp_keyvault_uk.module.avm-res-keyvault-vault.azurerm_key_vault.this
}

moved {
  from = module.avm-res-keyvault-vault-uk.azurerm_role_assignment.this["main_kv_tf_crypto_officer"]
  to   = module.dxp_keyvault_uk.module.avm-res-keyvault-vault.azurerm_role_assignment.this["main_kv_tf_crypto_officer"]
}

moved {
  from = module.avm-res-keyvault-vault-uk.azurerm_role_assignment.this["main_kv_tf_secrets_officer"]
  to   = module.dxp_keyvault_uk.module.avm-res-keyvault-vault.azurerm_role_assignment.this["main_kv_tf_secrets_officer"]
}

moved {
  from = module.avm-res-keyvault-vault-us.azurerm_key_vault.this
  to   = module.dxp_keyvault_us.module.avm-res-keyvault-vault.azurerm_key_vault.this
}

moved {
  from = module.avm-res-keyvault-vault-us.azurerm_role_assignment.this["main_kv_tf_crypto_officer"]
  to   = module.dxp_keyvault_us.module.avm-res-keyvault-vault.azurerm_role_assignment.this["main_kv_tf_crypto_officer"]
}

moved {
  from = module.avm-res-keyvault-vault-us.azurerm_role_assignment.this["main_kv_tf_secrets_officer"]
  to   = module.dxp_keyvault_us.module.avm-res-keyvault-vault.azurerm_role_assignment.this["main_kv_tf_secrets_officer"]
}
