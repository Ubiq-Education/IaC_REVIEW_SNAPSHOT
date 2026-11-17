locals {
  global_cosmos_db_connection_info = var.add_global_cosmos_db_connection_info == true ? {
    AZURE_COSMOS_PORT                 = "10350"
    AZURE_COSMOS_SCOPE                = "https://management.azure.com/.default"
    AZURE_COSMOS_CONTACTPOINT_CA      = "coscas-cnc-amais-dxp.cassandra.cosmos.azure.com"
    AZURE_COSMOS_CONTACTPOINT_EU      = "coscas-gwc-amais-dxp.cassandra.cosmos.azure.com"
    AZURE_COSMOS_CONTACTPOINT_UAE     = "coscas-uan-amais-dxp.cassandra.cosmos.azure.com"
    AZURE_COSMOS_CONTACTPOINT_UK      = "coscas-uks-amais-dxp.cassandra.cosmos.azure.com"
    AZURE_COSMOS_CONTACTPOINT_US      = "coscas-cus-amais-dxp.cassandra.cosmos.azure.com"
    AZURE_COSMOS_LISTKEYURL_CA        = "https://management.azure.com/subscriptions/c94f8a3d-8d0b-4660-85de-26004f233dbf/resourceGroups/Amais-DXP/providers/Microsoft.DocumentDB/databaseAccounts/coscas-cnc-amais-dxp/listKeys?api-version=2024-08-15"
    AZURE_COSMOS_LISTKEYURL_EU        = "https://management.azure.com/subscriptions/c94f8a3d-8d0b-4660-85de-26004f233dbf/resourceGroups/Amais-DXP/providers/Microsoft.DocumentDB/databaseAccounts/coscas-gwc-amais-dxp/listKeys?api-version=2024-08-15"
    AZURE_COSMOS_LISTKEYURL_UAE       = "https://management.azure.com/subscriptions/c94f8a3d-8d0b-4660-85de-26004f233dbf/resourceGroups/Amais-DXP/providers/Microsoft.DocumentDB/databaseAccounts/coscas-uan-amais-dxp/listKeys?api-version=2024-08-15"
    AZURE_COSMOS_LISTKEYURL_UK        = "https://management.azure.com/subscriptions/c94f8a3d-8d0b-4660-85de-26004f233dbf/resourceGroups/Amais-DXP/providers/Microsoft.DocumentDB/databaseAccounts/coscas-uks-amais-dxp/listKeys?api-version=2024-08-15"
    AZURE_COSMOS_LISTKEYURL_US        = "https://management.azure.com/subscriptions/c94f8a3d-8d0b-4660-85de-26004f233dbf/resourceGroups/Amais-DXP/providers/Microsoft.DocumentDB/databaseAccounts/coscas-cus-amais-dxp/listKeys?api-version=2024-08-15"
    AZURE_COSMOS_RESOURCEENDPOINT_CA  = "https://coscas-cnc-amais-dxp.documents.azure.com:443/"
    AZURE_COSMOS_RESOURCEENDPOINT_EU  = "https://coscas-gwc-amais-dxp.documents.azure.com:443/"
    AZURE_COSMOS_RESOURCEENDPOINT_UAE = "https://coscas-uan-amais-dxp.documents.azure.com:443/"
    AZURE_COSMOS_RESOURCEENDPOINT_UK  = "https://coscas-uks-amais-dxp.documents.azure.com:443/"
    AZURE_COSMOS_RESOURCEENDPOINT_US  = "https://coscas-cus-amais-dxp.documents.azure.com:443/"
    AZURE_COSMOS_USERNAME_CA          = "coscas-cnc-amais-dxp"
    AZURE_COSMOS_USERNAME_EU          = "coscas-gwc-amais-dxp"
    AZURE_COSMOS_USERNAME_UAE         = "coscas-uan-amais-dxp"
    AZURE_COSMOS_USERNAME_UK          = "coscas-uks-amais-dxp"
    AZURE_COSMOS_USERNAME_US          = "coscas-cus-amais-dxp"
  } : {}
  global_cosmos_db_connection_info_production = var.add_global_cosmos_db_connection_info == true ? {
    AZURE_COSMOS_CLIENTID = module.avm-res-managedidentity-userassignedidentity-app.resource.client_id
    AZURE_COSMOS_KEYSPACE = "amais_dxp"
  } : {}
  global_cosmos_db_connection_info_staging = var.add_global_cosmos_db_connection_info == true ? {
    AZURE_COSMOS_CLIENTID = module.avm-res-managedidentity-userassignedidentity-app-staging.resource.client_id
    AZURE_COSMOS_KEYSPACE = "amais_dxp_staging"
  } : {}
}
