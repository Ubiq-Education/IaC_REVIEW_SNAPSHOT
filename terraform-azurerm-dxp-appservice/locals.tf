locals {
  azure_tenant_id   = data.azurerm_client_config.current.tenant_id
  shared_sub_id     = "c94f8a3d-8d0b-4660-85de-26004f233dbf"
  subnet_identifier = element(split("-", data.azurerm_subscription.current.subscription_id), 0)
  central_dxp_rg    = "Amais-DXP"
  short_region      = module.short-region-lookup.short_region
  kv_name           = "kv-${local.short_region}-amaisdxp"
  service_plan_sku  = "P0v3"
  staging_slot_name = "staging"
  lower_app_name    = lower(var.webapp_name)
  formatted_name    = "${local.short_region}-${local.lower_app_name}"
  app_name          = var.do_not_format_app_name == true ? var.webapp_name : "app-${local.formatted_name}"
  sp_name           = var.service_plan_name_override != null ? var.service_plan_name_override : "asp-${local.formatted_name}"
  storage_accounts_map = var.mapped_storage_accounts == null ? {} : {
    for sa in var.mapped_storage_accounts : sa.name => sa
  }
  diag_settings_name                = "default_diagnostic_settings"
  enable_dxp_api_entra_auth_staging = var.mi_dxp_api_roles_staging != null && length(var.mi_dxp_api_roles_staging) > 0 ? true : false
  enable_dxp_api_entra_auth_prod    = var.mi_dxp_api_roles_production != null && length(var.mi_dxp_api_roles_production) > 0 ? true : false
  enable_global_oauth_settings_staging = (
    local.enable_dxp_api_entra_auth_staging ||
    var.analytics_service_connection_enabled_staging ||
    var.ingress_service_connection_enabled_staging ||
    var.notification_service_connection_enabled_staging ||
    var.report_service_connection_enabled_staging
  )
  enable_global_oauth_settings_prod = (
    local.enable_dxp_api_entra_auth_prod ||
    var.analytics_service_connection_enabled_production ||
    var.ingress_service_connection_enabled_production ||
    var.notification_service_connection_enabled_production ||
    var.report_service_connection_enabled_production
  )
  common_tags = {
    deployment_method = "terraform"
  }
  tags = merge(local.common_tags, var.tags)
  production_slot_map = tomap({
    for k, v in var.app_slots :
    k => merge(v, {
      app_settings = merge(
        lookup(local.app_slots, k, {}).app_settings,
        lookup(v, "app_settings", {})
      )
    }) if k == "production"
  })
  staging_slot_map = tomap({
    for k, v in var.app_slots :
    k => merge(v, {
      app_settings = merge(
        lookup(local.app_slots, k, {}).app_settings,
        lookup(v, "app_settings", {})
      )
    }) if k == local.staging_slot_name
  })
  additional_slots_map = tomap({
    for k, v in var.app_slots :
    k => merge(v, {
      app_settings = merge(
        lookup(local.app_slots, lookup(v, "app_settings_base_slot", "staging"), {}).app_settings,
        lookup(v, "app_settings", {})
      )
    }) if k != "production" && k != local.staging_slot_name && contains(keys(v), "app_settings_base_slot")
  })
  app_mi_ids = {
    production = module.avm-res-managedidentity-userassignedidentity-app.resource_id
    staging    = module.avm-res-managedidentity-userassignedidentity-app-staging.resource_id
  }
  dxp_api_environments = {
    dev = {
      name        = "DXP Platform Dev"
      description = "Development environment"
    }
    staging = {
      name        = "DXP Platform Staging"
      description = "Staging environment"
    }
    prod = {
      name        = "DXP Platform"
      description = "Production environment"
    }
  }
  dxp_api_identifier_uri = {
    staging    = local.enable_dxp_api_entra_auth_staging ? [for uri in data.azuread_application.dxp_api_staging[0].identifier_uris : uri if startswith(uri, "api://")][0] : null
    production = local.enable_dxp_api_entra_auth_prod ? [for uri in data.azuread_application.dxp_api_prod[0].identifier_uris : uri if startswith(uri, "api://")][0] : null
  }
  dxp_api_roles_staging = local.enable_dxp_api_entra_auth_staging ? {
    for role in var.mi_dxp_api_roles_staging : role => {
      app_role_id             = data.azuread_application.dxp_api_staging[0].app_role_ids[role]
      app_principal_object_id = module.avm-res-managedidentity-userassignedidentity-app-staging.principal_id
      resource_object_id      = data.azuread_service_principal.dxp_api_staging[0].object_id
    }
  } : {}
  dxp_api_roles_prod = local.enable_dxp_api_entra_auth_prod ? {
    for role in var.mi_dxp_api_roles_production : role => {
      app_role_id             = data.azuread_application.dxp_api_prod[0].app_role_ids[role]
      app_principal_object_id = module.avm-res-managedidentity-userassignedidentity-app.principal_id
      resource_object_id      = data.azuread_service_principal.dxp_api_prod[0].object_id
    }
  } : {}
}
