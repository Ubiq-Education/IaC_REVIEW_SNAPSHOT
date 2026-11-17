module "avm-res-keyvault-vault" {
  source                          = "Azure/avm-res-keyvault-vault/azurerm"
  version                         = "~>0.12.0"
  enable_telemetry                = false
  name                            = local.kv_name
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  tenant_id                       = local.azure_tenant_id
  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  public_network_access_enabled   = true
  purge_protection_enabled        = true
  soft_delete_retention_days      = 90
  sku_name                        = "standard"
  tags                            = merge(var.tags, local.common_tags)

  network_acls = {
    bypass         = "AzureServices"
    default_action = "Deny"
    virtual_network_subnet_ids = distinct(compact(concat(
      [data.azurerm_subnet.vnet_integration.id],
      [for subnet in module.ubiq_resources.twingate_subnets : subnet.id],
      [for subnet in module.ubiq_resources.terraform_subnets : subnet.id],
      [for subnet in module.ubiq_resources.devops_subnets : subnet.id]
    )))
  }

  wait_for_rbac_before_secret_operations = {
    create = "60s"
  }

  wait_for_rbac_before_key_operations = {
    create = "60s"
  }

  role_assignments = {
    main_kv_sql_crypto_user = {
      role_definition_id_or_name = "Key Vault Crypto Service Encryption User"
      principal_id               = module.avm-res-managedidentity-userassignedidentity-sql.principal_id
    }
    main_kv_sqldb_crypto_user = {
      role_definition_id_or_name = "Key Vault Crypto Service Encryption User"
      principal_id               = module.avm-res-managedidentity-userassignedidentity-sqldb.principal_id
    }
    main_kv_st_crypto_user = {
      role_definition_id_or_name = "Key Vault Crypto Service Encryption User"
      principal_id               = module.avm-res-managedidentity-userassignedidentity-st.principal_id
    }
    main_kv_app_secrets_user = {
      role_definition_id_or_name = "Key Vault Secrets User"
      principal_id               = module.avm-res-managedidentity-userassignedidentity-app.principal_id
    }
  }

  secrets = merge(
    {
      sql_admin_pw = {
        name = local.sql_admin_login_secret_name
        tags = merge(var.tags, local.common_tags)
      }
      send_grid_key_prod = {
        name = data.azurerm_key_vault_secret.send_grid_key_prod.name
        tags = merge(var.tags, local.common_tags)
      }
      send_grid_key_staging = {
        name = data.azurerm_key_vault_secret.send_grid_key_staging.name
        tags = merge(var.tags, local.common_tags)
      }
      amais_dxp_staging_redis_connection_string = {
        name = local.amais_dxp_staging_redis_connection_string_key_name
        tags = merge(var.tags, local.common_tags)
      }
      site_staging_dxp_api_key = {
        name = local.site_staging_dxp_api_key_name
        tags = merge(var.tags, local.common_tags)
      }
      amais_dxp_production_redis_connection_string = {
        name = local.amais_dxp_production_redis_connection_string_key_name
        tags = merge(var.tags, local.common_tags)
      }
      site_production_dxp_api_key = {
        name = local.site_production_dxp_api_key_name
        tags = merge(var.tags, local.common_tags)
      }
      stripeapikey_production = {
        name = "StripeAPIKey-Production"
        tags = merge(var.tags, local.common_tags)
      }
      stripeapikey_test = {
        name = "StripeAPIKey-Test"
        tags = merge(var.tags, local.common_tags)
      }
      stripepublickey_production = {
        name = "StripePublicKey-Production"
        tags = merge(var.tags, local.common_tags)
      }
      stripepublickey_test = {
        name = "StripePublicKey-Test"
        tags = merge(var.tags, local.common_tags)
      }
      ckeditor_apikey_prod = {
        name = data.azurerm_key_vault_secret.ckeditor_apikey_prod.name
        tags = merge(var.tags, local.common_tags)
      }
      ckeditor_secretkey_prod = {
        name = data.azurerm_key_vault_secret.ckeditor_secretkey_prod.name
        tags = merge(var.tags, local.common_tags)
      }
      ckeditor_apikey_staging = {
        name = data.azurerm_key_vault_secret.ckeditor_apikey_staging.name
        tags = merge(var.tags, local.common_tags)
      }
      ckeditor_secretkey_staging = {
        name = data.azurerm_key_vault_secret.ckeditor_secretkey_staging.name
        tags = merge(var.tags, local.common_tags)
      }
      zendesk_jwt_shared_key = {
        name = data.azurerm_key_vault_secret.zendesk_jwt_shared_key.name
        tags = merge(var.tags, local.common_tags)
      }
      google_fonts_shared_key = {
        name = "google-fonts-api-key"
        tags = merge(var.tags, local.common_tags)
      }
    },
    local.kv_custom_send_grid_key_prod_sk,
    local.kv_custom_send_grid_key_staging_sk,
    local.kv_authorize_net_sk,
    local.kv_blackbaud_oauth_settings_apikey_sk,
    local.kv_blackbaud_sk,
    local.kv_veracross_sk,
    local.kv_gg4l_sk,
    local.kv_gg4l_directory_synch_sk,
    local.dxp_auth0_client_staging_sk,
    local.dxp_auth0_client_production_sk,
    local.kv_bunnynet_api_key_sk,
    local.kv_ubiq_shortener_api_key_sk,
    local.kv_ubiq_captcha_site_key_sk,
    local.kv_ubiq_sendgrid_events_site_key_sk
  )

  secrets_value = merge(
    {
      sql_admin_pw                              = random_password.sql_admin.result
      send_grid_key_prod                        = data.azurerm_key_vault_secret.send_grid_key_prod.value
      send_grid_key_staging                     = data.azurerm_key_vault_secret.send_grid_key_staging.value
      amais_dxp_staging_redis_connection_string = local.redis_connection_string
      site_staging_dxp_api_key = (
        var.enable_dxp_integration_staging && var.dev_site != "no"
        ? data.azurerm_key_vault_secret.site_staging_dxp_api_key[0].value
        : "secret-will-be-populated-when-dxp-integration-enabled"
      )
      amais_dxp_production_redis_connection_string = local.redis_connection_string
      site_production_dxp_api_key = (
        var.enable_dxp_integration_production
        ? data.azurerm_key_vault_secret.site_production_dxp_api_key[0].value
        : "secret-will-be-populated-when-dxp-integration-enabled"
      )
      stripeapikey_production    = data.azurerm_key_vault_secret.stripeapikey_production.value
      stripeapikey_test          = data.azurerm_key_vault_secret.stripeapikey_test.value
      stripepublickey_production = data.azurerm_key_vault_secret.stripepublickey_production.value
      stripepublickey_test       = data.azurerm_key_vault_secret.stripepublickey_test.value
      ckeditor_apikey_prod       = data.azurerm_key_vault_secret.ckeditor_apikey_prod.value
      ckeditor_secretkey_prod    = data.azurerm_key_vault_secret.ckeditor_secretkey_prod.value
      ckeditor_apikey_staging    = data.azurerm_key_vault_secret.ckeditor_apikey_staging.value
      ckeditor_secretkey_staging = data.azurerm_key_vault_secret.ckeditor_secretkey_staging.value
      zendesk_jwt_shared_key     = data.azurerm_key_vault_secret.zendesk_jwt_shared_key.value
      google_fonts_shared_key    = data.azurerm_key_vault_secret.google_fonts_shared_key.value
    },
    local.kv_custom_send_grid_key_prod_sv,
    local.kv_custom_send_grid_key_staging_sv,
    local.kv_authorize_net_sv,
    local.kv_blackbaud_oauth_settings_apikey_sv,
    local.kv_blackbaud_sv,
    local.kv_veracross_sv,
    local.kv_gg4l_sv,
    local.kv_gg4l_directory_synch_sv,
    local.dxp_auth0_client_staging_sv,
    local.dxp_auth0_client_production_sv,
    local.kv_bunnynet_api_key_sv,
    local.kv_ubiq_shortener_api_key_sv,
    local.kv_ubiq_captcha_site_key_sv,
    local.kv_ubiq_sendgrid_events_site_key_sv
  )
}
