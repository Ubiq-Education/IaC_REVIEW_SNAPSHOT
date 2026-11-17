resource "azurerm_role_assignment" "app_additional_roles" {
  for_each = var.app_identity_roles_production

  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = module.avm-res-managedidentity-userassignedidentity-app.principal_id
}

resource "azurerm_role_assignment" "app_additional_roles_staging" {
  for_each = var.app_identity_roles_staging

  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = module.avm-res-managedidentity-userassignedidentity-app-staging.principal_id
}

resource "azurerm_role_assignment" "main_kv_app_secret_user" {
  scope                = data.azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.avm-res-managedidentity-userassignedidentity-app.principal_id
  depends_on           = [time_sleep.azurerm_managedidentity_all]
}

resource "azurerm_role_assignment" "main_kv_app_secret_user_staging" {
  scope                = data.azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.avm-res-managedidentity-userassignedidentity-app-staging.principal_id
  depends_on           = [time_sleep.azurerm_managedidentity_all]
}

resource "azurerm_role_assignment" "shared_kv_app_secret_user" {
  scope                = data.azurerm_key_vault.shared.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.avm-res-managedidentity-userassignedidentity-app.principal_id
  depends_on           = [time_sleep.azurerm_managedidentity_all]
}

resource "azurerm_role_assignment" "shared_kv_app_secret_user_staging" {
  scope                = data.azurerm_key_vault.shared.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.avm-res-managedidentity-userassignedidentity-app-staging.principal_id
  depends_on           = [time_sleep.azurerm_managedidentity_all]
}

resource "time_sleep" "azurerm_roles_all" {
  create_duration = "60s"

  triggers = {
    app_kv                = azurerm_role_assignment.main_kv_app_secret_user.id
    app_kv_staging        = azurerm_role_assignment.main_kv_app_secret_user_staging.id
    app_shared_kv         = azurerm_role_assignment.shared_kv_app_secret_user.id
    app_shared_kv_staging = azurerm_role_assignment.shared_kv_app_secret_user_staging.id
  }
}

resource "azuread_app_role_assignment" "dxp_client_staging" {
  for_each = local.dxp_api_roles_staging

  app_role_id         = each.value.app_role_id
  principal_object_id = each.value.app_principal_object_id
  resource_object_id  = each.value.resource_object_id
}

resource "azuread_app_role_assignment" "dxp_client_prod" {
  for_each = local.dxp_api_roles_prod

  app_role_id         = each.value.app_role_id
  principal_object_id = each.value.app_principal_object_id
  resource_object_id  = each.value.resource_object_id
}
