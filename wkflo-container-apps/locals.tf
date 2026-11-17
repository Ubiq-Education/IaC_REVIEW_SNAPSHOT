locals {
  sub_id               = "4ef55ff0-c50a-4146-8d6f-08e9e29defc9"
  app_name             = "${lower(var.name)}-${lower(var.environment)}"
  ignore_image_version = var.environment == "prod" ? false : var.ignore_image_version # Force image version specification in prod
  tags = merge(
    {
      deployment_method = "terraform"
      environment       = var.environment
      cost_center       = "WKFLO"
    }, var.tags
  )
  # Add central key vault uri as env var if any access is enabled
  central_key_vault_access_enabled = var.central_key_vault_key_access_enabled || var.central_key_vault_secret_access_enabled
  # Add default http scale rule if no other scale rules supplied
  http_scale_rules = (
    length(var.http_scale_rules) > 0 ? var.http_scale_rules :
    length(var.tcp_scale_rules) > 0 || length(var.custom_scale_rules) > 0 ? [] : [
      {
        name                = "http-rule"
        concurrent_requests = 10
      }
    ]
  )
  cae_id                         = try(var.cae[var.azure_long_region].resource.id, null)
  cae_default_domain             = try(var.cae[var.azure_long_region].resource.default_domain, null)
  cae_custom_domain              = try(var.cae[var.azure_long_region].resource.custom_domain, null)
  cae_key_vault_id               = try(var.cae[var.azure_long_region].key_vault_resources.id, null)
  resource_group_name            = try(var.cae[var.azure_long_region].app_resource_group_name, null)
  cae_log_analytics_workspace_id = try(var.cae[var.azure_long_region].law_resources.id, null)
  cae_identity                   = try(var.cae[var.azure_long_region].identities, null)
  cae_wkflo_mssql_resource       = try(var.cae[var.azure_long_region].mssql_resources["wkflo"], null)
  cae_postgresql_resource        = try(var.cae[var.azure_long_region].postgresql_resources, null)
  cae_storeage_account           = try(var.cae[var.azure_long_region].storage_accounts, null)
  signalr_resource               = try(var.cae[var.azure_long_region].signalr_resources, null)
  signalr_fqdn = (
    try(local.signalr_resource.custom_fqdn, "none") != "none" ?
    local.signalr_resource.custom_fqdn :
    local.signalr_resource.hostname
  )
  # Generate AI subscription role assignments from discovered subscriptions
  ai_sub_roles = var.azure_ai_model_access_enabled ? {
    for s in data.azurerm_subscriptions.ai_subs[0].subscriptions : s.subscription_id => {
      "${s.subscription_id}_cognitive_services_openai_user" = {
        scope                = s.id
        role_definition_name = "Cognitive Services OpenAI User"
      }
      "${s.subscription_id}_azure_ai_user" = {
        scope                = s.id
        role_definition_name = "Foundry User"
      }
      "${s.subscription_id}_cognitive_services_speech_user" = {
        scope                = s.id
        role_definition_name = "Cognitive Services Speech User"
      }
    }
  } : {}
  # Flatten the nested map structure for easier merging
  flat_ai_sub_roles = merge([
    for sub_map in values(local.ai_sub_roles) : sub_map
  ]...)
  elastic_search_url = {
    staging = "https://wkflo-elastic-staging-f30e4b.es.northeurope.azure.elastic.cloud:443"
    prod    = "https://wkflo-elastic-prod-c038ca.es.northeurope.azure.elastic.cloud:443"
  }
  serilog_elastic_search_url = {
    staging = "https://wkflo-elastic-staging-f30e4b.es.northeurope.azure.elastic.cloud:443"
    prod    = "https://wkflo-elastic-prod-c038ca.es.northeurope.azure.elastic.cloud:443"
  }
  eis_elastic_search_url = {
    staging = "https://amais-ai-elastic-staging-e10fbe.es.northeurope.azure.elastic.cloud:443"
    prod    = "https://amais-ai-elastic-prod-c6ef6f.es.northeurope.azure.elastic.cloud:443"
  }
  # DXP client
  dxp_client = {
    staging = {
      ingress_url               = "https://ingress-staging.dxp.amais.com"
      md_url                    = "https://amais-dxp-md-staging.azurewebsites.net"
      report_url                = "https://amais-dxp-report-staging.azurewebsites.net"
      mi_resource_id            = "/subscriptions/c94f8a3d-8d0b-4660-85de-26004f233dbf/resourceGroups/rg-uks-dxp-client-resources/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-app-uks-wkflo-dxp-client-staging"
      mi_client_id              = "90acbd0f-86f8-4725-912f-0dc3e056d6aa"
      api_application_object_id = "0cf3e507-264e-444d-958e-1dd75b6c1615"
    }
    prod = {
      ingress_url               = "https://ingress.dxp.amais.com"
      md_url                    = "https://amais-dxp-md.azurewebsites.net"
      report_url                = "https://amais-dxp-report.azurewebsites.net"
      mi_resource_id            = "/subscriptions/c94f8a3d-8d0b-4660-85de-26004f233dbf/resourceGroups/rg-uks-dxp-client-resources/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-app-uks-wkflo-dxp-client-prod"
      mi_client_id              = "fc79c506-4909-48f1-ba9b-855bb5469db6"
      api_application_object_id = "3503d7d2-282c-4d94-b449-0c579899efd3"
    }
  }
  # The WKFLO DXP client managed identity is attached when any DXP client (Ingress/MasterData or Report) is enabled
  dxp_client_identity_enabled = var.dxp_client_enabled || var.dxp_report_client_enabled
  dxp_api_identifier_uri      = local.dxp_client_identity_enabled ? [for uri in data.azuread_application.dxp_api[0].identifier_uris : uri if startswith(uri, "api://")][0] : null
  # Bunny defaults
  bunny_pullzone_name = "pz-${local.app_name}-${lower(substr(random_id.main.hex, 0, 4))}"
  # For selecting only the first rule if using the Basic tier for Bunny Shield
  first_additional_rate_limit_key = length(keys(var.bunny_pullzone_additional_rate_limit_rules)) > 0 ? keys(var.bunny_pullzone_additional_rate_limit_rules)[0] : null
  bot_detection_disable_paths = distinct(concat(
    [],
    var.bot_detection_disable_paths
  ))
  # Adds an edge rule to disable WAF for specified paths
  # Better to use WAF rule exclusions where possible (local.waf_rules_path_exclusions)
  waf_rules_disable_paths = distinct(concat(
    [],
    var.waf_rules_disable_paths
  ))
  waf_rules_path_exclusions = {}
}
