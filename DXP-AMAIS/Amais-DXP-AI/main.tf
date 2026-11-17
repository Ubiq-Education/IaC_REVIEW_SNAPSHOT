module "dxp-appservice" {
  source  = "api.controlmonkey.io/o-26drsisx9g/dxp-appservice/azurerm"
  version = "~>1.0"

  az_long_region                          = "uksouth"
  webapp_name                             = "Amais-DXP-AI"
  service_plan_name_override              = "Amais-DXP-AI"
  app_stack_dotnet_version_staging        = "v10.0"
  app_stack_dotnet_version_production     = "v10.0"
  auth0_oauth_settings_enabled_staging    = true
  auth0_oauth_settings_enabled_production = true
  db_connection_use_entra_auth_staging    = true
  db_connection_use_entra_auth_production = true
  elastic_search_settings_enabled         = true
  dxp_redis_cache_enabled                 = true
  app_identity_roles_production = {
    eventhub_sender = {
      scope                = "/subscriptions/c94f8a3d-8d0b-4660-85de-26004f233dbf/resourceGroups/rg-uks-amais-pum/providers/Microsoft.EventHub/namespaces/evgns-uks-amais-pum/eventhubs/evh-amais-pum-usage-log"
      role_definition_name = "Azure Event Hubs Data Sender"
    }
  }
  app_identity_roles_staging = {
    eventhub_sender = {
      scope                = "/subscriptions/c94f8a3d-8d0b-4660-85de-26004f233dbf/resourceGroups/rg-uks-amais-pum-staging/providers/Microsoft.EventHub/namespaces/evgns-uks-amais-pum-staging/eventhubs/evh-amais-pum-usage-log"
      role_definition_name = "Azure Event Hubs Data Sender"
    }
  }
  app_slots = {
    production = {
      app_settings = {
        Application                                       = "AMAIS_DXP_AI"
        EFCacheKeyPrefix_MD                               = "AMAIS_DXP_MD"
        WebAPICacheSettings__AbsoluteExpiration           = "600"
        WebAPICacheSettings__CacheEnable                  = "true"
        WebAPICacheSettings__SlidingExpirationTime        = "7200"
        EntraId__AuthorityIssuer                          = "https://login.microsoftonline.com/bf3e1181-ffe9-40f7-aee4-11dc5fd642c6/"
        EntraId__Audience                                 = "api://0899c8e5-addb-46b3-b8a5-240f1633ff59/"
        AzureOpenAISettings__Url                          = "https://ais-uks-amais-dxp-ai-4fe8.cognitiveservices.azure.com/"
        AzureOpenAISettings__DeploymentName               = "o3-mini"
        ElasticsearchRestSettings__Url                    = "https://amais-dxp-elastic-prod.es.uksouth.azure.elastic-cloud.com"
        ElasticsearchRestSettings__UserName               = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--ai-elk-audience-username-prod)"
        ElasticsearchRestSettings__Password               = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--ai-elk-audience-password-prod)"
        UsageLogClientSettings__EventHubQualifiedFullName = "evgns-uks-amais-pum.servicebus.windows.net"
        UsageLogClientSettings__EvenHubName               = "evh-amais-pum-usage-log"
      }
    }
    staging = {
      app_settings = {
        Application                                       = "AMAIS_DXP_AI"
        EFCacheKeyPrefix_MD                               = "AMAIS_DXP_MD_STAGING"
        WebAPICacheSettings__AbsoluteExpiration           = "600"
        WebAPICacheSettings__CacheEnable                  = "true"
        WebAPICacheSettings__SlidingExpirationTime        = "7200"
        EntraId__AuthorityIssuer                          = "https://login.microsoftonline.com/bf3e1181-ffe9-40f7-aee4-11dc5fd642c6/"
        EntraId__Audience                                 = "api://ce91d5ac-a24b-4173-b4f6-c30bbd6b660f/"
        AzureOpenAISettings__Url                          = "https://ais-uks-amais-dxp-ai-staging-4fe8.cognitiveservices.azure.com/"
        AzureOpenAISettings__DeploymentName               = "o3-mini"
        ElasticsearchRestSettings__Url                    = "https://amais-dxp-elastic-staging.es.uksouth.azure.elastic-cloud.com"
        ElasticsearchRestSettings__UserName               = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--ai-elk-audience-username-staging)"
        ElasticsearchRestSettings__Password               = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--ai-elk-audience-password-staging)"
        UsageLogClientSettings__EventHubQualifiedFullName = "evgns-uks-amais-pum-staging.servicebus.windows.net"
        UsageLogClientSettings__EvenHubName               = "evh-amais-pum-usage-log"
      }
    }
  }
}
