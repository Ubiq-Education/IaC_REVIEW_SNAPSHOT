locals {
  webapp_additional_identity_ids_prod = [
    local.wkflo_auth_settings.prod.client_resource_id,
    var.enable_entra_dxp_client_production ? data.azurerm_user_assigned_identity.dxp_client_production[0].id : null
  ]
  webapp_additional_identity_ids_staging = local.add_staging_slot && var.dev_site != "no" ? [
    local.wkflo_auth_settings.staging.client_resource_id,
    var.enable_entra_dxp_client_staging ? data.azurerm_user_assigned_identity.dxp_client_staging[0].id : null
  ] : local.webapp_additional_identity_ids_prod
  app_sticky_settings_names = distinct(
    concat(
      keys(var.app_settings),
      keys(var.app_settings_staging),
      keys(local.app_settings),
      keys(local.app_settings_staging)
    )
  )
  # External environments config for web app settings
  # prod and staging here refer to the external environments, not the web app slots.
  external_environments = {
    ### Production Slot Settings
    prod = {
      SEND_GRID_KEY = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${data.azurerm_key_vault_secret.send_grid_key_prod.name})"
      ])
      AMAIS_DXP_API_KEY = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${local.site_production_dxp_api_key_name})"
      ])
      AMAIS_DXP_INGRESS_SERVER_URL    = "https://ingress.dxp.amais.com"
      AMAIS_DXP_MASTERDATA_SERVER_URL = "https://amais-dxp-md.azurewebsites.net"
      AMAIS_DXP_AI_SERVER_URL         = "https://app-uks-amais-dxp-ai.azurewebsites.net"
      # TODO: Remove Redis connection string when no longer needed
      AMAIS_DXP_REDIS_CONNECTION_STRING = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${local.amais_dxp_production_redis_connection_string_key_name})"
      ])
      AMAIS_DXP_REDIS_INSTANCE_NAME                     = "amais-dxp-prod"
      AMAIS_DXP_REPORT_SERVER_URL                       = "https://amais-dxp-report.azurewebsites.net"
      UsageLogClientSettings__EventHubQualifiedFullName = local.pum_api.prod.eventhub_fqdn
      UsageLogClientSettings__EvenHubName               = "evh-amais-pum-usage-log"
      PumApiSettings__Scope                             = "${local.pum_api.prod.identifier_uri}/.default"
      PumApiSettings__Url                               = local.pum_api.prod.url
      CKEDITOR_API_KEY_SECRET_NAME                      = data.azurerm_key_vault_secret.ckeditor_apikey_prod.name
      CKEDITOR_IMPORT_WORD_SECRET_KEY_SECRET_NAME       = data.azurerm_key_vault_secret.ckeditor_secretkey_prod.name
      CKEditor_Import_Word_Url                          = "https://docx-converter.amais.com"
      CKEditor_Import_Word_Audience                     = local.ckeditor_api_identifier_uri.production
      TokenApiServiceSettings__TokenServiceApiURL       = local.token_api_service_settings.prod.token_service_api_url
      TokenApiServiceSettings__AppIdUri                 = local.token_api_service_settings.prod.app_id_uri
      WKFloAuthSettings__ManagedIdentity                = local.wkflo_auth_settings.prod.client_id
      WKFloAuthSettings__Audience                       = local.wkflo_auth_settings.prod.audience
      WkfloSettings__BaseUrl                            = "https://gateway.wkflo.ai"
      AMAIS_WKFLO_WIDGET_CJS_URL                        = "https://app.wkflo.ai/assets/wkflo-widget.umd.cjs"
      AmaisJwtSchema__KeyName                           = "jwt-key-prod"
      GPTBotApiSettings__AzureFunctionSubscriptionId    = local.ai_chatbot_function_app.prod.sub_id
      GPTBotApiSettings__AzureFunctionAppName           = local.ai_chatbot_function_app.prod.app_name
      GPTBotApiSettings__AzureFunctionResourceGroup     = local.ai_chatbot_function_app.prod.app_rg
      GPTBotApiSettings__AzureFunctionName              = local.ai_chatbot_function_app.prod.function_name
      GPTBotApiSettings__AzureFunctionBaseUrl           = local.ai_chatbot_function_app.prod.app_baseurl
    }
    prod_chatbot = {
      AIS_MI_RESOURCE_ID                      = local.ai_chatbot_required ? data.azurerm_user_assigned_identity.ais_srch[0].id : null
      CHAT_MODULE_ENABLED                     = "true"
      ENABLE_GPTBOT                           = "true"
      GPTBotApiSettings__AzureOpenAIClientURL = local.amais_ai_url
      GPTBotApiSettings__GPTDeploymentName    = var.ai_chatbot_model_production
      GPTBotApiSettings__ChatbotApiURL        = local.ai_chatbot_api.prod.url
      GPTBotApiSettings__AzureSearchURL       = local.ai_search_endpoint
      GPTBotApiSettings__AzureSearchIndexName = local.ai_search_index_names.production
    }
    prod_dxp = var.enable_entra_dxp_client_production ? {
      AMAIS_DXP_CLIENT_AUTH_FLOW              = "entraid-no-secrets"
      IngressClientOAuthSettings__Audience    = "${local.dxp_api_identifier_uri.production}/.default"
      IngressClientOAuthSettings__ClientId    = data.azurerm_user_assigned_identity.dxp_client_production[0].client_id
      MasterDataClientOAuthSettings__Audience = "${local.dxp_api_identifier_uri.production}/.default"
      MasterDataClientOAuthSettings__ClientId = data.azurerm_user_assigned_identity.dxp_client_production[0].client_id
      ReportClientOAuthSettings__Audience     = "${local.dxp_api_identifier_uri.production}/.default"
      ReportClientOAuthSettings__ClientId     = data.azurerm_user_assigned_identity.dxp_client_production[0].client_id
      AIClientOAuthSettings__Audience         = "${local.dxp_api_identifier_uri.production}/.default"
      AIClientOAuthSettings__ClientId         = data.azurerm_user_assigned_identity.dxp_client_production[0].client_id
      } : {
      IngressClientOAuthSettings__Audience = "https://amais-dxp-ingress.azurewebsites.net/"
      IngressClientOAuthSettings__ClientId = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${data.azurerm_key_vault_secret.amais_dxp_production_ingressclientoauthsettings_clientid[0].name})"
      ])
      IngressClientOAuthSettings__ClientSecret = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${data.azurerm_key_vault_secret.amais_dxp_production_ingressclientoauthsettings_clientsecret[0].name})"
      ])
      IngressClientOAuthSettings__OAuthUrl    = "https://amais-prod-uk.uk.auth0.com"
      IngressClientOAuthSettings__TokenPath   = "/oauth/token"
      MasterDataClientOAuthSettings__Audience = "https://amais-dxp-md.azurewebsites.net/"
      MasterDataClientOAuthSettings__ClientId = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${data.azurerm_key_vault_secret.amais_dxp_production_masterdataclientoauthsettings_clientid[0].name})"
      ])
      MasterDataClientOAuthSettings__ClientSecret = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${data.azurerm_key_vault_secret.amais_dxp_production_masterdataclientoauthsettings_clientsecret[0].name})"
      ])
      MasterDataClientOAuthSettings__OAuthUrl  = "https://amais-prod-uk.uk.auth0.com"
      MasterDataClientOAuthSettings__TokenPath = "/oauth/token"
      ReportClientOAuthSettings__Audience      = "https://amais-dxp-report.azurewebsites.net/"
      ReportClientOAuthSettings__ClientId = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${data.azurerm_key_vault_secret.amais_dxp_production_reportclientoauthsettings_clientid[0].name})"
      ])
      ReportClientOAuthSettings__ClientSecret = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${data.azurerm_key_vault_secret.amais_dxp_production_reportclientoauthsettings_clientsecret[0].name})"
      ])
      ReportClientOAuthSettings__OAuthUrl  = "https://amais-prod-uk.uk.auth0.com"
      ReportClientOAuthSettings__TokenPath = "/oauth/token"
      AIClientOAuthSettings__Audience      = "https://app-uks-amais-dxp-ai.azurewebsites.net/"
      AIClientOAuthSettings__ClientId = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${data.azurerm_key_vault_secret.amais_dxp_production_aiclientoauthsettings_clientid[0].name})"
      ])
      AIClientOAuthSettings__ClientSecret = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${data.azurerm_key_vault_secret.amais_dxp_production_aiclientoauthsettings_clientsecret[0].name})"
      ])
      AIClientOAuthSettings__OAuthUrl  = "https://amais-prod-uk.uk.auth0.com"
      AIClientOAuthSettings__TokenPath = "/oauth/token"
    }
    prod_ubiq_shortener = {
      UBIQ_SHORTENER_API_ENDPOINT = "https://api.links.amais.com/api/links"
      UBIQ_SHORTENER_API_KEY = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${local.kv_ubiq_shortener_api_key_sk["ubiq_shortener_prod_api_key"].name})"
      ])
    }

    ### Staging Slot Settings
    staging = local.add_staging_slot ? {
      SEND_GRID_KEY = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${data.azurerm_key_vault_secret.send_grid_key_staging.name})"
      ])
      AMAIS_DXP_API_KEY = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${local.site_staging_dxp_api_key_name})"
      ])
      AMAIS_DXP_INGRESS_SERVER_URL    = "https://ingress-staging.dxp.amais.com"
      AMAIS_DXP_MASTERDATA_SERVER_URL = "https://amais-dxp-md-staging.azurewebsites.net"
      AMAIS_DXP_AI_SERVER_URL         = "https://app-uks-amais-dxp-ai-staging.azurewebsites.net"
      # TODO: Remove Redis connection string when no longer needed
      AMAIS_DXP_REDIS_CONNECTION_STRING = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${local.amais_dxp_staging_redis_connection_string_key_name})"
      ])
      AMAIS_DXP_REDIS_INSTANCE_NAME                     = "amais-dxp-staging"
      AMAIS_DXP_REPORT_SERVER_URL                       = "https://amais-dxp-report-staging.azurewebsites.net"
      UsageLogClientSettings__EventHubQualifiedFullName = local.pum_api.staging.eventhub_fqdn
      UsageLogClientSettings__EvenHubName               = "evh-amais-pum-usage-log"
      PumApiSettings__Scope                             = "${local.pum_api.staging.identifier_uri}/.default"
      PumApiSettings__Url                               = local.pum_api.staging.url
      CKEDITOR_API_KEY_SECRET_NAME                      = data.azurerm_key_vault_secret.ckeditor_apikey_staging.name
      CKEDITOR_IMPORT_WORD_SECRET_KEY_SECRET_NAME       = data.azurerm_key_vault_secret.ckeditor_secretkey_staging.name
      CKEditor_Import_Word_Url                          = "https://docx-converter-staging.amais.com"
      CKEditor_Import_Word_Audience                     = local.ckeditor_api_identifier_uri.staging
      TokenApiServiceSettings__TokenServiceApiURL       = local.token_api_service_settings.staging.token_service_api_url
      TokenApiServiceSettings__AppIdUri                 = local.token_api_service_settings.staging.app_id_uri
      WKFloAuthSettings__ManagedIdentity                = local.wkflo_auth_settings.staging.client_id
      WKFloAuthSettings__Audience                       = local.wkflo_auth_settings.staging.audience
      WkfloSettings__BaseUrl                            = "https://staging.gateway.wkflo.ai"
      AMAIS_WKFLO_WIDGET_CJS_URL                        = "https://staging.app.wkflo.ai/assets/wkflo-widget.umd.cjs"
      AmaisJwtSchema__KeyName                           = "jwt-key-staging"
      GPTBotApiSettings__AzureFunctionSubscriptionId    = local.ai_chatbot_function_app.staging.sub_id
      GPTBotApiSettings__AzureFunctionAppName           = local.ai_chatbot_function_app.staging.app_name
      GPTBotApiSettings__AzureFunctionResourceGroup     = local.ai_chatbot_function_app.staging.app_rg
      GPTBotApiSettings__AzureFunctionName              = local.ai_chatbot_function_app.staging.function_name
      GPTBotApiSettings__AzureFunctionBaseUrl           = local.ai_chatbot_function_app.staging.app_baseurl
    } : {}
    staging_chatbot = local.add_staging_slot ? {
      AIS_MI_RESOURCE_ID                      = local.ai_chatbot_required ? data.azurerm_user_assigned_identity.ais_srch[0].id : null
      CHAT_MODULE_ENABLED                     = "true"
      ENABLE_GPTBOT                           = "true"
      GPTBotApiSettings__AzureOpenAIClientURL = local.amais_ai_url
      GPTBotApiSettings__GPTDeploymentName    = var.ai_chatbot_model_staging
      GPTBotApiSettings__ChatbotApiURL        = local.ai_chatbot_api.staging.url
      GPTBotApiSettings__AzureSearchURL       = local.ai_search_endpoint
      GPTBotApiSettings__AzureSearchIndexName = local.ai_search_index_names.staging
    } : {}
    staging_dxp = local.add_staging_slot ? var.enable_entra_dxp_client_staging ? {
      AMAIS_DXP_CLIENT_AUTH_FLOW              = "entraid-no-secrets"
      IngressClientOAuthSettings__Audience    = "${local.dxp_api_identifier_uri.staging}/.default"
      IngressClientOAuthSettings__ClientId    = data.azurerm_user_assigned_identity.dxp_client_staging[0].client_id
      MasterDataClientOAuthSettings__Audience = "${local.dxp_api_identifier_uri.staging}/.default"
      MasterDataClientOAuthSettings__ClientId = data.azurerm_user_assigned_identity.dxp_client_staging[0].client_id
      ReportClientOAuthSettings__Audience     = "${local.dxp_api_identifier_uri.staging}/.default"
      ReportClientOAuthSettings__ClientId     = data.azurerm_user_assigned_identity.dxp_client_staging[0].client_id
      AIClientOAuthSettings__Audience         = "${local.dxp_api_identifier_uri.staging}/.default"
      AIClientOAuthSettings__ClientId         = data.azurerm_user_assigned_identity.dxp_client_staging[0].client_id
      } : {
      IngressClientOAuthSettings__Audience = "https://amais-dxp-ingress.azurewebsites.net/"
      IngressClientOAuthSettings__ClientId = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${data.azurerm_key_vault_secret.amais_dxp_staging_ingressclientoauthsettings_clientid[0].name})"
      ])
      IngressClientOAuthSettings__ClientSecret = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${data.azurerm_key_vault_secret.amais_dxp_staging_ingressclientoauthsettings_clientsecret[0].name})"
      ])
      IngressClientOAuthSettings__OAuthUrl    = "https://amais-dev-uk.uk.auth0.com"
      IngressClientOAuthSettings__TokenPath   = "/oauth/token"
      MasterDataClientOAuthSettings__Audience = "https://amais-dxp-md.azurewebsites.net/"
      MasterDataClientOAuthSettings__ClientId = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${data.azurerm_key_vault_secret.amais_dxp_staging_masterdataclientoauthsettings_clientid[0].name})"
      ])
      MasterDataClientOAuthSettings__ClientSecret = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${data.azurerm_key_vault_secret.amais_dxp_staging_masterdataclientoauthsettings_clientsecret[0].name})"
      ])
      MasterDataClientOAuthSettings__OAuthUrl  = "https://amais-dev-uk.uk.auth0.com"
      MasterDataClientOAuthSettings__TokenPath = "/oauth/token"
      ReportClientOAuthSettings__Audience      = "https://amais-dxp-report.azurewebsites.net/"
      ReportClientOAuthSettings__ClientId = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${data.azurerm_key_vault_secret.amais_dxp_staging_reportclientoauthsettings_clientid[0].name})"
      ])
      ReportClientOAuthSettings__ClientSecret = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${data.azurerm_key_vault_secret.amais_dxp_staging_reportclientoauthsettings_clientsecret[0].name})"
      ])
      ReportClientOAuthSettings__OAuthUrl  = "https://amais-dev-uk.uk.auth0.com"
      ReportClientOAuthSettings__TokenPath = "/oauth/token"
      AIClientOAuthSettings__Audience      = "https://app-uks-amais-dxp-ai.azurewebsites.net/"
      AIClientOAuthSettings__ClientId = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${data.azurerm_key_vault_secret.amais_dxp_staging_aiclientoauthsettings_clientid[0].name})"
      ])
      AIClientOAuthSettings__ClientSecret = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${data.azurerm_key_vault_secret.amais_dxp_staging_aiclientoauthsettings_clientsecret[0].name})"
      ])
      AIClientOAuthSettings__OAuthUrl  = "https://amais-dev-uk.uk.auth0.com"
      AIClientOAuthSettings__TokenPath = "/oauth/token"
    } : {}
    staging_ubiq_shortener = local.add_staging_slot && var.dev_site != "no" ? {
      UBIQ_SHORTENER_API_ENDPOINT = "https://api-staging.links.amais.com/api/links"
      UBIQ_SHORTENER_API_KEY = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${local.kv_ubiq_shortener_api_key_sk["ubiq_shortener_staging_api_key"].name})"
      ])
    } : {}
    prod_ubiq_captcha = {
      UBIQ_CAPTCHA_API_ENDPOINT   = "https://${local.captcha_hosts.prod}/sites/${local.captcha_site_name}/"
      UBIQ_CAPTCHA_SITEVERIFY_URL = "https://${local.captcha_hosts.prod}/sites/${local.captcha_site_name}/siteverify"
      UBIQ_CAPTCHA_SITE_KEY = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${local.kv_ubiq_captcha_site_key_sk["ubiq_captcha_prod_site_key"].name})"
      ])
      UBIQ_CAPTCHA_WIDGET_URL = local.captcha_assets.prod.widget
      UBIQ_CAPTCHA_WASM_URL   = local.captcha_assets.prod.wasm
      UBIQ_CAPTCHA_HASHWX_URL = local.captcha_assets.prod.hashwx
      UBIQ_CAPTCHA_PAKO_URL   = local.captcha_assets.prod.pako
    }
    staging_ubiq_captcha = local.add_staging_slot && var.dev_site != "no" ? {
      UBIQ_CAPTCHA_API_ENDPOINT   = "https://${local.captcha_hosts.staging}/sites/${local.captcha_site_name}/"
      UBIQ_CAPTCHA_SITEVERIFY_URL = "https://${local.captcha_hosts.staging}/sites/${local.captcha_site_name}/siteverify"
      UBIQ_CAPTCHA_SITE_KEY = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${local.kv_ubiq_captcha_site_key_sk["ubiq_captcha_staging_site_key"].name})"
      ])
      UBIQ_CAPTCHA_WIDGET_URL = local.captcha_assets.staging.widget
      UBIQ_CAPTCHA_WASM_URL   = local.captcha_assets.staging.wasm
      UBIQ_CAPTCHA_HASHWX_URL = local.captcha_assets.staging.hashwx
      UBIQ_CAPTCHA_PAKO_URL   = local.captcha_assets.staging.pako
    } : {}
    # Only merged into slots with custom SendGrid config (see sendgrid_events.tf)
    prod_ubiq_sendgrid_events = contains(local.sendgrid_events_environments, "prod") ? {
      SendGridEvents__BaseUrl  = "https://${local.sendgrid_events_hosts.prod}"
      SendGridEvents__SiteName = local.sendgrid_events_site_name
      SendGridEvents__ApiKey = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${local.kv_ubiq_sendgrid_events_site_key_sk["ubiq_sendgrid_events_prod_site_key"].name})"
      ])
    } : {}
    staging_ubiq_sendgrid_events = contains(local.sendgrid_events_environments, "staging") ? {
      SendGridEvents__BaseUrl  = "https://${local.sendgrid_events_hosts.staging}"
      SendGridEvents__SiteName = local.sendgrid_events_site_name
      SendGridEvents__ApiKey = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${local.kv_ubiq_sendgrid_events_site_key_sk["ubiq_sendgrid_events_staging_site_key"].name})"
      ])
    } : {}
  }
  # Web app settings for production slot
  static_app_settings = {
    Application                     = local.amais_application_name
    TEMPLATES_FOLDER                = local.templates_folder
    SEND_GRID_EMAIL_SENDER          = local.send_grid_email_sender
    SEND_GRID_USER                  = local.send_grid_user
    AMS_CDN_PATH                    = local.ams_cdn_path
    ROOT_CDN_PATH                   = local.root_cdn_path
    BLOB_STORAGE_ROOT_CONTAINER     = local.blob_storage_root_container
    BLOB_STORAGE_CDN_CONTAINER      = "$web"
    BLOB_STORAGE_ACCOUNT_URI        = module.avm-res-storage-storageaccount.resource.output.properties.primaryEndpoints.blob
    BLOB_STORAGE_ACCOUNT_URI_DXP    = data.azurerm_storage_account.uks_dxp.primary_blob_endpoint
    AZURE_SUBSCRIPTION_ID           = var.sub_id
    AZURE_TENANT_ID                 = local.azure_tenant_id
    NLOG_CONNECTION_STRING          = local.nlog_db_connection_string
    DB_CONNECTION_STRING            = local.db_connection_string
    DB_USER_CONNECTION_STRING       = local.db_user_connection_string
    WEBSITE_RUN_FROM_PACKAGE        = "1"
    WEBSITE_ENABLE_SYNC_UPDATE_SITE = "true"
    ASPNETCORE_ENVIRONMENT          = "Production"
    KEY_VAULT_URI                   = module.avm-res-keyvault-vault.uri
    SERVICE_BUS_URI                 = data.azurerm_servicebus_namespace.main.endpoint
    CDN_PROVIDER                    = local.cdn_provider
    DATA_ENCRYPTION_KEY_NAME        = azurerm_key_vault_key.amais.name
    ENABLE_PROXY_FORWARD_HEADERS    = var.web_app_x_azure_fdid_lockdown ? "true" : "false"
    ZENDESK_JWT_SHARED_KEY = join("", [
      "@Microsoft.KeyVault(VaultName=${local.kv_name};",
      "SecretName=${data.azurerm_key_vault_secret.zendesk_jwt_shared_key.name})"
    ])
    MI_CLIENT_ID                                          = module.avm-res-managedidentity-userassignedidentity-app.resource.client_id
    AZ_WEBAPP_DEFAULT_FQDN                                = local.az_webapp_default_fqdn_production
    AZ_WEBAPP_ALL_FQDN                                    = join(" ", distinct(concat(var.web_domains, [local.az_webapp_default_fqdn_production])))
    ProcessPageDataGenerationJobSettings__IsEnable        = var.enable_page_data_generation_job_slot == "production" ? "true" : "false"
    Scheduler__ProcessPageDataGenerationJob               = var.page_data_generation_job_cron_expression
    OAuthBehaviourSettings__CacheEnable                   = "true"
    OAuthBehaviourSettings__RetrieveTokenBeforeExpiration = "60"
    OAuthBehaviourSettings__SlidingExpirationTime         = "2419200"
    SSO_SAML_UBIQ_ENTITY_ID                               = local.ubiq_sso_entity_id
    SSO_SAML_UBIQ_LOGIN_URL                               = "https://login.microsoftonline.com/${azuread_service_principal.sso_main.application_tenant_id}/saml2"
    SSO_SAML_UBIQ_LOGOUT_URL                              = ""
    SSO_SAML_UBIQ_CERT_1                                  = azuread_service_principal_token_signing_certificate.sso_main_1.value
    SSO_SAML_UBIQ_CERT_2                                  = azuread_service_principal_token_signing_certificate.sso_main_2.value
    BlackbaudSynchAthleticsUpdateJobSettings__IsEnable = (
      var.enable_BlackbaudSynchAthleticsUpdateJobSetting && var.BlackbaudSynchAthleticsUpdateJobSetting_slot_name == "production" ? "true" : "false"
    )
    BlackbaudSynchJobSettings__IsEnable = (
      var.enable_BlackbaudSynchJobSettings && var.BlackbaudSynchJobSettings_slot_name == "production" ? "true" : "false"
    )
    OAuthProvider            = "Blackbaud"
    OauthBlackBaudSkyBaseUri = "https://api.sky.blackbaud.com/"
    OauthBlackBaud__AuthRedirectUri = (
      var.web_app_x_azure_fdid_lockdown ?
      "https://${trimsuffix(azurerm_dns_cname_record.cdn_root[0].fqdn, ".")}/blackbaud/integration/callback" :
      "https://${lower(local.app_name)}.azurewebsites.net/blackbaud/integration/callback"
    )
    OauthBlackBaud__ClientId = join("", [
      "@Microsoft.KeyVault(VaultName=${local.kv_name};",
      "SecretName=${data.azurerm_key_vault_secret.oauth_blackbaud_client_id.name})"
    ])
    OauthBlackBaud__ClientSecret = join("", [
      "@Microsoft.KeyVault(VaultName=${local.kv_name};",
      "SecretName=${data.azurerm_key_vault_secret.oauth_blackbaud_client_secret.name})"
    ])
    OauthBlackBaud__OAuthUrl = "https://oauth2.sky.blackbaud.com/"
    OauthBlackBaud__SubscriptionKey = join("", [
      "@Microsoft.KeyVault(VaultName=${local.kv_name};",
      "SecretName=${data.azurerm_key_vault_secret.oauth_blackbaud_subscription_key.name})"
    ])
    Scheduler__BlackbaudSynchJob                = var.BlackbaudSynchJobSettings_schedule
    Scheduler__BlackbaudSynchAthleticsUpdateJob = var.BlackbaudSynchAthleticsUpdateJobSetting_schedule
    Scheduler__VeracrossSynchJob                = var.veracross_synch_job_schedule_cron_expression
  }
  # Web app settings for staging slot
  static_app_settings_staging = local.add_staging_slot ? {
    Application                     = local.amais_application_name
    TEMPLATES_FOLDER                = local.templates_folder
    SEND_GRID_EMAIL_SENDER          = local.send_grid_email_sender
    SEND_GRID_USER                  = local.send_grid_user
    AMS_CDN_PATH                    = local.ams_cdn_path
    ROOT_CDN_PATH                   = "/cdn"
    BLOB_STORAGE_ROOT_CONTAINER     = local.blob_storage_root_container
    BLOB_STORAGE_CDN_CONTAINER      = "$web"
    BLOB_STORAGE_ACCOUNT_URI        = module.avm-res-storage-storageaccount.resource.output.properties.primaryEndpoints.blob
    BLOB_STORAGE_ACCOUNT_URI_DXP    = data.azurerm_storage_account.uks_dxp.primary_blob_endpoint
    AZURE_SUBSCRIPTION_ID           = var.sub_id
    AZURE_TENANT_ID                 = local.azure_tenant_id
    NLOG_CONNECTION_STRING          = local.nlog_db_connection_string_staging
    DB_CONNECTION_STRING            = local.db_connection_string
    DB_USER_CONNECTION_STRING       = local.db_user_connection_string
    WEBSITE_RUN_FROM_PACKAGE        = "1"
    WEBSITE_ENABLE_SYNC_UPDATE_SITE = "true"
    ASPNETCORE_ENVIRONMENT          = "Staging"
    KEY_VAULT_URI                   = module.avm-res-keyvault-vault.uri
    SERVICE_BUS_URI                 = data.azurerm_servicebus_namespace.main.endpoint
    CDN_PROVIDER                    = local.cdn_provider
    DATA_ENCRYPTION_KEY_NAME        = azurerm_key_vault_key.amais.name
    ENABLE_PROXY_FORWARD_HEADERS    = var.web_app_x_azure_fdid_lockdown ? "true" : "false"
    ZENDESK_JWT_SHARED_KEY = join("", [
      "@Microsoft.KeyVault(VaultName=${local.kv_name};",
      "SecretName=${data.azurerm_key_vault_secret.zendesk_jwt_shared_key.name})"
    ])
    MI_CLIENT_ID                                          = module.avm-res-managedidentity-userassignedidentity-app.resource.client_id
    AZ_WEBAPP_DEFAULT_FQDN                                = local.az_webapp_default_fqdn_staging
    AZ_WEBAPP_ALL_FQDN                                    = join(" ", distinct(concat(var.web_domains, [local.az_webapp_default_fqdn_staging])))
    ProcessPageDataGenerationJobSettings__IsEnable        = var.enable_page_data_generation_job_slot == "staging" ? "true" : "false"
    Scheduler__ProcessPageDataGenerationJob               = var.page_data_generation_job_cron_expression
    OAuthBehaviourSettings__CacheEnable                   = "true"
    OAuthBehaviourSettings__RetrieveTokenBeforeExpiration = "60"
    OAuthBehaviourSettings__SlidingExpirationTime         = "2419200"
    SSO_SAML_UBIQ_ENTITY_ID                               = local.ubiq_sso_entity_id
    SSO_SAML_UBIQ_LOGIN_URL                               = "https://login.microsoftonline.com/${azuread_service_principal.sso_main.application_tenant_id}/saml2"
    SSO_SAML_UBIQ_LOGOUT_URL                              = ""
    SSO_SAML_UBIQ_CERT_1                                  = azuread_service_principal_token_signing_certificate.sso_main_1.value
    SSO_SAML_UBIQ_CERT_2                                  = azuread_service_principal_token_signing_certificate.sso_main_2.value
    BlackbaudSynchAthleticsUpdateJobSettings__IsEnable = (
      var.enable_BlackbaudSynchAthleticsUpdateJobSetting && var.BlackbaudSynchAthleticsUpdateJobSetting_slot_name == "staging" ? "true" : "false"
    )
    BlackbaudSynchJobSettings__IsEnable = (
      var.enable_BlackbaudSynchJobSettings && var.BlackbaudSynchJobSettings_slot_name == "staging" ? "true" : "false"
    )
    OAuthProvider            = "Blackbaud"
    OauthBlackBaudSkyBaseUri = "https://api.sky.blackbaud.com/"
    OauthBlackBaud__AuthRedirectUri = (
      var.web_app_x_azure_fdid_lockdown ?
      "https://${trimsuffix(azurerm_dns_cname_record.cdn_staging[0].fqdn, ".")}/blackbaud/integration/callback" :
      "https://${lower(local.app_name)}-${lower(local.staging_slot_name)}.azurewebsites.net/blackbaud/integration/callback"
    )
    OauthBlackBaud__ClientId = join("", [
      "@Microsoft.KeyVault(VaultName=${local.kv_name};",
      "SecretName=${data.azurerm_key_vault_secret.oauth_blackbaud_client_id.name})"
    ])
    OauthBlackBaud__ClientSecret = join("", [
      "@Microsoft.KeyVault(VaultName=${local.kv_name};",
      "SecretName=${data.azurerm_key_vault_secret.oauth_blackbaud_client_secret.name})"
    ])
    OauthBlackBaud__OAuthUrl = "https://oauth2.sky.blackbaud.com/"
    OauthBlackBaud__SubscriptionKey = join("", [
      "@Microsoft.KeyVault(VaultName=${local.kv_name};",
      "SecretName=${data.azurerm_key_vault_secret.oauth_blackbaud_subscription_key.name})"
    ])
    Scheduler__BlackbaudSynchJob                = var.BlackbaudSynchJobSettings_schedule
    Scheduler__BlackbaudSynchAthleticsUpdateJob = var.BlackbaudSynchAthleticsUpdateJobSetting_schedule
    Scheduler__VeracrossSynchJob                = var.veracross_synch_job_schedule_cron_expression
  } : {}
  # Conditional Web app settings for production slot
  app_settings = merge(
    local.static_app_settings,
    local.wkflo_auth_settings_common,
    local.external_environments.prod,
    var.enable_ai_chatbot_production ? local.external_environments.prod_chatbot : {},
    local.external_environments.prod_dxp,
    local.external_environments.prod_ubiq_shortener,
    local.external_environments.prod_ubiq_captcha,
    var.enable_custom_send_grid_config_production ? local.external_environments.prod_ubiq_sendgrid_events : {},
    var.bunny_cdn_enablement == "yes" ? {
      BUNNY_PULLZONE_ID         = module.bunny_cdn_waf[0].pullzone.id
      BUNNY_API_KEY_SECRET_NAME = data.azurerm_key_vault_secret.bunnynet_api_key[0].name
    } : {},
    # Use directory sync variable for gg4l enablement as validation will ensure GG4L is selected and it's idependent of SSO settings
    local.enable_blackbaud_integration || local.enable_veracross_integration || (local.enable_gg4l_integration && var.enable_gg4l_directory_synch) ? {
      INTEGRATION_FEATURE_ENABLED = "true"
    } : {},
    local.enable_blackbaud_integration ? {
      BLACKBAUD_INTEGRATION_ENABLED = "true"
    } : {},
    local.enable_blackbaud_integration && var.enable_blackbaud_sso ? {
      OAuthSettings__AuthorizeUrl = var.oauth_authorize_url_override != null ? var.oauth_authorize_url_override : format(
        "https://%s.myschoolapp.com/app/sso/auth/%s",
        lower(var.blackbaud_account_name),
        lower(var.blackbaud_sso_auth_api_slug_production)
      )
      OAuthSettings__ReturnUri = "/web/account/blackbaud-sso"
      OAuthSettings__ApiKey = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${local.blackbaud_oauth_settings_apikey_prod_key_name})"
      ])
    } : {},
    var.enable_dxp_integration_production ? {
      DXP_MODULE_ENABLED = "true"
    } : {},
    var.enable_authorize_net_integration_staging ? {
      AUTHORIZE_NET_ACCEPT_JS_URL = "https://js.authorize.net/v1/Accept.js"
      AUTHORIZE_NET_API_LOGIN_ID = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${local.authorize_net_api_login_id_key_name})"
      ])
      AUTHORIZE_NET_PUBLIC_CLIENT_KEY = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${local.authorize_net_public_client_key_key_name})"
      ])
      AUTHORIZE_NET_RUN_ENVIROMENT = "PRODUCTION"
      AUTHORIZE_NET_TRANSACTION_KEY = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${local.authorize_net_transaction_key_key_name})"
      ])
    } : {},
    var.enable_form_payments_production ? {
      FORM_PAYMENTS_ENABLED = "true"
    } : {},
    var.enable_email_module_production ? {
      EMAIL_MODULE_ENABLED = "true"
    } : {},
    var.enable_contacts_module_production ? {
      CONTACTS_MODULE_ENABLED = "true"
    } : {},
    var.enable_custom_send_grid_config_production ? {
      SEND_GRID_EMAIL_SENDER = var.send_grid_email_sender
      SEND_GRID_KEY = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${local.custom_send_grid_key_prod_key_name})"
      ])
      SEND_GRID_MARKETING_UNSUBSCRIBE_GROUP_ID = var.send_grid_marketing_unsubscribe_group_id
      SEND_GRID_UNSUBSCRIBE_GROUPS             = var.send_grid_unsubscribe_groups
      SEND_GRID_USER                           = var.send_grid_user
      EmailStatsSyncJobSettings__IsEnable = (
        var.EmailStatsSyncJobSettings_slot_name == "production" ? "true" : "false"
      )
      Scheduler__EmailStatsSyncJob = var.EmailStats_sync_job_schedule_cron_expression
      EmailSupressionsSyncJobSettings__IsEnable = (
        var.EmailSupressionsSyncJobSettings_slot_name == "production" ? "true" : "false"
      )
      Scheduler__EmailSupressionsSyncJob = var.EmailSupressions_sync_job_schedule_cron_expression
    } : {},
    var.calendar_time_zone != null ? {
      CALENDAR_TIME_ZONE = var.calendar_time_zone
    } : {},
    var.calendar_time_zone_id != null ? {
      CALENDAR_TIME_ZONE_ID = var.calendar_time_zone_id
    } : {},
    var.disable_branch_redirects_production ? {
      DISABLE_BRANCH_REDIRECTS = "true"
    } : {},
    local.enable_veracross_integration ? {
      VERACROSS_INTEGRATION_ENABLED = "true"
      OAuthProvider                 = "Veracross"
      OAuthSettings__OAuthUrl       = "https://accounts.veracross.com/${lower(var.veracross_account_name)}/oauth"
      OAuthSettings__ResourceUrl    = "https://api.veracross.com/${lower(var.veracross_account_name)}/v3"
      OAuthSettings__ClientId = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${local.veracross_oauth_settings_client_id_key_name})"
      ])
      OAuthSettings__ClientSecret = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${local.veracross_oauth_settings_client_secret_key_name})"
      ])
      OAuthSettings__Scope = var.veracross_oauth_settings_scope
      VeracrossSynchJobSettings__IsEnable = (
        var.enable_VeracrossSynchJobSettings && var.VeracrossSynchJobSettings_slot_name == "production" ? "true" : "false"
      )
    } : {},
    local.enable_veracross_integration && var.enable_veracross_sso ? {
      OAuthSettings__AuthorizeUrl = var.oauth_authorize_url_override != null ? var.oauth_authorize_url_override : format(
        "https://accounts.veracross.com/%s/oauth/authorize?client_id={clienId}&redirect_uri={redirect_uri}&scope=sso&response_type=code",
        lower(var.veracross_account_name)
      )
      OAuthSettings__ReturnUri = "/web/account/oauth"
    } : {},
    local.enable_gg4l_integration && var.enable_gg4l_directory_synch ? {
      GG4L_SynchClientId = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${local.gg4l_synch_client_id_key_name})"
      ])
      GG4L_SynchClientSecret = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${local.gg4l_synch_client_secret_key_name})"
      ])
      GG4L_SynchOAuthUrl       = "https://api.gg4l.com/datahub/oauth"
      GG4L_SynchResourceUrl    = "https://api.gg4l.com/datahub/services/ims/oneroster/v1p1"
      GG4L_INTEGRATION_ENABLED = "true"
    } : {},
    local.enable_gg4l_integration && var.enable_gg4l_sso ? {
      OAuthProvider            = "GG4L"
      OAuthSettings__ReturnUri = "/web/account/oauth"
      OAuthSettings__AuthorizeUrl = (
        var.oauth_authorize_url_override != null ? var.oauth_authorize_url_override :
        "https://sso.gg4l.com/oauth/auth?response_type=code&client_id={clienId}&redirect_uri={redirect_uri}"
      )
      OAuthSettings__OAuthUrl    = "https://sso.gg4l.com/oauth"
      OAuthSettings__ResourceUrl = "https://sso.gg4l.com/services/v1.4"
      OAuthSettings__ClientId = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${local.gg4l_oauth_settings_client_id_key_name})"
      ])
      OAuthSettings__ClientSecret = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${local.gg4l_oauth_settings_client_secret_key_name})"
      ])
      OAuthSettings__IncludeBasicAuthHeader = "true"
    } : {},
    var.enable_workflow_module_production ? {
      WORKFLOW_MODULE_ENABLED = "true"
      WorkflowEngineJobSettings__IsEnable = (
        var.WorkflowEngineJob_slot_name == "production" ? "true" : "false"
      )
      Scheduler__WorkflowEngineJob = var.WorkflowEngineJob_schedule_cron_expression
    } : {},
    var.scheduler_manager_slot_name == "production" ? {
      Scheduler__ManagerJob = var.scheduler_manager_job_cron_expression
    } : {},
    var.weglot_redirection_enabled ? {
      PREVENT_CMS_USERS_AUTHENTICATION_CSV_DOMAINS = local.prevent_cms_users_authentication_csv_domains_value
    } : {}
  )
  # Conditional Web app settings for staging slot
  app_settings_staging = local.add_staging_slot ? merge(
    local.static_app_settings_staging,
    local.wkflo_auth_settings_common,
    var.dev_site != "no" ? local.external_environments.staging : local.external_environments.prod,
    var.enable_ai_chatbot_staging ? var.dev_site != "no" ? local.external_environments.staging_chatbot : local.external_environments.prod_chatbot : {},
    var.dev_site != "no" ? local.external_environments.staging_dxp : local.external_environments.prod_dxp,
    var.dev_site != "no" ? local.external_environments.staging_ubiq_shortener : local.external_environments.prod_ubiq_shortener,
    var.dev_site != "no" ? local.external_environments.staging_ubiq_captcha : local.external_environments.prod_ubiq_captcha,
    var.enable_custom_send_grid_config_staging ? (
      var.dev_site != "no" ? local.external_environments.staging_ubiq_sendgrid_events : local.external_environments.prod_ubiq_sendgrid_events
    ) : {},
    var.bunny_cdn_enablement == "yes" ? {
      BUNNY_PULLZONE_ID         = module.bunny_cdn_waf[0].pullzone.id
      BUNNY_API_KEY_SECRET_NAME = data.azurerm_key_vault_secret.bunnynet_api_key[0].name
    } : {},
    # Use directory sync variable for gg4l enablement as validation will ensure GG4L is selected and it's idependent of SSO settings
    local.enable_blackbaud_integration || local.enable_veracross_integration || (local.enable_gg4l_integration && var.enable_gg4l_directory_synch) ? {
      INTEGRATION_FEATURE_ENABLED = "true"
    } : {},
    local.enable_blackbaud_integration ? {
      BLACKBAUD_INTEGRATION_ENABLED = "true"
    } : {},
    local.enable_blackbaud_integration && var.enable_blackbaud_sso ? {
      OAuthSettings__AuthorizeUrl = var.oauth_authorize_url_override != null ? var.oauth_authorize_url_override : format(
        "https://%s.myschoolapp.com/app/sso/auth/%s",
        lower(var.blackbaud_account_name),
        lower(var.blackbaud_sso_auth_api_slug_staging)
      )
      OAuthSettings__ReturnUri = "/web/account/blackbaud-sso"
      OAuthSettings__ApiKey = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${local.blackbaud_oauth_settings_apikey_staging_key_name})"
      ])
    } : {},
    var.enable_dxp_integration_staging ? {
      DXP_MODULE_ENABLED = "true"
    } : {},
    var.enable_authorize_net_integration_staging ? {
      AUTHORIZE_NET_ACCEPT_JS_URL = "https://js.authorize.net/v1/Accept.js"
      AUTHORIZE_NET_API_LOGIN_ID = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${local.authorize_net_api_login_id_key_name})"
      ])
      AUTHORIZE_NET_PUBLIC_CLIENT_KEY = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${local.authorize_net_public_client_key_key_name})"
      ])
      AUTHORIZE_NET_RUN_ENVIROMENT = "PRODUCTION"
      AUTHORIZE_NET_TRANSACTION_KEY = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${local.authorize_net_transaction_key_key_name})"
      ])
    } : {},
    var.enable_form_payments_staging ? {
      FORM_PAYMENTS_ENABLED = "true"
    } : {},
    var.enable_email_module_staging ? {
      EMAIL_MODULE_ENABLED = "true"
    } : {},
    var.enable_contacts_module_staging ? {
      CONTACTS_MODULE_ENABLED = "true"
    } : {},
    var.enable_custom_send_grid_config_staging ? {
      SEND_GRID_EMAIL_SENDER = var.send_grid_email_sender
      SEND_GRID_KEY = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${local.custom_send_grid_key_staging_key_name})"
      ])
      SEND_GRID_MARKETING_UNSUBSCRIBE_GROUP_ID = var.send_grid_marketing_unsubscribe_group_id
      SEND_GRID_UNSUBSCRIBE_GROUPS             = var.send_grid_unsubscribe_groups
      SEND_GRID_USER                           = var.send_grid_user
      EmailStatsSyncJobSettings__IsEnable = (
        var.EmailStatsSyncJobSettings_slot_name == "staging" ? "true" : "false"
      )
      Scheduler__EmailStatsSyncJob = var.EmailStats_sync_job_schedule_cron_expression
      EmailSupressionsSyncJobSettings__IsEnable = (
        var.EmailSupressionsSyncJobSettings_slot_name == "staging" ? "true" : "false"
      )
      Scheduler__EmailSupressionsSyncJob = var.EmailSupressions_sync_job_schedule_cron_expression
    } : {},
    var.calendar_time_zone != null ? {
      CALENDAR_TIME_ZONE = var.calendar_time_zone
    } : {},
    var.calendar_time_zone_id != null ? {
      CALENDAR_TIME_ZONE_ID = var.calendar_time_zone_id
    } : {},
    var.disable_branch_redirects_staging ? {
      DISABLE_BRANCH_REDIRECTS = "true"
    } : {},
    local.enable_veracross_integration ? {
      VERACROSS_INTEGRATION_ENABLED = "true"
      OAuthProvider                 = "Veracross"
      OAuthSettings__OAuthUrl       = "https://accounts.veracross.com/${lower(var.veracross_account_name)}/oauth"
      OAuthSettings__ResourceUrl    = "https://api.veracross.com/${lower(var.veracross_account_name)}/v3"
      OAuthSettings__ClientId = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${local.veracross_oauth_settings_client_id_key_name})"
      ])
      OAuthSettings__ClientSecret = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${local.veracross_oauth_settings_client_secret_key_name})"
      ])
      OAuthSettings__Scope = var.veracross_oauth_settings_scope
      VeracrossSynchJobSettings__IsEnable = (
        var.enable_VeracrossSynchJobSettings && var.VeracrossSynchJobSettings_slot_name == "staging" ? "true" : "false"
      )
    } : {},
    local.enable_veracross_integration && var.enable_veracross_sso ? {
      OAuthSettings__AuthorizeUrl = var.oauth_authorize_url_override != null ? var.oauth_authorize_url_override : format(
        "https://accounts.veracross.com/%s/oauth/authorize?client_id={clienId}&redirect_uri={redirect_uri}&scope=sso&response_type=code",
        lower(var.veracross_account_name)
      )
      OAuthSettings__ReturnUri = "/web/account/oauth"
    } : {},
    local.enable_gg4l_integration && var.enable_gg4l_directory_synch ? {
      GG4L_SynchClientId = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${local.gg4l_synch_client_id_key_name})"
      ])
      GG4L_SynchClientSecret = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${local.gg4l_synch_client_secret_key_name})"
      ])
      GG4L_SynchOAuthUrl       = "https://api.gg4l.com/datahub/oauth"
      GG4L_SynchResourceUrl    = "https://api.gg4l.com/datahub/services/ims/oneroster/v1p1"
      GG4L_INTEGRATION_ENABLED = "true"
    } : {},
    local.enable_gg4l_integration && var.enable_gg4l_sso ? {
      OAuthProvider            = "GG4L"
      OAuthSettings__ReturnUri = "/web/account/oauth"
      OAuthSettings__AuthorizeUrl = (
        var.oauth_authorize_url_override != null ? var.oauth_authorize_url_override :
        "https://sso.gg4l.com/oauth/auth?response_type=code&client_id={clienId}&redirect_uri={redirect_uri}"
      )
      OAuthSettings__OAuthUrl    = "https://sso.gg4l.com/oauth"
      OAuthSettings__ResourceUrl = "https://sso.gg4l.com/services/v1.4"
      OAuthSettings__ClientId = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${local.gg4l_oauth_settings_client_id_key_name})"
      ])
      OAuthSettings__ClientSecret = join("", [
        "@Microsoft.KeyVault(VaultName=${local.kv_name};",
        "SecretName=${local.gg4l_oauth_settings_client_secret_key_name})"
      ])
      OAuthSettings__IncludeBasicAuthHeader = "true"
    } : {},
    var.enable_workflow_module_staging ? {
      WORKFLOW_MODULE_ENABLED = "true"
      WorkflowEngineJobSettings__IsEnable = (
        var.WorkflowEngineJob_slot_name == "staging" ? "true" : "false"
      )
      Scheduler__WorkflowEngineJob = var.WorkflowEngineJob_schedule_cron_expression
    } : {},
    var.scheduler_manager_slot_name == "staging" ? {
      Scheduler__ManagerJob = var.scheduler_manager_job_cron_expression
    } : {},
    var.weglot_redirection_enabled ? {
      PREVENT_CMS_USERS_AUTHENTICATION_CSV_DOMAINS = local.prevent_cms_users_authentication_csv_domains_value
    } : {}
  ) : {}
}
