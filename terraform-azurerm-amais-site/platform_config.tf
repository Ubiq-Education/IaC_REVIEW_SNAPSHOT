locals {
  static_amais_site_entity = {
    "friendly_name"          = var.site_name
    "templates_folder"       = local.templates_folder
    "amais_application_name" = local.amais_application_name
    "web_domains"            = join(",", var.web_domains)
    "region"                 = var.az_long_region
    "resource_group_name"    = azurerm_resource_group.main.name
    "sp_name"                = azurerm_service_plan.main.name # Ensure service plan is successfully created before creating the entity
    "app_name"               = local.app_name
    "app_name_lower"         = lower(local.app_name)
    "app_mi_name"            = local.app_mi_name
    "sql_fqdn"               = azurerm_mssql_server.main.fully_qualified_domain_name # Ensure SQL server is successfully created before creating the entity
    "sql_admin_name"         = var.sql_admin_login
    "sql_admin_secret_name"  = local.sql_admin_login_secret_name
    "sqldb_name"             = local.sqldb_name
    "key_vault_name"         = local.kv_name
    "storage_account_name"   = module.avm-res-storage-storageaccount.name                         # Read by the provision-from-baseline pipeline
    "storage_container_name" = module.avm-res-storage-storageaccount.containers["main_priv"].name # Read by the provision-from-baseline pipeline
    "production_url"         = local.production_url
    "web_app_os"             = lower(var.web_app_os)
    "dev_site"               = var.dev_site
  }
  amais_site_entity = merge(
    local.static_amais_site_entity,
    local.add_staging_slot ? {
      "staging_slot_name" = local.staging_slot_name
      "staging_url"       = local.staging_url
    } : {},
    var.bunny_cdn_enablement == "yes" ? {
      "bunny_pullzone_fqdn" = "${module.bunny_cdn_waf[0].pullzone_name}.${module.bunny_cdn_waf[0].pullzone.cdn_domain}"
      "bunny_pullzone_id"   = module.bunny_cdn_waf[0].pullzone.id
    } : {},
    var.sql_entra_login_only ? { "sql_auth" = "aad_only" } : { "sql_auth" = "server" },
    var.launch_date != null ? { "launch_date" = var.launch_date } : {}
  )
}

# Other sites already using this site key in AMAISSites (same RowKey under another subscription's PartitionKey).
# Automation treats the RowKey as the site's identity, so a duplicate must never be written. New-AMAISSiteConfig.ps1
# prevents it for generated configs; this catches a hand-written one. The data source does not follow continuation
# tokens, so it can miss a duplicate (fails open) but never blocks wrongly. No `select`: with a selector the provider
# drops entities that come back empty, which would hide a match. The check is not atomic with creating the entity:
# two configs using the same key applied at the same moment could both pass. Apostrophes in the key are doubled to
# keep the OData string literal valid (templates_folder_override is free text).
data "azurerm_storage_table_entities" "amais_site_key_in_use" {
  provider         = azurerm.shared
  storage_table_id = "https://st47860a55d730abc11df262.table.core.windows.net/Tables('AMAISSites')"
  filter           = "RowKey eq '${replace(lower(local.templates_folder), "'", "''")}' and PartitionKey ne '${var.sub_id}'"
}

resource "azurerm_storage_table_entity" "amais_site" {
  provider         = azurerm.shared
  storage_table_id = "https://st47860a55d730abc11df262.table.core.windows.net/Tables('AMAISSites')"
  partition_key    = var.sub_id
  row_key          = lower(local.templates_folder)
  entity           = local.amais_site_entity

  lifecycle {
    # The entity is the site's registration with the platform: one per site, created once with the site and only
    # replaced if the site key changes. Updates (entity changes) do not trigger onboarding. No condition: from
    # Terraform 1.16 a destroy plan evaluates the conditions of after_create triggers without the variables they refer
    # to; onboard_client_assets is switched off with enabled in actions.tf instead.
    action_trigger {
      events  = [after_create]
      actions = [action.azureactions_devops_pipeline_trigger.onboard_client_assets]
    }

    precondition {
      condition     = length(data.azurerm_storage_table_entities.amais_site_key_in_use.items) == 0
      error_message = "Site key '${lower(local.templates_folder)}' is already used in AMAISSites by a site in another subscription. Site keys (the templates folder) must be unique across subscriptions; New-AMAISSiteConfig.ps1 enforces this for generated configs."
    }

    ignore_changes = [
      entity["swap_lock"], entity["swap_lock@odata.type"],
      entity["dashboard_swap_request_time"], entity["dashboard_swap_request_time@odata.type"],
      entity["last_dashboard_release_to_staging_build_id"], entity["last_dashboard_release_to_staging_build_id@odata.type"],
      entity["last_dashboard_release_to_staging_time"], entity["last_dashboard_release_to_staging_time@odata.type"],
      entity["swap_lock_time_utc"], entity["swap_lock_time_utc@odata.type"],
      entity["swap_locked_by"], entity["swap_locked_by@odata.type"],
      entity["release_lock_active"], entity["release_lock_active@odata.type"],
      entity["release_lock_time_utc"], entity["release_lock_time_utc@odata.type"],
      entity["swap_action_lock_active"], entity["swap_action_lock_active@odata.type"],
      entity["swap_action_lock_time_utc"], entity["swap_action_lock_time_utc@odata.type"],
      entity["purge_action_lock_active"], entity["purge_action_lock_active@odata.type"],
      entity["purge_action_lock_time_utc"], entity["purge_action_lock_time_utc@odata.type"]
    ]
  }
}

resource "terraform_data" "web_domains" {
  input = join(",", var.web_domains)

  lifecycle {
    action_trigger {
      events  = [after_update]
      actions = [action.azureactions_devops_pipeline_trigger.configure_dxp]
    }
  }

  depends_on = [azurerm_storage_table_entity.amais_site]
}
