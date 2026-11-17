data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

data "azuread_group" "sql_admins" {
  display_name     = "Azure-RBAC-SQL-Admins"
  security_enabled = true
}

data "azuread_group" "entra_dir_r" {
  display_name     = "Entra-RBAC-SQL-Directory-Readers"
  security_enabled = true
}

data "azuread_group" "amais_sql_rw" {
  display_name     = "Amais-SQL-RBAC-site-identities-RW"
  security_enabled = true
}

data "azuread_group" "amais_app_umi" {
  display_name     = "Azure-RBAC-AMAIS-App-UMI"
  security_enabled = true
}

data "azurerm_storage_account" "uks_dxp" {
  provider            = azurerm.shared
  name                = "amaisdxp"
  resource_group_name = "Amais-DXP"
}

data "azurerm_mssql_server" "central_amais" {
  provider            = azurerm.shared
  name                = "amais"
  resource_group_name = "Amais"
}

data "azurerm_key_vault" "shared" {
  provider            = azurerm.shared
  name                = "kv-uks-ubiq-shared-res"
  resource_group_name = "rg-uks-ubiq-shared-res"
}

data "azurerm_key_vault_secret" "ckeditor_apikey_prod" {
  name         = "ckeditor-apikey-production"
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "ckeditor_secretkey_prod" {
  name         = "ckeditor-secretkey-production"
  key_vault_id = data.azurerm_key_vault.shared.id
}

# Local development captcha values (dev config blob only)
data "azurerm_key_vault_secret" "devconfig_ubiq_captcha" {
  for_each = toset([
    "DEVCONFIG-UBIQ-CAPTCHA-API-ENDPOINT",
    "DEVCONFIG-UBIQ-CAPTCHA-SITEVERIFY-URL",
    "DEVCONFIG-UBIQ-CAPTCHA-SITE-KEY",
  ])
  name         = each.key
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "ckeditor_apikey_staging" {
  name         = "ckeditor-apikey-staging"
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "ckeditor_secretkey_staging" {
  name         = "ckeditor-secretkey-staging"
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "zendesk_jwt_shared_key" {
  name         = "zendesk-jwt-shared-key"
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "google_fonts_shared_key" {
  name         = "amais-google-fonts-api-key"
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "send_grid_key_prod" {
  name         = "send-grid-key-prod"
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "send_grid_key_staging" {
  name         = "send-grid-key-staging"
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "oauth_blackbaud_client_id" {
  name         = "oauth-blackbaud-client-id"
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "oauth_blackbaud_client_secret" {
  name         = "oauth-blackbaud-client-secret"
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "oauth_blackbaud_subscription_key" {
  name         = "oauth-blackbaud-subscription-key"
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "amais_dxp_staging_masterdataclientoauthsettings_clientid" {
  count        = var.enable_entra_dxp_client_staging ? 0 : 1
  name         = "amais-dxp-staging-masterdataclientoauthsettings-clientid"
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "amais_dxp_staging_reportclientoauthsettings_clientsecret" {
  count        = var.enable_entra_dxp_client_staging ? 0 : 1
  name         = "amais-dxp-staging-reportclientoauthsettings-clientsecret"
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "amais_dxp_staging_reportclientoauthsettings_clientid" {
  count        = var.enable_entra_dxp_client_staging ? 0 : 1
  name         = "amais-dxp-staging-reportclientoauthsettings-clientid"
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "amais_dxp_staging_masterdataclientoauthsettings_clientsecret" {
  count        = var.enable_entra_dxp_client_staging ? 0 : 1
  name         = "amais-dxp-staging-masterdataclientoauthsettings-clientsecret"
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "amais_dxp_staging_ingressclientoauthsettings_clientsecret" {
  count        = var.enable_entra_dxp_client_staging ? 0 : 1
  name         = "amais-dxp-staging-ingressclientoauthsettings-clientsecret"
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "amais_dxp_staging_ingressclientoauthsettings_clientid" {
  count        = var.enable_entra_dxp_client_staging ? 0 : 1
  name         = "amais-dxp-staging-ingressclientoauthsettings-clientid"
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "amais_dxp_staging_aiclientoauthsettings_clientid" {
  count        = var.enable_entra_dxp_client_staging ? 0 : 1
  name         = "amais-dxp-staging-aiclientoauthsettings-clientid"
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "amais_dxp_staging_aiclientoauthsettings_clientsecret" {
  count        = var.enable_entra_dxp_client_staging ? 0 : 1
  name         = "amais-dxp-staging-aiclientoauthsettings-clientsecret"
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "site_staging_dxp_api_key" {
  count        = var.enable_dxp_integration_staging && var.dev_site != "no" ? 1 : 0
  name         = local.site_staging_dxp_api_key_name
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "amais_dxp_production_masterdataclientoauthsettings_clientid" {
  count        = var.enable_entra_dxp_client_production ? 0 : 1
  name         = "amais-dxp-production-masterdataclientoauthsettings-clientid"
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "amais_dxp_production_reportclientoauthsettings_clientsecret" {
  count        = var.enable_entra_dxp_client_production ? 0 : 1
  name         = "amais-dxp-production-reportclientoauthsettings-clientsecret"
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "amais_dxp_production_reportclientoauthsettings_clientid" {
  count        = var.enable_entra_dxp_client_production ? 0 : 1
  name         = "amais-dxp-production-reportclientoauthsettings-clientid"
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "amais_dxp_production_masterdataclientoauthsettings_clientsecret" {
  count        = var.enable_entra_dxp_client_production ? 0 : 1
  name         = "amais-dxp-production-masterdataclientoauthsettings-clientsecret"
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "amais_dxp_production_ingressclientoauthsettings_clientsecret" {
  count        = var.enable_entra_dxp_client_production ? 0 : 1
  name         = "amais-dxp-production-ingressclientoauthsettings-clientsecret"
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "amais_dxp_production_ingressclientoauthsettings_clientid" {
  count        = var.enable_entra_dxp_client_production ? 0 : 1
  name         = "amais-dxp-production-ingressclientoauthsettings-clientid"
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "amais_dxp_production_aiclientoauthsettings_clientid" {
  count        = var.enable_entra_dxp_client_production ? 0 : 1
  name         = "amais-dxp-production-aiclientoauthsettings-clientid"
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "amais_dxp_production_aiclientoauthsettings_clientsecret" {
  count        = var.enable_entra_dxp_client_production ? 0 : 1
  name         = "amais-dxp-production-aiclientoauthsettings-clientsecret"
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "site_production_dxp_api_key" {
  count        = var.enable_dxp_integration_production ? 1 : 0
  name         = local.site_production_dxp_api_key_name
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "stripeapikey_production" {
  name         = local.stripe_region_key_names.api_key.production
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "stripeapikey_test" {
  name         = local.stripe_region_key_names.api_key.test
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "stripepublickey_production" {
  name         = local.stripe_region_key_names.public_key.production
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "stripepublickey_test" {
  name         = local.stripe_region_key_names.public_key.test
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "bunnynet_api_key" {
  count        = var.bunny_cdn_enablement == "yes" ? 1 : 0
  name         = "bunnynet-api-key"
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "ubiq_shortener_api_key" {
  for_each     = local.shortener_environments
  name         = "shortener-${each.key}-api-key-${var.ubiq_shortener_api_key_selection}"
  key_vault_id = data.azurerm_key_vault.shared.id
}

# Admin keys for the restful.captcha_* and restful.sendgrid_events_* providers only.
# Deliberately NOT gated by the enabled environments: switching a feature or slot off destroys its registration in the
# same plan, and the destroy hook needs the key. A gated lookup disappears in that plan, the provider's try() falls
# back to "" and the authenticated DELETE fails. All four secrets are permanent in the shared Ubiq Key Vault.
data "azurerm_key_vault_secret" "ubiq_captcha_admin_key" {
  for_each     = toset(["prod", "staging"])
  name         = "cap-${each.key}-admin-key-${var.ubiq_captcha_admin_key_selection}"
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_secret" "ubiq_sendgrid_events_admin_key" {
  for_each     = toset(["prod", "staging"])
  name         = "sgevents-${each.key}-admin-key-${var.ubiq_sendgrid_events_admin_key_selection}"
  key_vault_id = data.azurerm_key_vault.shared.id
}

data "azurerm_key_vault_key" "main_sql" {
  name         = "sql-${local.formatted_name}-key"
  key_vault_id = module.avm-res-keyvault-vault.resource_id
  depends_on   = [time_sleep.azurerm_key_vault_key_all]
}

data "azurerm_key_vault_key" "main_sqldb" {
  name         = "sqldb-${local.formatted_name}-key"
  key_vault_id = module.avm-res-keyvault-vault.resource_id
  depends_on   = [time_sleep.azurerm_key_vault_key_all]
}

data "azurerm_storage_account" "configs" {
  provider            = azurerm.shared
  name                = "st47860a55d730abc11df262"
  resource_group_name = "rg-uks-ubiq-shared-res"
}

data "azurerm_storage_container" "configs" {
  provider           = azurerm.shared
  name               = "siteconfigs"
  storage_account_id = data.azurerm_storage_account.configs.id
}

data "http" "staticweb_files" {
  for_each = local.staticweb_files
  url      = "${data.azurerm_storage_account.configs.primary_web_endpoint}${each.value.name}"
  request_headers = {
    Accept = each.value.type
  }
  retry {
    attempts = 3
  }
}

# Current captcha widget asset URLs
data "http" "captcha_assets" {
  for_each = local.captcha_environments
  url      = "https://${local.captcha_hosts[each.key]}/assets/manifest.json"
  request_headers = {
    Accept = "application/json"
  }
  retry {
    attempts = 3
  }
  lifecycle {
    postcondition {
      condition = self.status_code == 200 && alltrue([
        for field in ["widget", "wasm", "hashwx", "pako"] : can(jsondecode(self.response_body)[field])
      ])
      error_message = "The captcha asset manifest at ${local.captcha_hosts[each.key]} is unavailable or malformed."
    }
  }
}

data "azurerm_redis_cache" "uks" {
  count               = contains(local.az_us_geography, lower(local.region_geography)) ? 0 : 1
  provider            = azurerm.shared
  name                = "amais-uk"
  resource_group_name = "Amais"
}

data "azurerm_redis_cache" "eus" {
  count               = contains(local.az_us_geography, lower(local.region_geography)) ? 1 : 0
  provider            = azurerm.shared
  name                = "amais-us"
  resource_group_name = "Amais"
}

data "azurerm_subnet" "vnet_integration" {
  provider             = azurerm.shared
  name                 = "subnet-${local.short_region}-amais-01-${local.subnet_identifier}"
  virtual_network_name = "vnet-${local.short_region}-${var.amais_vnet_alias}"
  resource_group_name  = "rg-${local.short_region}-ubiq-networking"
}

data "azurerm_servicebus_namespace" "main" {
  provider            = azurerm.shared
  name                = "sbns-uks-amais-central-01"
  resource_group_name = "rg-uks-amais-central"
}

data "azurerm_dns_zone" "static_amais_com" {
  provider            = azurerm.shared
  name                = "static.amais.com"
  resource_group_name = "rg-uks-ubiq-networking"
}

data "azurerm_dns_zone" "website_amais_com" {
  provider            = azurerm.shared
  name                = "website.amais.com"
  resource_group_name = "rg-uks-ubiq-networking"
}

data "azurerm_user_assigned_identity" "dxp_client_staging" {
  count               = var.enable_entra_dxp_client_staging ? 1 : 0
  provider            = azurerm.shared
  name                = "id-app-uks-amais-dxp-client-staging"
  resource_group_name = "rg-uks-dxp-client-resources"
}

data "azurerm_user_assigned_identity" "dxp_client_production" {
  count               = var.enable_entra_dxp_client_production ? 1 : 0
  provider            = azurerm.shared
  name                = "id-app-uks-amais-dxp-client-prod"
  resource_group_name = "rg-uks-dxp-client-resources"
}

data "azuread_application" "dxp_api_staging" {
  count     = var.enable_entra_dxp_client_staging ? 1 : 0
  object_id = "0cf3e507-264e-444d-958e-1dd75b6c1615"
}

data "azuread_application" "dxp_api_production" {
  count     = var.enable_entra_dxp_client_production ? 1 : 0
  object_id = "3503d7d2-282c-4d94-b449-0c579899efd3"
}

data "azurerm_user_assigned_identity" "ais_srch" {
  count               = local.ai_chatbot_required ? 1 : 0
  provider            = azurerm.shared
  name                = "id-ais-uks-ai-central"
  resource_group_name = "rg-uks-ai-central"
}

data "azuread_application" "ckeditor_api_staging" {
  object_id = "106be387-81f8-4e05-8b2b-6506ccc3cb0e"
}

data "azuread_application" "ckeditor_api_prod" {
  object_id = "a184be5a-3abb-4982-a625-a5fa01e12933"
}
