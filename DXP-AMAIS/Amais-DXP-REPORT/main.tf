module "dxp-appservice" {
  source  = "api.controlmonkey.io/o-26drsisx9g/dxp-appservice/azurerm"
  version = "~>1.0"

  az_long_region                             = "uksouth"
  webapp_name                                = "Amais-DXP-REPORT"
  do_not_format_app_name                     = true
  service_plan_name_override                 = "Amais-DXP-REPORT"
  app_stack_dotnet_version_staging           = "v10.0"
  app_stack_dotnet_version_production        = "v10.0"
  auth0_oauth_settings_enabled_staging       = true
  auth0_oauth_settings_enabled_production    = true
  db_connection_use_entra_auth_staging       = true
  db_connection_use_entra_auth_production    = true
  health_check_eviction_time_in_min          = 5
  elastic_search_settings_enabled            = true
  analytics_db_connection_enabled_staging    = true
  analytics_db_connection_enabled_production = true
  dxp_redis_cache_enabled                    = true
  app_slots = {
    production = {
      app_settings = {
        Application                                = "AMAIS_DXP_REPORT"
        EFCacheKeyPrefix_MD                        = "AMAIS_DXP_MD"
        WebAPICacheSettings__AbsoluteExpiration    = "600"
        WebAPICacheSettings__CacheEnable           = "true"
        WebAPICacheSettings__SlidingExpirationTime = "7200"
        AMAIS_DXP_RECOMENDATION_AI_SERVER_URL      = "https://amais-dxp-recommendation-ai.azurewebsites.net/"
        EntraId__AuthorityIssuer                   = "https://login.microsoftonline.com/bf3e1181-ffe9-40f7-aee4-11dc5fd642c6/"
        EntraId__Audience                          = "api://0899c8e5-addb-46b3-b8a5-240f1633ff59/"
      }
    }
    staging = {
      app_settings = {
        Application                                = "AMAIS_DXP_REPORT"
        EFCacheKeyPrefix_MD                        = "AMAIS_DXP_MD_STAGING"
        WebAPICacheSettings__AbsoluteExpiration    = "600"
        WebAPICacheSettings__CacheEnable           = "true"
        WebAPICacheSettings__SlidingExpirationTime = "7200"
        AMAIS_DXP_RECOMENDATION_AI_SERVER_URL      = "https://amais-dxp-recommendation-ai-staging.azurewebsites.net/"
        EntraId__AuthorityIssuer                   = "https://login.microsoftonline.com/bf3e1181-ffe9-40f7-aee4-11dc5fd642c6/"
        EntraId__Audience                          = "api://ce91d5ac-a24b-4173-b4f6-c30bbd6b660f/"
      }
    }
  }
}
