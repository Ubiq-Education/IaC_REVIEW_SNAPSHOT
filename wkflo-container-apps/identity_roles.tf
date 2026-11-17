# Global identity for use by this container app, to be used for all regional instances if additional regions added in the future.
module "avm-res-managedidentity-userassignedidentity-app" {
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3"
  enable_telemetry    = false
  name                = "id-${local.app_name}"
  resource_group_name = var.cae[var.azure_long_region].global_resource_group_name
  location            = var.azure_long_region
  tags                = local.tags
}

resource "time_sleep" "identities" {
  create_duration = "60s"

  triggers = {
    identity_principal_id = module.avm-res-managedidentity-userassignedidentity-app.principal_id
  }
}

resource "azurerm_role_assignment" "additional_container_identity_roles" {
  for_each = merge(
    {
      pum_eventhub_sender = {
        scope                = var.environment == "prod" ? module.ubiq_resources.pum.prod.resource_id : module.ubiq_resources.pum.staging.resource_id
        role_definition_name = "Azure Event Hubs Data Sender"
      }
    },
    var.central_key_vault_key_access_enabled ? {
      key_vault_crypto_service_encryption_user = {
        scope                = data.azurerm_key_vault.central.id
        role_definition_name = "Key Vault Crypto User"
      }
    } : {},
    var.central_key_vault_secret_access_enabled ? {
      key_vault_secret_user = {
        scope                = data.azurerm_key_vault.central.id
        role_definition_name = "Key Vault Secrets User"
      }
    } : {},
    var.blob_storage_connection_enabled ? {
      blob_storage_contributor = {
        scope                = local.cae_storeage_account.id
        role_definition_name = "Storage Blob Data Contributor"
      }
    } : {},
    var.signalr_connection_enabled ? {
      signalr_rest_api_owner = {
        scope                = local.signalr_resource.id
        role_definition_name = "SignalR REST API Owner"
      },
      signalr_app_server = {
        scope                = local.signalr_resource.id
        role_definition_name = "SignalR App Server"
      }
    } : {},
    var.azure_ai_model_access_enabled ? local.flat_ai_sub_roles : {}
  )

  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = module.avm-res-managedidentity-userassignedidentity-app.principal_id

  depends_on = [time_sleep.identities]
}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "app" {
  count = var.postgres_vector_db_connection_enabled ? 1 : 0

  server_name         = local.cae_postgresql_resource.name
  resource_group_name = provider::azurerm::parse_resource_id(local.cae_postgresql_resource.id)["resource_group_name"]
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = module.avm-res-managedidentity-userassignedidentity-app.principal_id
  principal_name      = module.avm-res-managedidentity-userassignedidentity-app.resource_name
  principal_type      = "ServicePrincipal"

  depends_on = [time_sleep.identities]
}

resource "azuread_group_member" "sql_rw" {
  count = var.wkflo_sql_db_connection_enabled ? 1 : 0

  group_object_id  = data.azuread_group.sql_rw.object_id
  member_object_id = module.avm-res-managedidentity-userassignedidentity-app.principal_id
  depends_on       = [time_sleep.identities]
}
