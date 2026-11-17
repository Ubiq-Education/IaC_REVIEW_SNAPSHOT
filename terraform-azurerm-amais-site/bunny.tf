# Use helper modules to clean up null values in the Bunny CDN configuration
# This allows to use the variable defaults in the Bunny module
module "clean_bunny_pullzone_config" {
  source = "./modules/clean_object_null_values"
  object = var.bunny_pullzone_config
}

module "clean_bunny_pullzone_shield_config" {
  source = "./modules/clean_object_null_values"
  object = var.bunny_pullzone_shield_config
}

module "bunny_cdn_waf" {
  count = var.bunny_cdn_enablement == "yes" ? 1 : 0

  source             = "api.controlmonkey.io/o-26drsisx9g/cdn-waf/bunnynet"
  version            = "~>1.1"
  x_azure_fdid_value = local.x_azure_fdid_value
  pullzone_config = merge(
    {
      name                 = local.bunny_pullzone_name
      log_forward_enabled  = true
      log_forward_format   = "JSON"
      log_forward_port     = 31893
      log_forward_protocol = "TCPEncrypted"
      log_forward_server   = "global.logging.amais.com"
      log_forward_token    = var.syslog_token
    },
    # Only set optimizer defaults when optimizer is being enabled, to avoid drift on sites that don't use it
    var.bunny_pullzone_config.optimizer_enabled == true ? {
      optimizer_enabled           = true
      optimizer_webp              = false
      optimizer_dynamic_image_api = false
      optimizer_burrow            = false
      optimizer_classes_force     = false
      optimizer_html_prerender    = false
      optimizer_minify_css        = false
      optimizer_minify_js         = false
      optimizer_smartimage        = false
      optimizer_watermark         = false
    } : {},
    module.clean_bunny_pullzone_config.object,
    # Add merged_origin last to ensure required internal properties are present
    {
      origin = merge(
        # type and url cannot be provided by the user of this root module
        {
          type = "OriginUrl"
          url  = local.production_webapp_url
        },
        try(module.clean_bunny_pullzone_config.object.origin, {})
      )
    },
    {
      # module requires routing tier to be set, so we set it to "Standard" by default
      routing = merge(
        { tier = "Standard", blocked_countries = [] },
        # merge will overwrite the defaults with user provided values
        try(module.clean_bunny_pullzone_config.object.routing, {})
      )
    }
  )
  pullzone_edge_rules = merge(
    {
      remove_x_powered_by = {
        description = "Remove x-powered-by header"
        priority    = 2
        actions = [{
          type       = "SetResponseHeader"
          parameter1 = "X-Powered-By"
          parameter2 = null
          parameter3 = null
        }]
        match_type = "MatchAny"
        triggers = [{
          type       = "ResponseHeader"
          match_type = "MatchAny"
          patterns   = ["*"]
          parameter1 = "X-Powered-By"
          parameter2 = null
        }]
      }
    },
    {
      disable_healthcheck_bot_detection = {
        description = "Disable bot detection for trusted user agents"
        priority    = 3
        actions = [{
          type       = "DisableShieldBotDetection"
          parameter1 = null
          parameter2 = null
          parameter3 = null
        }]
        match_type = "MatchAll"
        triggers = [
          {
            type       = "RequestHeader"
            match_type = "MatchAny"
            patterns   = ["<REDACTED>"]
            parameter1 = "User-Agent"
            parameter2 = null
          },
          {
            type       = "RequestMethod"
            match_type = "MatchAny"
            patterns   = ["GET", "POST", "PUT"]
            parameter1 = null
            parameter2 = null
          }
        ]
      }
    },
    # We've already confirmed that Bunny CDN is enabled using the count on the module
    !var.web_app_x_azure_fdid_lockdown ? {
      dynamic_assets_redirection = {
        description = "Dynamic assets redirection"
        priority    = 4
        actions = [{
          type       = "OriginUrl"
          parameter1 = "${local.production_webapp_url}/cdn%%{Url.Path}"
          parameter2 = null
          parameter3 = null
        }]
        match_type = "MatchAny"
        triggers = [{
          type       = "Url"
          match_type = "MatchAny"
          patterns   = ["https://${local.root_cdn_path_name}.${data.azurerm_dns_zone.website_amais_com.name}/*"]
          parameter1 = null
          parameter2 = null
        }]
      }
    } : {},
    {
      disable_static_assets_rate_limit = {
        description = "Disable rate limit for static assets"
        priority    = 5
        actions = [{
          type       = "DisableShieldRateLimiting"
          parameter1 = null
          parameter2 = null
          parameter3 = null
        }]
        match_type = "MatchAny"
        triggers = [{
          type       = "Url"
          match_type = "MatchAny"
          patterns   = ["https://${local.lower_site_name}.${data.azurerm_dns_zone.static_amais_com.name}/*"]
          parameter1 = null
          parameter2 = null
        }]
      }
    },
    {
      static_assets_redirection = {
        description = "Static assets redirection"
        priority    = 6
        actions = [{
          type       = "OriginUrl"
          parameter1 = trimsuffix(module.avm-res-storage-storageaccount.resource.output.properties.primaryEndpoints.web, " / ")
          parameter2 = null
          parameter3 = null
        }]
        match_type = "MatchAny"
        triggers = [{
          type       = "Url"
          match_type = "MatchAny"
          patterns   = ["https://${local.lower_site_name}.${data.azurerm_dns_zone.static_amais_com.name}/*"]
          parameter1 = null
          parameter2 = null
        }]
      }
    },
    local.add_staging_slot ? {
      staging_redirection = {
        description = "Staging redirection"
        priority    = 7
        actions = [{
          type       = "OriginUrl"
          parameter1 = local.staging_webapp_url
          parameter2 = null
          parameter3 = null
        }]
        match_type = "MatchAny"
        triggers = [{
          type       = "Url"
          match_type = "MatchAny"
          patterns   = ["https://${local.lower_site_name}-${local.staging_slot_name}.${data.azurerm_dns_zone.website_amais_com.name}/*"]
          parameter1 = null
          parameter2 = null
        }]
      }
    } : {},
    length(local.bot_detection_disable_paths) > 0 ? {
      disable_paths_bot_detection = {
        description = "Disable bot detection for paths"
        priority    = 8
        actions = [{
          type       = "DisableShieldBotDetection"
          parameter1 = null
          parameter2 = null
          parameter3 = null
        }]
        match_type = "MatchAll"
        triggers = [
          {
            type       = "Url"
            match_type = "MatchAny"
            patterns   = local.bot_detection_disable_paths
            parameter1 = null
            parameter2 = null
          }
        ]
      }
    } : {},
    length(local.waf_rules_disable_paths) > 0 ? {
      disable_paths_waf_rules = {
        description = "Disable WAF rules for paths"
        priority    = 9
        actions = [{
          type       = "DisableWAF"
          parameter1 = null
          parameter2 = null
          parameter3 = null
        }]
        match_type = "MatchAll"
        triggers = [
          {
            type       = "Url"
            match_type = "MatchAny"
            patterns   = local.waf_rules_disable_paths
            parameter1 = null
            parameter2 = null
          }
        ]
      }
    } : {},
    {
      disable_static_assets_bot_detection = {
        description = "Disable bot detection for static assets"
        priority    = 10
        actions = [{
          type       = "DisableShieldBotDetection"
          parameter1 = null
          parameter2 = null
          parameter3 = null
        }]
        match_type = "MatchAny"
        triggers = [{
          type       = "Url"
          match_type = "MatchAny"
          patterns   = ["https://${local.lower_site_name}.${data.azurerm_dns_zone.static_amais_com.name}/*"]
          parameter1 = null
          parameter2 = null
        }]
      }
    },
    # Loop through additional edge rules and adjust the priority so they are after the default rules
    # Use the rest of the map as is so that null values are passed through beacuse we want that in this case
    {
      for k, v in var.bunny_pullzone_additional_edge_rules :
      "${k}-additional" => merge(v, {
        priority = v.priority + 20
      })
    }
  )
  pullzone_shield_config = merge(
    # Only include tier and whitelabel if they have non-null values
    try(module.clean_bunny_pullzone_shield_config.object.tier, null) != null ? {
      tier = module.clean_bunny_pullzone_shield_config.object.tier
    } : {},
    try(module.clean_bunny_pullzone_shield_config.object.whitelabel, null) != null ? {
      whitelabel = module.clean_bunny_pullzone_shield_config.object.whitelabel
    } : {},
    {
      # module requires ddos and waf modes to be set, so we set them to "Log" by default
      # merge the mode property individually to avoid the issue where a user-provided object without mode removes the default
      ddos = merge(
        try(module.clean_bunny_pullzone_shield_config.object.ddos, {})
      )
      waf = merge(
        # Ensure empty variable defaults match the default variable values in variables.tf for consistency
        {
          mode                 = "Log",
          allowed_http_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
          rules_disabled       = ["952100", "953100", "953101", "953110", "953120", "DDoS-0ad5f8", "SHL-G8", "941160", "932125"]
          rules_logonly        = ["932235", "941100", "921130", "933120", "942100", "942550", "932370", "951120"]
        },
        # merge will overwrite the defaults with user provided values
        try(module.clean_bunny_pullzone_shield_config.object.waf, {})
      )
      bot_detection = merge(
        { mode = "Log" },
        # merge will overwrite the defaults with user provided values
        try(module.clean_bunny_pullzone_shield_config.object.bot_detection, {})
      )
      bot_categorization = try(module.clean_bunny_pullzone_shield_config.object.bot_categorization, local.bot_categorization)
      access_list        = try(module.clean_bunny_pullzone_shield_config.object.access_list, [])
    }
  )
  # Only include custom WAF rules if the tier supports it
  # Advanced tier supports 10 custom rules
  pullzone_shield_waf_rules = contains(["Advanced", "Business", "Enterprise"], try(module.clean_bunny_pullzone_shield_config.object.tier, "Basic")) ? merge(
    {
      for k, v in local.waf_rules_path_exclusions :
      k => {
        name            = "ExcludePath${upper(k)}"
        description     = "Excluded path to log only"
        transformations = ["LOWERCASE", "REMOVEWHITESPACE"]
        condition = {
          1 = {
            operator = v.operator
            value    = lower(v.value)
            variable = "REQUEST_URI"
          }
        }
        response = {
          action = "Allow"
        }
      }
    },
    {
      for k, v in var.bunny_pullzone_custom_waf_rules :
      "${k}-custom" => v
    }
  ) : {}
  pullzone_shield_rate_limit_rules = merge(
    var.bunny_pullzone_base_rate_limit_rule.enabled && try(coalesce(module.clean_bunny_pullzone_shield_config.object.waf.enabled, false), false) == true ? {
      base_rate_limit = {
        name            = "Base Rate Limit"
        description     = "Default rule for AMAIS sites"
        transformations = ["LOWERCASE"]
        condition = {
          request_uri = {
            operator = "BEGINSWITH"
            value    = "/"
            variable = "REQUEST_URI"
          }
        }
        limit = {
          requests = coalesce(var.bunny_pullzone_base_rate_limit_rule.requests_per_second, 1000)
          interval = 10
        }
        response = {
          # Max interval on the baisic tier is 60 seconds but use 30 minutes for higher tiers as a default
          # If the user has provided a block duration, use that instead and it will be validated by the provider
          interval = (
            contains(["Advanced", "Business", "Enterprise"], try(module.clean_bunny_pullzone_shield_config.object.tier, "Basic")) ?
            coalesce(var.bunny_pullzone_base_rate_limit_rule.block_duration_seconds, 60) :
            coalesce(var.bunny_pullzone_base_rate_limit_rule.block_duration_seconds, 60)
          )
        }
      }
    } : {},
    # Only include additional rate limit rules if the tier supports it, baisc allows two rules so one more in addition to the base rule
    contains(["Advanced", "Business", "Enterprise"], try(module.clean_bunny_pullzone_shield_config.object.tier, "Basic")) ? {
      for k, v in var.bunny_pullzone_additional_rate_limit_rules :
      "${k}-additional" => v
      } : local.first_additional_rate_limit_key != null ? {
      "${local.first_additional_rate_limit_key}-additional" = var.bunny_pullzone_additional_rate_limit_rules[local.first_additional_rate_limit_key]
    } : {}
  )
  pullzone_access_lists = merge(
    {
      ubiq_secure_access_gateways = {
        name    = "Ubiq secure access gateways"
        action  = "Bypass"
        type    = "IP"
        entries = [for gateway in module.ubiq_resources.secure_access_gw_pips : gateway.ip_address]
      }
    },
    var.google_bot_bypass_enabled ? {
      google_user_triggered_fetchers = {
        name    = "Google user-triggered fetchers"
        action  = "Bypass"
        type    = "CIDR"
        entries = module.ubiq_resources.google_user_triggered_fetcher_ips
      }
    } : {},
    var.semrush_bot_bypass_enabled ? {
      semrush = {
        name    = "Semrush IPs"
        action  = "Bypass"
        type    = "CIDR"
        entries = ["85.208.98.128/25"]
      }
    } : {},
    var.bunny_pullzone_custom_access_lists
  )
}

resource "bunnynet_pullzone_hostname" "custom" {
  for_each = merge(
    var.bunny_cdn_enablement == "yes" ? {
      cdn_root = { name = trimsuffix(azurerm_dns_cname_record.cdn_root[0].fqdn, ".") }
    } : {},
    var.bunny_cdn_enablement == "yes" && !var.web_app_x_azure_fdid_lockdown ? {
      cdn_root_subpath = { name = trimsuffix(azurerm_dns_cname_record.cdn_root_subpath[0].fqdn, ".") }
    } : {},
    var.bunny_cdn_enablement == "yes" && local.add_staging_slot ? {
      cdn_staging = { name = trimsuffix(azurerm_dns_cname_record.cdn_staging[0].fqdn, ".") }
    } : {},
    var.bunny_cdn_enablement == "yes" ? {
      cdn_ams = { name = trimsuffix(azurerm_dns_cname_record.cdn_ams.fqdn, ".") }
    } : {}
  )

  pullzone    = module.bunny_cdn_waf[0].pullzone.id
  name        = each.value.name
  tls_enabled = true
  force_ssl   = true

  depends_on = [time_sleep.cdn_dns, time_sleep.cdn_dns_ams]
}
