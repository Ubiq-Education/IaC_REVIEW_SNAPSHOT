resource "azurerm_role_assignment" "kv_secret_user" {
  for_each = var.kv_secret_user_principal_ids

  scope                = module.avm-res-keyvault-vault.resource_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "kv_certificate_user" {
  for_each = var.kv_certificate_user_principal_ids

  scope                = module.avm-res-keyvault-vault.resource_id
  role_definition_name = "Key Vault Certificate User"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "kv_crypto_service_encryption_user" {
  for_each = var.kv_crypto_service_encryption_user_principal_ids

  scope                = module.avm-res-keyvault-vault.resource_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = each.value
}

resource "time_sleep" "azurerm_role_assignments" {
  create_duration = "60s"

  triggers = {
    for ra in concat(
      values(azurerm_role_assignment.kv_secret_user),
      values(azurerm_role_assignment.kv_certificate_user),
      values(azurerm_role_assignment.kv_crypto_service_encryption_user)
    ) : ra.id => ra.id
  }
}
