locals {
  short_region            = module.short-region-lookup.short_region
  parsed_cae_id           = provider::azurerm::parse_resource_id(var.cae_resource_id)
  parsed_identity_id      = var.add_primary_identity != null ? provider::azurerm::parse_resource_id(var.add_primary_identity.id) : null
  additional_identity_ids = distinct(compact(flatten([values(var.additional_identities)[*].id])))
  app_primary_identity = var.add_primary_identity != null ? {
    id           = data.azurerm_user_assigned_identity.primary_identity[0].id
    principal_id = data.azurerm_user_assigned_identity.primary_identity[0].principal_id
    client_id    = data.azurerm_user_assigned_identity.primary_identity[0].client_id
    } : {
    id           = module.avm-res-managedidentity-userassignedidentity-app[0].resource_id
    principal_id = module.avm-res-managedidentity-userassignedidentity-app[0].principal_id
    client_id    = module.avm-res-managedidentity-userassignedidentity-app[0].client_id
  }
  kv_local_id_roles_map = var.create_app_instance_identity ? {
    "Key Vault Secrets User"     = {}
    "Key Vault Certificate User" = {}
    "Key Vault Crypto User"      = {}
  } : {}
  kv_global_id_roles_map = var.add_primary_identity != null ? {
    "Key Vault Secrets User"     = {}
    "Key Vault Certificate User" = {}
    "Key Vault Crypto User"      = {}
  } : {}
  auth_configs = var.entra_auth_config != null ? {
    # Refer to schema in auth_config.tf for structure
    entra = {
      name = "current"
      platform = {
        enabled = var.entra_auth_config.enabled
      }
      global_validation = {
        unauthenticated_client_action = "Return401"
        exclude_paths                 = ["/health"]
      }
      identity_providers = {
        azure_active_directory = {
          enabled = true
          registration = {
            open_id_issuer             = "https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}/v2.0"
            client_id                  = var.entra_auth_config.entra_app_registration_client_id
            client_secret_setting_name = "override-use-mi-fic-assertion-client-id"
          }
          validation = {
            allowed_audiences = ["api://${var.entra_auth_config.entra_app_registration_client_id}"]
            # default_authorization_policy = {
            #   allowed_applications = distinct([
            #     var.entra_auth_config.entra_app_registration_client_id,
            #     var.entra_auth_config.entra_spn_client_id,
            #     local.app_primary_identity.client_id
            #   ])
            # }
          }
        }
      }
    }
  } : {}
  entra_auth_all = {
    for auth_key, auth_config in local.auth_configs :
    auth_key => auth_config
    if try(auth_config.identity_providers.azure_active_directory.enabled, false)
  }
  # Should only be one auth config for Entra ID, but take the first one just in case
  entra_auth = length(keys(local.entra_auth_all)) > 0 ? {
    "${keys(local.entra_auth_all)[0]}" = values(local.entra_auth_all)[0]
  } : {}
}
