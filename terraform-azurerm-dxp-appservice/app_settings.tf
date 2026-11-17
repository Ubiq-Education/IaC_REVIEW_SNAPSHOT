locals {
  global_redis_cache_connection_info = var.redis_cache_enabled ? {
    AZURE_REDIS_HOSTNAME = data.azurerm_managed_redis.main[0].hostname
  } : {}
  app_slots = {
    production = {
      app_settings = merge(
        {
          ASPNETCORE_ENVIRONMENT = "Production"
          DB_CONNECTION_STRING   = var.db_connection_use_entra_auth_production == true ? local.db_connection_string_entra : local.db_connection_string_serverauth
          NLOG_CONNECTION_STRING = var.db_connection_use_entra_auth_production == true ? local.nlog_db_connection_string_entra : local.nlog_db_connection_string_serverauth
          AZURE_CLIENT_ID        = module.avm-res-managedidentity-userassignedidentity-app.resource.client_id
        },
        var.auth0_oauth_settings_enabled_production == true ? {
          OauthSettings__AuthorityIssuer = "https://amais-prod-uk.uk.auth0.com/"
          OauthSettings__UrlToken        = "https://amais-prod-uk.uk.auth0.com/oauth/token"
          OauthSettings__UrlAuthorize    = "https://amais-prod-uk.uk.auth0.com/authorize"
          OauthSettings__Audience        = "https://${lower(local.app_name)}.azurewebsites.net/"
        } : {},
        var.elastic_search_settings_enabled == true ? {
          # TODO: Do we just add these as custom app settings in the root config for the web app?
          ElasticsearchSettings__ApiKey = join("", [
            "@Microsoft.KeyVault(VaultName=${local.kv_name};",
            "SecretName=amais-dxp--elk-api-key-prod)"
          ])
          ElasticsearchSettings__CloudId = join("", [
            "@Microsoft.KeyVault(VaultName=${local.kv_name};",
            "SecretName=amais-dxp--elk-cloud-id-prod)"
          ])
          ElasticsearchSettings__DataStream = "amais-dxp-data-stream"
          ElasticsearchSettings__TenantDataStream = (
            var.elastic_search_tenant_data_stream_slot == "production" ? "amais-{tenant}-dxp-data-stream" : ""
          )
          ElasticsearchSettings__IsEnableTenantDataStream = (
            var.elastic_search_tenant_data_stream_slot == "production" ? "true" : "false"
          )
        } : {},
        var.analytics_db_connection_enabled_production == true ? {
          ANALYTICS_CONNECTION_STRING = (
            var.db_connection_use_entra_auth_production == true ? local.analytics_connection_string_entra : local.analytics_connection_string_serverauth
          )
        } : {},
        var.dxp_redis_cache_enabled == true ? {
          AMAIS_DXP_REDIS_INSTANCE_NAME     = "amais-dxp-prod"
          AMAIS_DXP_REDIS_CONNECTION_STRING = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--redis-connection-string)"
        } : {},
        local.enable_dxp_api_entra_auth_prod ? {
          AMAIS_DXP_CLIENT_AUTH_FLOW = "entraid-no-secrets"
        } : {},
        var.analytics_service_connection_enabled_production ? {
          AMAIS_DXP_ANALYTICS_SERVER_URL = "https://amais-dxp-analytics.azurewebsites.net"
        } : {},
        var.analytics_service_connection_enabled_production && local.enable_dxp_api_entra_auth_prod ? {
          AnalyticsClientOAuthSettings__ClientId = module.avm-res-managedidentity-userassignedidentity-app.resource.client_id
          AnalyticsClientOAuthSettings__Audience = "${local.dxp_api_identifier_uri.production}/.default"
        } : {},
        var.analytics_service_connection_enabled_production && local.enable_dxp_api_entra_auth_prod == false ? {
          AnalyticsClientOAuthSettings__ClientId     = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--analytics-client-oauth-settings-clientId-prod)"
          AnalyticsClientOAuthSettings__ClientSecret = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--analytics-client-oauth-settings-clientsecret-prod)"
          AnalyticsClientOAuthSettings__Audience     = "https://amais-dxp-analytics.azurewebsites.net/"
          AnalyticsClientOAuthSettings__OAuthUrl     = "https://amais-prod-uk.uk.auth0.com"
          AnalyticsClientOAuthSettings__TokenPath    = "/oauth/token"
        } : {},
        var.ingress_service_connection_enabled_production ? {
          AMAIS_DXP_INGRESS_SERVER_URL = "https://amais-dxp-ingress.azurewebsites.net"
        } : {},
        var.ingress_service_connection_enabled_production && local.enable_dxp_api_entra_auth_prod ? {
          IngressClientOAuthSettings__ClientId = module.avm-res-managedidentity-userassignedidentity-app.resource.client_id
          IngressClientOAuthSettings__Audience = "${local.dxp_api_identifier_uri.production}/.default"
        } : {},
        var.ingress_service_connection_enabled_production && local.enable_dxp_api_entra_auth_prod == false ? {
          IngressClientOAuthSettings__Audience     = "https://amais-dxp-ingress.azurewebsites.net/"
          IngressClientOAuthSettings__ClientId     = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--ingress-client-oauth-settings-clientId-prod)"
          IngressClientOAuthSettings__ClientSecret = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--ingress-client-oauth-settings-clientsecret-prod)"
          IngressClientOAuthSettings__OAuthUrl     = "https://amais-prod-uk.uk.auth0.com"
          IngressClientOAuthSettings__TokenPath    = "/oauth/token"
        } : {},
        var.notification_service_connection_enabled_production ? {
          AMAIS_DXP_NOTIFICATION_SERVER_URL = "https://amais-dxp-notf.azurewebsites.net"
        } : {},
        var.notification_service_connection_enabled_production && local.enable_dxp_api_entra_auth_prod ? {
          NotificationClientOAuthSettings__ClientId = module.avm-res-managedidentity-userassignedidentity-app.resource.client_id
          NotificationClientOAuthSettings__Audience = "${local.dxp_api_identifier_uri.production}/.default"
        } : {},
        var.notification_service_connection_enabled_production && local.enable_dxp_api_entra_auth_prod == false ? {
          NotificationClientOAuthSettings__Audience     = "https://amais-dxp-notf.azurewebsites.net/"
          NotificationClientOAuthSettings__ClientId     = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--notification-client-oauth-settings-clientId-prod)"
          NotificationClientOAuthSettings__ClientSecret = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--notification-client-oauth-settings-clientsecret-prod)"
          NotificationClientOAuthSettings__OAuthUrl     = "https://amais-prod-uk.uk.auth0.com"
          NotificationClientOAuthSettings__TokenPath    = "/oauth/token"
        } : {},
        var.report_service_connection_enabled_production ? {
          AMAIS_DXP_REPORT_SERVER_URL = "https://amais-dxp-report.azurewebsites.net"
        } : {},
        var.report_service_connection_enabled_production && local.enable_dxp_api_entra_auth_prod ? {
          ReportClientOAuthSettings__ClientId = module.avm-res-managedidentity-userassignedidentity-app.resource.client_id
          ReportClientOAuthSettings__Audience = "${local.dxp_api_identifier_uri.production}/.default"
        } : {},
        var.report_service_connection_enabled_production && local.enable_dxp_api_entra_auth_prod == false ? {
          ReportClientOAuthSettings__Audience     = "https://amais-dxp-report.azurewebsites.net/"
          ReportClientOAuthSettings__ClientId     = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--report-client-oauth-settings-clientId-prod)"
          ReportClientOAuthSettings__ClientSecret = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--report-client-oauth-settings-clientsecret-prod)"
          ReportClientOAuthSettings__OAuthUrl     = "https://amais-prod-uk.uk.auth0.com"
          ReportClientOAuthSettings__TokenPath    = "/oauth/token"
        } : {},
        local.enable_global_oauth_settings_prod ? {
          OAuthBehaviourSettings__CacheEnable                   = "true"
          OAuthBehaviourSettings__RetrieveTokenBeforeExpiration = "60"
          OAuthBehaviourSettings__SlidingExpirationTime         = "2419200"
        } : {},
        var.distilled_connection_enabled_production == true ? {
          DistilledSettings__IsEnable  = true
          DistilledSettings__AccessKey = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--distilled-settings-access-key)"
          DistilledSettings__SecretKey = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--distilled-settings-secret-key)"
          DistilledSettings__Location  = var.distilled_location
          DistilledSettings__WorkGroup = var.distilled_workgroup
        } : {},
        local.global_cosmos_db_connection_info,
        local.global_cosmos_db_connection_info_production,
        local.global_redis_cache_connection_info
      )
    }
    staging = {
      app_settings = merge(
        {
          ASPNETCORE_ENVIRONMENT = "Staging"
          DB_CONNECTION_STRING   = var.db_connection_use_entra_auth_staging == true ? local.db_connection_string_staging_entra : local.db_connection_string_staging_serverauth
          NLOG_CONNECTION_STRING = var.db_connection_use_entra_auth_staging == true ? local.nlog_db_connection_string_staging_entra : local.nlog_db_connection_string_staging_serverauth
          AZURE_CLIENT_ID        = module.avm-res-managedidentity-userassignedidentity-app-staging.resource.client_id
        },
        var.auth0_oauth_settings_enabled_staging == true ? {
          OauthSettings__AuthorityIssuer = "https://amais-dev-uk.uk.auth0.com/"
          OauthSettings__UrlToken        = "https://amais-dev-uk.uk.auth0.com/oauth/token"
          OauthSettings__UrlAuthorize    = "https://amais-dev-uk.uk.auth0.com/authorize"
          OauthSettings__Audience        = "https://${lower(local.app_name)}.azurewebsites.net/"
        } : {},
        var.elastic_search_settings_enabled == true ? {
          # TODO: Do we just add these as custom app settings in the root config for the web app?
          ElasticsearchSettings__ApiKey = join("", [
            "@Microsoft.KeyVault(VaultName=${local.kv_name};",
            "SecretName=amais-dxp--elk-api-key-staging)"
          ])
          ElasticsearchSettings__CloudId = join("", [
            "@Microsoft.KeyVault(VaultName=${local.kv_name};",
            "SecretName=amais-dxp--elk-cloud-id-staging)"
          ])
          ElasticsearchSettings__DataStream = "amais-staging-dxp-data-stream"
          ElasticsearchSettings__TenantDataStream = (
            var.elastic_search_tenant_data_stream_slot == "staging" ? "amais-{tenant}-dxp-data-stream" : ""
          )
          ElasticsearchSettings__IsEnableTenantDataStream = (
            var.elastic_search_tenant_data_stream_slot == "staging" ? "true" : "false"
          )
        } : {},
        var.analytics_db_connection_enabled_staging == true ? {
          ANALYTICS_CONNECTION_STRING = (
            var.db_connection_use_entra_auth_staging == true ? local.analytics_connection_string_staging_entra : local.analytics_connection_string_staging_serverauth
          )
        } : {},
        var.dxp_redis_cache_enabled == true ? {
          AMAIS_DXP_REDIS_INSTANCE_NAME     = "amais-dxp-staging"
          AMAIS_DXP_REDIS_CONNECTION_STRING = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--redis-connection-string)"
        } : {},
        local.enable_dxp_api_entra_auth_staging ? {
          AMAIS_DXP_CLIENT_AUTH_FLOW = "entraid-no-secrets"
        } : {},
        var.analytics_service_connection_enabled_staging ? {
          AMAIS_DXP_ANALYTICS_SERVER_URL = "https://amais-dxp-analytics-staging.azurewebsites.net"
        } : {},
        var.analytics_service_connection_enabled_staging && local.enable_dxp_api_entra_auth_staging ? {
          AMAIS_DXP_CLIENT_AUTH_FLOW             = "entraid-no-secrets"
          AnalyticsClientOAuthSettings__ClientId = module.avm-res-managedidentity-userassignedidentity-app-staging.resource.client_id
          AnalyticsClientOAuthSettings__Audience = "${local.dxp_api_identifier_uri.staging}/.default"
        } : {},
        var.analytics_service_connection_enabled_staging && local.enable_dxp_api_entra_auth_staging == false ? {
          AnalyticsClientOAuthSettings__ClientId     = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--analytics-client-oauth-settings-clientId-staging)"
          AnalyticsClientOAuthSettings__ClientSecret = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--analytics-client-oauth-settings-clientsecret-staging)"
          AnalyticsClientOAuthSettings__Audience     = "https://amais-dxp-analytics.azurewebsites.net/"
          AnalyticsClientOAuthSettings__OAuthUrl     = "https://amais-dev-uk.uk.auth0.com"
          AnalyticsClientOAuthSettings__TokenPath    = "/oauth/token"
        } : {},
        var.ingress_service_connection_enabled_staging ? {
          AMAIS_DXP_INGRESS_SERVER_URL = "https://amais-dxp-ingress-staging.azurewebsites.net"
        } : {},
        var.ingress_service_connection_enabled_staging && local.enable_dxp_api_entra_auth_staging ? {
          IngressClientOAuthSettings__ClientId = module.avm-res-managedidentity-userassignedidentity-app-staging.resource.client_id
          IngressClientOAuthSettings__Audience = "${local.dxp_api_identifier_uri.staging}/.default"
        } : {},
        var.ingress_service_connection_enabled_staging && local.enable_dxp_api_entra_auth_staging == false ? {
          IngressClientOAuthSettings__Audience     = "https://amais-dxp-ingress.azurewebsites.net/"
          IngressClientOAuthSettings__ClientId     = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--ingress-client-oauth-settings-clientId-staging)"
          IngressClientOAuthSettings__ClientSecret = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--ingress-client-oauth-settings-clientsecret-staging)"
          IngressClientOAuthSettings__OAuthUrl     = "https://amais-dev-uk.uk.auth0.com"
          IngressClientOAuthSettings__TokenPath    = "/oauth/token"
        } : {},
        var.notification_service_connection_enabled_staging ? {
          AMAIS_DXP_NOTIFICATION_SERVER_URL = "https://amais-dxp-notf-staging.azurewebsites.net"
        } : {},
        var.notification_service_connection_enabled_staging && local.enable_dxp_api_entra_auth_staging ? {
          NotificationClientOAuthSettings__ClientId = module.avm-res-managedidentity-userassignedidentity-app-staging.resource.client_id
          NotificationClientOAuthSettings__Audience = "${local.dxp_api_identifier_uri.staging}/.default"
        } : {},
        var.notification_service_connection_enabled_staging && local.enable_dxp_api_entra_auth_staging == false ? {
          NotificationClientOAuthSettings__Audience     = "https://amais-dxp-notf.azurewebsites.net/"
          NotificationClientOAuthSettings__ClientId     = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--notification-client-oauth-settings-clientId-staging)"
          NotificationClientOAuthSettings__ClientSecret = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--notification-client-oauth-settings-clientsecret-staging)"
          NotificationClientOAuthSettings__OAuthUrl     = "https://amais-dev-uk.uk.auth0.com"
          NotificationClientOAuthSettings__TokenPath    = "/oauth/token"
        } : {},
        var.report_service_connection_enabled_staging ? {
          AMAIS_DXP_REPORT_SERVER_URL = "https://amais-dxp-report-staging.azurewebsites.net"
        } : {},
        var.report_service_connection_enabled_staging && local.enable_dxp_api_entra_auth_staging ? {
          ReportClientOAuthSettings__ClientId = module.avm-res-managedidentity-userassignedidentity-app-staging.resource.client_id
          ReportClientOAuthSettings__Audience = "${local.dxp_api_identifier_uri.staging}/.default"
        } : {},
        var.report_service_connection_enabled_staging && local.enable_dxp_api_entra_auth_staging == false ? {
          ReportClientOAuthSettings__Audience     = "https://amais-dxp-report.azurewebsites.net/"
          ReportClientOAuthSettings__ClientId     = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--report-client-oauth-settings-clientId-staging)"
          ReportClientOAuthSettings__ClientSecret = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--report-client-oauth-settings-clientsecret-staging)"
          ReportClientOAuthSettings__OAuthUrl     = "https://amais-dev-uk.uk.auth0.com"
          ReportClientOAuthSettings__TokenPath    = "/oauth/token"
        } : {},
        local.enable_global_oauth_settings_staging ? {
          OAuthBehaviourSettings__CacheEnable                   = "true"
          OAuthBehaviourSettings__RetrieveTokenBeforeExpiration = "60"
          OAuthBehaviourSettings__SlidingExpirationTime         = "2419200"
        } : {},
        var.distilled_connection_enabled_staging == true ? {
          DistilledSettings__IsEnable  = true
          DistilledSettings__AccessKey = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--distilled-settings-access-key)"
          DistilledSettings__SecretKey = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--distilled-settings-secret-key)"
          DistilledSettings__Location  = var.distilled_location
          DistilledSettings__WorkGroup = var.distilled_workgroup
        } : {},
        local.global_cosmos_db_connection_info,
        local.global_cosmos_db_connection_info_staging,
        local.global_redis_cache_connection_info
      )
    }

  }
  app_sticky_settings_names = distinct(flatten([
    for k, v in merge(local.production_slot_map, local.staging_slot_map, local.additional_slots_map) :
    keys(v.app_settings)
  ]))
}
