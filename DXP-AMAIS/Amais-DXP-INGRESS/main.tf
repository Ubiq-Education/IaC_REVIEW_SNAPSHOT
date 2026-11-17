module "dxp-appservice" {
  source  = "api.controlmonkey.io/o-26drsisx9g/dxp-appservice/azurerm"
  version = "~>1.0"

  az_long_region                          = "uksouth"
  webapp_name                             = local.webapp_name
  do_not_format_app_name                  = true
  service_plan_name_override              = "Amais-DXP-INGRESS"
  app_stack_dotnet_version_staging        = "v10.0"
  app_stack_dotnet_version_production     = "v10.0"
  auth0_oauth_settings_enabled_staging    = true
  auth0_oauth_settings_enabled_production = true
  db_connection_use_entra_auth_staging    = true
  db_connection_use_entra_auth_production = true
  waf_azure_fdid_lockdown = {
    x_azure_fdid_value = local.x_azure_fdid_value
    production         = false
    staging            = false
  }
  app_slots = {
    production = {
      app_settings = {
        Application                                        = "AMAIS_DXP_INGRESS"
        EFCacheKeyPrefix_MD                                = "AMAIS_DXP_MD"
        EventHubSettingsBulkInteractions__ConnectionString = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--bulkinteractions-eventhub-connection-string-prod)"
        EventHubSettingsBulkInteractions__Topic            = "bulk-interactions-ingress"
        EventHubSettingsInteractions__ConnectionString     = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--interactions-eventhub-connection-string-prod)"
        EventHubSettingsInteractions__Topic                = "interactions-ingress"
        EntraId__AuthorityIssuer                           = "https://login.microsoftonline.com/bf3e1181-ffe9-40f7-aee4-11dc5fd642c6/"
        EntraId__Audience                                  = "api://0899c8e5-addb-46b3-b8a5-240f1633ff59/"
      }
    }
    staging = {
      app_settings = {
        Application                                        = "AMAIS_DXP_INGRESS"
        EFCacheKeyPrefix_MD                                = "AMAIS_DXP_MD_STAGING"
        EventHubSettingsBulkInteractions__ConnectionString = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--bulkinteractions-eventhub-connection-string-staging)"
        EventHubSettingsBulkInteractions__Topic            = "bulk-interactions-staging-ingress"
        EventHubSettingsInteractions__ConnectionString     = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--interactions-eventhub-connection-string-staging)"
        EventHubSettingsInteractions__Topic                = "interactions-staging-ingress"
        EntraId__AuthorityIssuer                           = "https://login.microsoftonline.com/bf3e1181-ffe9-40f7-aee4-11dc5fd642c6/"
        EntraId__Audience                                  = "api://ce91d5ac-a24b-4173-b4f6-c30bbd6b660f/"
      }
    }
  }
  app_autoscale_rule_profiles = {
    profile1 = {
      name = "Profile 1"
      capacity = {
        default = 2
        maximum = 3
        minimum = 2
      }
      rules = {
        rule1 = {
          metric_trigger = {
            metric_name      = "CpuPercentage"
            metric_namespace = "microsoft.web/serverfarms"
            operator         = "GreaterThan"
            statistic        = "Average"
            threshold        = 30
            time_aggregation = "Average"
            time_grain       = "PT1M"
            time_window      = "PT10M"
          }
          scale_action = {
            cooldown  = "PT10M"
            direction = "Increase"
            type      = "ChangeCount"
            value     = "1"
          }
        }
        rule2 = {
          metric_trigger = {
            metric_name      = "CpuPercentage"
            metric_namespace = "microsoft.web/serverfarms"
            operator         = "LessThan"
            statistic        = "Average"
            threshold        = 15
            time_aggregation = "Average"
            time_grain       = "PT1M"
            time_window      = "PT30M"
          }
          scale_action = {
            cooldown  = "PT10M"
            direction = "Decrease"
            type      = "ChangeCount"
            value     = "1"
          }
        }
      }
      recurrence = {
        timezone = "W. Europe Standard Time"
        days     = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        hours    = [0]
        minutes  = [0]
      }
    }
  }
}
