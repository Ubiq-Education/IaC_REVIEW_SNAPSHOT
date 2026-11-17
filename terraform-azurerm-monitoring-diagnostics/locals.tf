locals {
  action_group_ids = {
    warning  = "/subscriptions/c94f8a3d-8d0b-4660-85de-26004f233dbf/resourceGroups/rg-uks-ubiq-shared-res/providers/Microsoft.Insights/actionGroups/UBIQWarning"
    global   = "/subscriptions/c94f8a3d-8d0b-4660-85de-26004f233dbf/resourceGroups/UBIQ/providers/Microsoft.Insights/actionGroups/UBIQ Global"
    critical = "/subscriptions/c94f8a3d-8d0b-4660-85de-26004f233dbf/resourceGroups/UBIQ/providers/Microsoft.Insights/actionGroups/UBIQCritical"
  }
  unparseable_resource_id_segments = [
    "/blobServices/",
    "/queueServices/",
    "/tableServices/",
    "/fileServices/",
  ]
  # Construct resource ids for storage account services based on the parent storage account id and the enabled services in the storage_account_services variable
  enabled_blob_service_ids    = { for k, v in var.diagnostics_storage_resource_ids : "${k}-blob" => "${v.id}/blobServices/default" if var.diagnostics_storage_resource_ids[k].blob_enabled }
  enabled_queue_service_ids   = { for k, v in var.diagnostics_storage_resource_ids : "${k}-queue" => "${v.id}/queueServices/default" if var.diagnostics_storage_resource_ids[k].queue_enabled }
  enabled_table_service_ids   = { for k, v in var.diagnostics_storage_resource_ids : "${k}-table" => "${v.id}/tableServices/default" if var.diagnostics_storage_resource_ids[k].table_enabled }
  enabled_file_service_ids    = { for k, v in var.diagnostics_storage_resource_ids : "${k}-file" => "${v.id}/fileServices/default" if var.diagnostics_storage_resource_ids[k].file_enabled }
  storage_account_service_ids = merge(local.enabled_blob_service_ids, local.enabled_queue_service_ids, local.enabled_table_service_ids, local.enabled_file_service_ids)
  # Collect all resource_id values from relavant other resources so we can ensure everything has diagnostic settings
  function_app_resource_ids    = { for k, v in var.function_apps : k => provider::azurerm::normalise_resource_id(v.resource_id) }
  traffic_manager_resource_ids = { for k, v in var.traffic_manager_profiles : k => provider::azurerm::normalise_resource_id(v.resource_id) }
  # Combine the original diagnostics_resource_ids with relavant other ids, ensuring all ids are normalised and there are no duplicates
  # Remove storage account ids in favour of child services
  resultant_resource_id_map = merge(
    var.diagnostics_resource_ids,
    local.storage_account_service_ids,
    local.function_app_resource_ids,
    local.traffic_manager_resource_ids,
  )
  resultant_log_category_groups = (
    length(var.enabled_log_categories) == 0 && length(var.enabled_log_category_groups) == 0 ?
    ["allLogs", "audit"] :
    var.enabled_log_category_groups
  )
  # SQL auditing storage account details
  # Reference supply of server and database ids to match variable validation logic and avoid count/for_each errors on new deployments
  sql_auditing_sa = (length(var.mssql.mssql_server_ids) > 0 || length(var.mssql.mssql_database_ids) > 0) ? { id = provider::azurerm::parse_resource_id(var.mssql.auditing_storage_account_id) } : {}
}
