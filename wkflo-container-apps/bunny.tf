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
  count = coalesce(try(var.bunny_pullzone_config.add_pullzone, null), false) == true ? 1 : 0

  source  = "api.controlmonkey.io/o-26drsisx9g/cdn-waf/bunnynet"
  version = "~>1.1"
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
          url  = "https://${module.cae_app.container_app.output.properties.configuration.ingress.fqdn}"
        },
        try(module.clean_bunny_pullzone_config.object.origin, {})
      )
    },
    {
      # module requires routing tier to be set, so we set it to "Standard" by default
      routing = merge(
        { tier = "Standard" },
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
      disable_bot_detection_trusted_useragents = {
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
        # Ensure empty variable defaults match the default variable values in variables.tf for consistency
        {
          level = "Low"
        },
        # merge will overwrite the defaults with user provided values
        try(module.clean_bunny_pullzone_shield_config.object.ddos, {})
      )
      waf = merge(
        # Ensure empty variable defaults match the default variable values in variables.tf for consistency
        {
          mode                 = "Log",
          allowed_http_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
          rules_disabled       = []
          rules_logonly        = ["SHL-G8", "932235"]
        },
        # merge will overwrite the defaults with user provided values
        try(module.clean_bunny_pullzone_shield_config.object.waf, {})
      )
      bot_detection = merge(
        { mode = "Log" },
        # merge will overwrite the defaults with user provided values
        try(module.clean_bunny_pullzone_shield_config.object.bot_detection, {})
      )
      access_list = try(module.clean_bunny_pullzone_shield_config.object.access_list, [])
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
    # Only include additional rate limit rules if the tier supports it, baisc allows two rules so one more in addition to the base rule
    contains(["Advanced", "Business", "Enterprise"], try(module.clean_bunny_pullzone_shield_config.object.tier, "Basic")) ? {
      for k, v in var.bunny_pullzone_additional_rate_limit_rules :
      "${k}-additional" => v
      } : local.first_additional_rate_limit_key != null ? {
      "${local.first_additional_rate_limit_key}-additional" = var.bunny_pullzone_additional_rate_limit_rules[local.first_additional_rate_limit_key]
    } : {}
  )
}

resource "bunnynet_pullzone_hostname" "main" {
  for_each = var.bunny_hostnames

  pullzone    = module.bunny_cdn_waf[0].pullzone.id
  name        = each.value
  tls_enabled = true
  force_ssl   = true

  depends_on = [time_sleep.cdn_dns]
}
