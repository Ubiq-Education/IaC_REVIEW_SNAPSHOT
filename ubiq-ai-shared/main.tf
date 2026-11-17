resource "random_id" "main" {
  byte_length = 16
}

module "short-region-lookup" {
  source         = "api.controlmonkey.io/o-26drsisx9g/short-region-lookup/azurerm"
  version        = "~>1.0.0"
  az_long_region = var.primary_region
}

module "short-region-lookup-additional" {
  for_each = toset(var.regions)

  source         = "api.controlmonkey.io/o-26drsisx9g/short-region-lookup/azurerm"
  version        = "~>1.0.0"
  az_long_region = each.key
}

module "amais-ai" {
  for_each = toset(var.regions)

  source                                = "api.controlmonkey.io/o-26drsisx9g/amais-ai/azurerm"
  version                               = "~>2.0"
  deployment_name                       = var.deployment_name
  random_deployment_name_suffix_enabled = true
  az_long_region                        = each.key
  ais_network_acl_default_action        = "Allow"
  ais_roles = {
    amais_apps = {
      principal_id         = data.azuread_group.amais_app_umi.object_id
      role_definition_name = "Cognitive Services OpenAI User"
    }
    dxp_apps = {
      principal_id         = data.azuread_group.dxp_app_umi.object_id
      role_definition_name = "Cognitive Services OpenAI User"
    }
    dxp_apps_staging = {
      principal_id         = data.azuread_group.dxp_app_umi_staging.object_id
      role_definition_name = "Cognitive Services OpenAI User"
    }
    ai_devs = {
      principal_id         = data.azuread_group.aidev.object_id
      role_definition_name = "Cognitive Services OpenAI User"
    }
    amais_apps_foundry_user = {
      principal_id         = data.azuread_group.amais_app_umi.object_id
      role_definition_name = "Foundry User"
    }
    dxp_apps_foundry_user = {
      principal_id         = data.azuread_group.dxp_app_umi.object_id
      role_definition_name = "Foundry User"
    }
    dxp_apps_staging_foundry_user = {
      principal_id         = data.azuread_group.dxp_app_umi_staging.object_id
      role_definition_name = "Foundry User"
    }
    ai_devs_foundry_user = {
      principal_id         = data.azuread_group.aidev.object_id
      role_definition_name = "Foundry User"
    }
  }
  key_vault_resource_id                          = module.avm-res-keyvault-vault[each.key].resource_id
  ais_srch_mi_resource_id                        = data.azurerm_user_assigned_identity.ais_srch.id
  log_analytics_workspace_resource_id            = data.azurerm_log_analytics_workspace.shared.id
  cognitive_deployments                          = local.cognitive_deployments_by_region[each.key]
  cognitive_account_customer_managed_key_enabled = false
  tags                                           = local.merged_tags
}

module "bunny_cdn_waf" {
  source  = "api.controlmonkey.io/o-26drsisx9g/cdn-waf/bunnynet"
  version = "~>1.0"
  pullzone_config = {
    name                  = "pz-amais-ai-${var.deployment_name}"
    cache_enabled         = false
    cache_expiration_time = 0
    cache_errors          = false
    cache_chunked         = false
    log_forward_enabled   = true
    log_forward_format    = "JSON"
    log_forward_port      = 31893
    log_forward_protocol  = "TCPEncrypted"
    log_forward_server    = "global.logging.amais.com"
    log_forward_token     = var.syslog_token
    origin = {
      type              = "OriginUrl"
      url               = module.amais-ai[local.primary_region.name].azure_openai_client_url
      middleware_script = var.bunny_pz_middleware_script_id != null ? var.bunny_pz_middleware_script_id : null
    }
    routing = {
      tier  = "Standard"
      zones = var.pullzone_zones
    }
  }
  pullzone_edge_rules = merge(
    local.ais_regional_origins,
    {
      add_response_headers = {
        description = "Add Response Headers"
        priority    = length(local.ais_regional_origins) + 3
        actions = [{
          type       = "SetResponseHeader"
          parameter1 = "amais-deployment"
          parameter2 = var.deployment_name
          parameter3 = null
        }]
        match_type = "MatchNone"
        triggers = [{
          type       = "ResponseHeader"
          match_type = "MatchAny"
          patterns   = ["*"]
          parameter1 = "amais-deployment"
          parameter2 = null
        }]
      }
    }
  )
  pullzone_shield_config = {
    ddos          = { mode = "Block" }
    waf           = { mode = "Log" }
    bot_detection = { mode = "Log" }
  }
}

resource "azurerm_dns_cname_record" "main" {
  provider            = azurerm.shared
  name                = local.custom_hostname
  zone_name           = data.azurerm_dns_zone.amais_com.name
  resource_group_name = data.azurerm_dns_zone.amais_com.resource_group_name
  ttl                 = 3600
  record              = module.bunny_cdn_waf.pullzone_default_hostname
  tags                = local.merged_tags
}

resource "time_sleep" "cdn_dns" {
  create_duration = "240s"

  triggers = {
    cdn_dns_fqdn = azurerm_dns_cname_record.main.fqdn
  }
}

resource "bunnynet_pullzone_hostname" "custom" {
  pullzone    = module.bunny_cdn_waf.pullzone.id
  name        = local.custom_fqdn
  tls_enabled = true
  force_ssl   = true

  depends_on = [time_sleep.cdn_dns]
}
