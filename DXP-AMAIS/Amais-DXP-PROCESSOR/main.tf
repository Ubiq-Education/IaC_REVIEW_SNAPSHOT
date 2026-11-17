module "dxp-appservice" {
  source  = "api.controlmonkey.io/o-26drsisx9g/dxp-appservice/azurerm"
  version = "~>1.0"

  az_long_region                             = "uksouth"
  webapp_name                                = "Amais-DXP-PROCESSOR"
  app_instance_count                         = 2
  do_not_format_app_name                     = true
  service_plan_name_override                 = "Amais-DXP-PROCESSOR"
  app_stack_dotnet_version_staging           = "v10.0"
  app_stack_dotnet_version_production        = "v10.0"
  db_connection_use_entra_auth_staging       = true
  db_connection_use_entra_auth_production    = true
  health_check_enabled                       = false
  elastic_search_settings_enabled            = true
  analytics_db_connection_enabled_staging    = true
  analytics_db_connection_enabled_production = true
  add_global_cosmos_db_connection_info       = true
  client_affinity_enabled                    = true
  app_slots = {
    production = {
      app_settings = {
        EFCacheKeyPrefix_MD                                       = "AMAIS_DXP_MD"
        DOTNET_ENVIRONMENT                                        = "Production"
        Logging__LogLevel__Default                                = "Information"
        "Logging__LogLevel__Microsoft.Hosting.Lifetime"           = "Information"
        RepositorySettings__ReadParallelism                       = "2"
        RepositorySettings__WriteParallelism                      = "2"
        EventHubSettingsAnalytics__BlobContainerName              = "0-eventhubprocessor-analytics"
        EventHubSettingsAnalytics__BlobStorageUri                 = "https://stuks86b31processorp.blob.core.windows.net/"
        EventHubSettingsAnalytics__ConnectionString               = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--analytics-eventhub-connection-string-prod)"
        EventHubSettingsAnalytics__ConsumerGroup                  = "analytics-service"
        EventHubSettingsAnalytics__EventsBeforeCheckpoint         = "10"
        EventHubSettingsAnalytics__MaxConcurrentProcessing        = "1"
        EventHubSettingsAnalytics__Topic                          = "analytics-ingress"
        EventHubSettingsBulkInteractions__BlobContainerName       = "0-eventhubprocessor-bulk-interactions"
        EventHubSettingsBulkInteractions__BlobStorageUri          = "https://stuks86b31processorp.blob.core.windows.net/"
        EventHubSettingsBulkInteractions__ConnectionString        = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--bulkinteractions-eventhub-connection-string-prod)"
        EventHubSettingsBulkInteractions__ConsumerGroup           = "bulk-interations-service"
        EventHubSettingsBulkInteractions__EventsBeforeCheckpoint  = "10"
        EventHubSettingsBulkInteractions__MaxConcurrentProcessing = "1"
        EventHubSettingsBulkInteractions__Topic                   = "bulk-interactions-ingress"
        EventHubSettingsInteractions__BlobContainerName           = "0-eventhubprocessor-interactions"
        EventHubSettingsInteractions__BlobStorageUri              = "https://stuks86b31processorp.blob.core.windows.net/"
        EventHubSettingsInteractions__ConnectionString            = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--interactions-eventhub-connection-string-prod)"
        EventHubSettingsInteractions__ConsumerGroup               = "interaction-service"
        EventHubSettingsInteractions__EventsBeforeCheckpoint      = "10"
        EventHubSettingsInteractions__Topic                       = "interactions-ingress"
      }
    }
    staging = {
      app_settings = {
        EFCacheKeyPrefix_MD                                       = "AMAIS_DXP_MD_STAGING"
        DOTNET_ENVIRONMENT                                        = "Staging"
        Logging__LogLevel__Default                                = "Information"
        "Logging__LogLevel__Microsoft.Hosting.Lifetime"           = "Information"
        RepositorySettings__ReadParallelism                       = "2"
        RepositorySettings__WriteParallelism                      = "2"
        EventHubSettingsAnalytics__BlobContainerName              = "0-eventhubprocessor-analytics"
        EventHubSettingsAnalytics__BlobStorageUri                 = "https://stuks86b31processors.blob.core.windows.net/"
        EventHubSettingsAnalytics__ConnectionString               = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--analytics-eventhub-connection-string-staging)"
        EventHubSettingsAnalytics__ConsumerGroup                  = "analytics-service"
        EventHubSettingsAnalytics__EventsBeforeCheckpoint         = "10"
        EventHubSettingsAnalytics__MaxConcurrentProcessing        = "1"
        EventHubSettingsAnalytics__Topic                          = "analytics-staging-ingress"
        EventHubSettingsBulkInteractions__BlobContainerName       = "0-eventhubprocessor-bulk-interactions"
        EventHubSettingsBulkInteractions__BlobStorageUri          = "https://stuks86b31processors.blob.core.windows.net/"
        EventHubSettingsBulkInteractions__ConnectionString        = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--bulkinteractions-eventhub-connection-string-staging)"
        EventHubSettingsBulkInteractions__ConsumerGroup           = "bulk-interations-service"
        EventHubSettingsBulkInteractions__EventsBeforeCheckpoint  = "10"
        EventHubSettingsBulkInteractions__MaxConcurrentProcessing = "1"
        EventHubSettingsBulkInteractions__Topic                   = "bulk-interactions-staging-ingress"
        EventHubSettingsInteractions__BlobContainerName           = "0-eventhubprocessor-interactions"
        EventHubSettingsInteractions__BlobStorageUri              = "https://stuks86b31processors.blob.core.windows.net/"
        EventHubSettingsInteractions__ConnectionString            = "@Microsoft.KeyVault(VaultName=kv-uks-amaisdxp;SecretName=amais-dxp--interactions-eventhub-connection-string-staging)"
        EventHubSettingsInteractions__ConsumerGroup               = "interaction-service"
        EventHubSettingsInteractions__EventsBeforeCheckpoint      = "10"
        EventHubSettingsInteractions__Topic                       = "interactions-staging-ingress"
      }
    }
  }
}

resource "azurerm_role_assignment" "production_storage" {
  scope                = "/subscriptions/c94f8a3d-8d0b-4660-85de-26004f233dbf/resourceGroups/Amais-DXP/providers/Microsoft.Storage/storageAccounts/stuks86b31processorp"
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.dxp-appservice.production_identity_principal_id
}

resource "azurerm_role_assignment" "staging_storage" {
  scope                = "/subscriptions/c94f8a3d-8d0b-4660-85de-26004f233dbf/resourceGroups/Amais-DXP/providers/Microsoft.Storage/storageAccounts/stuks86b31processors"
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.dxp-appservice.staging_identity_principal_id
}
