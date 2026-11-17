locals {
  mi_dxp_api_roles = [
    "all",
    "analytics:audience",
    "analytics:conversion",
    "analytics:leadscore",
    "analytics:persona",
    "analytics:touchpoint",
    "audience:ai",
    "chatbot:ai",
    "get:abtest:totals",
    "get:conversion:by:time",
    "get:conversion:totals",
    "get:leadscore:by:time",
    "get:leadscore:totals:by:stage",
    "get:persona:by:time",
    "get:persona:totals",
    "get:personalization:totals",
    "get:touchpoint:by:time",
    "get:touchpoint:totals",
    "list:abtest:totals",
    "list:contacts",
    "list:conversions:by:time",
    "list:conversions:totals",
    "list:documents",
    "list:leadscores:totals:by:stage",
    "list:personalization:totals",
    "list:personas:by:time",
    "list:personas:link:subject",
    "list:top:leadscores:by:time",
    "list:top:personas:by:time",
    "list:touchpoints:by:time",
    "list:touchpoints:totals",
    "list:visitors:by:time",
    "post:interaction",
    "post:notification:emails",
    "preview:audience"
  ]
}

module "dxp-appservice" {
  source  = "api.controlmonkey.io/o-26drsisx9g/dxp-appservice/azurerm"
  version = "~>1.0"

  az_long_region                                     = "uksouth"
  webapp_name                                        = "Amais-DXP-SCHDLR"
  do_not_format_app_name                             = true
  use_existing_service_plan                          = true
  service_plan_name_override                         = "Amais-DXP-MD"
  app_stack_dotnet_version_staging                   = "v10.0"
  app_stack_dotnet_version_production                = "v10.0"
  analytics_db_connection_enabled_staging            = true
  analytics_db_connection_enabled_production         = true
  db_connection_use_entra_auth_staging               = true
  db_connection_use_entra_auth_production            = true
  dxp_redis_cache_enabled                            = true
  analytics_service_connection_enabled_staging       = true
  analytics_service_connection_enabled_production    = true
  ingress_service_connection_enabled_staging         = true
  ingress_service_connection_enabled_production      = true
  notification_service_connection_enabled_staging    = true
  notification_service_connection_enabled_production = true
  report_service_connection_enabled_staging          = true
  report_service_connection_enabled_production       = true
  distilled_connection_enabled_staging               = false
  distilled_connection_enabled_production            = true
  elastic_search_settings_enabled                    = true
  health_check_enabled                               = false
  mi_dxp_api_roles_staging                           = local.mi_dxp_api_roles
  mi_dxp_api_roles_production                        = local.mi_dxp_api_roles
  app_slots = {
    production = {
      app_settings = {
        Application                                        = "AMAIS_DXP_SCHDLR_SCHEDULER"
        DOTNET_ENVIRONMENT                                 = "Production"
        DXPAnalyticsSettings__IsEnable                     = "true"
        KEY_VAULT_URI                                      = "https://kv-uks-amaisdxp.vault.azure.net/"
        HUMANTIC_SERVER_URL                                = "https://api.humantic.ai"
        HumanticFetchPersonalitiesSettings__ApiKey         = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--humantic-fetch-personalities-settings-apikey)"
        HumanticFetchPersonalitiesSettings__IsEnable       = "true"
        ProcessGA4InteractionsSettings__IsEnable           = "true"
        ProcessLeadScoresSendEmailsSettings__IsEnable      = "true"
        Scheduler__DistilledJob                            = "0 15 0/1 * * ?"
        Scheduler__DXPAnalyticsJob                         = "0 0 6 * * ?"
        Scheduler__HumanticFetchPersonalitiesJob           = "0 45 0/1 * * ?"
        Scheduler__ProcessGA4InteractionsJob               = "0 0 2 * * ?"
        Scheduler__ProcessLeadScoresSendEmailsJob          = "0 0 1 ? * SUN"
        Scheduler__UpdateContactsWithGAInteractionsJob     = "0 0 5 ? * SUN"
        Scheduler__WarmUpLeadScoreReportEndpointsJob       = "0 0/10 * * * ?"
        Scheduler__WarmUpPersonaReportEndpointsJob         = "0 0/15 * * * ?"
        UpdateContactsWithGAInteractionsSettings__IsEnable = "true"
        WarmUpLeadScoreReportEndpointsSettings__IsEnable   = "false"
        WarmUpPersonaReportEndpointsSettings__IsEnable     = "false"
        DistilledSettings__Accounts__0__IsEnable           = "true"
        DistilledSettings__Accounts__0__TagId              = "ubiqeducation~thewalkerschool"
        DistilledSettings__Accounts__0__TenantName         = "TheWalkerSchool"
        DistilledSettings__Accounts__1__IsEnable           = "true"
        DistilledSettings__Accounts__1__TagId              = "ubiqeducation~cityandcountry"
        DistilledSettings__Accounts__1__TenantName         = "CityAndCountry"
        DistilledSettings__Accounts__2__IsEnable           = "true"
        DistilledSettings__Accounts__2__TagId              = "ubiqeducation~friendsselect"
        DistilledSettings__Accounts__2__TenantName         = "FriendsSelect"
        DistilledSettings__Accounts__3__IsEnable           = "true"
        DistilledSettings__Accounts__3__TagId              = "ubiqeducation~ubiq"
        DistilledSettings__Accounts__3__TenantName         = "Ubiq"
      }
    }
    staging = {
      app_settings = {
        Application                                        = "AMAIS_DXP_SCHDLR_SCHEDULER"
        DOTNET_ENVIRONMENT                                 = "Staging"
        DXPAnalyticsSettings__IsEnable                     = "true"
        KEY_VAULT_URI                                      = "https://kv-uks-amaisdxp.vault.azure.net/"
        HUMANTIC_SERVER_URL                                = "https://api.humantic.ai"
        HumanticFetchPersonalitiesSettings__ApiKey         = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--humantic-fetch-personalities-settings-apikey)"
        HumanticFetchPersonalitiesSettings__IsEnable       = "false"
        ProcessGA4InteractionsSettings__IsEnable           = "false"
        ProcessLeadScoresSendEmailsSettings__IsEnable      = "true"
        Scheduler__DXPAnalyticsJob                         = "0 0 0 * * ?"
        Scheduler__HumanticFetchPersonalitiesJob           = "0 * * * * ?"
        Scheduler__ProcessGA4InteractionsJob               = "0 0 0 * * ?"
        Scheduler__ProcessLeadScoresSendEmailsJob          = "0 0 1 ? * SAT"
        Scheduler__UpdateContactsWithGAInteractionsJob     = "0 0 3 ? * SAT"
        Scheduler__WarmUpLeadScoreReportEndpointsJob       = "* 0/30 * * * ?"
        Scheduler__WarmUpPersonaReportEndpointsJob         = "* 0/30 * * * ?"
        UpdateContactsWithGAInteractionsSettings__IsEnable = "false"
        WarmUpLeadScoreReportEndpointsSettings__IsEnable   = "false"
        WarmUpPersonaReportEndpointsSettings__IsEnable     = "false"
      }
    }
  }
}
