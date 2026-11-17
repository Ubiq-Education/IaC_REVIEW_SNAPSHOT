module "bunny_cdn_waf" {
  source  = "api.controlmonkey.io/o-26drsisx9g/cdn-waf/bunnynet"
  version = "~>1.1"

  x_azure_fdid_value = local.x_azure_fdid_value
  pullzone_config = {
    name                  = local.bunny_pullzone_name
    cache_enabled         = false
    cache_expiration_time = 0
    cache_errors          = false
    cache_chunked         = false
    block_root_path       = true
    log_forward_enabled   = true
    log_forward_format    = "JSON"
    log_forward_port      = 31893
    log_forward_protocol  = "TCPEncrypted"
    log_forward_server    = "global.logging.amais.com"
    log_forward_token     = var.syslog_token
    origin = {
      type = "OriginUrl"
      url  = "https://${lower(local.webapp_name)}.azurewebsites.net"
    }
    routing = {
      tier = "Standard"
    }
  }
  pullzone_edge_rules = {
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
    disable_healthcheck_bot_detection = {
      description = "Disable bot detection for healthcheck"
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
          type       = "Url"
          match_type = "MatchAny"
          patterns   = ["*/api/v1/healthcheck"]
          parameter1 = null
          parameter2 = null
        },
        {
          type       = "RequestMethod"
          match_type = "MatchAny"
          patterns   = ["GET"]
          parameter1 = null
          parameter2 = null
        }
      ]
    }
    disable_amais_bot_detection = {
      description = "Disable bot detection for AMAIS requests"
      priority    = 4
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
          patterns   = ["*/api/v1/interaction-with-ip"]
          parameter1 = null
          parameter2 = null
        },
        {
          type       = "RequestMethod"
          match_type = "MatchAny"
          patterns   = ["POST"]
          parameter1 = null
          parameter2 = null
        },
        {
          type       = "RequestHeader"
          match_type = "MatchAny"
          patterns   = ["*"]
          parameter1 = "amais-dxp-api-key"
          parameter2 = null
        }
        ,
        {
          type       = "RequestHeader"
          match_type = "MatchAny"
          patterns   = ["*"]
          parameter1 = "amais-dxp-tenant-name"
          parameter2 = null
        },
        {
          type       = "RequestHeader"
          match_type = "MatchAny"
          patterns   = ["*"]
          parameter1 = "amais-dxp-domain"
          parameter2 = null
        }
      ]
    }
    staging_redirection = {
      description = "Staging redirection"
      priority    = 5
      actions = [{
        type       = "OriginUrl"
        parameter1 = "https://${lower(local.webapp_name)}-staging.azurewebsites.net"
        parameter2 = null
        parameter3 = null
      }]
      match_type = "MatchAny"
      triggers = [{
        type       = "Url"
        match_type = "MatchAny"
        patterns   = ["https://${local.dns_alias_staging_name}.${local.dns_alias_zone_name}/*"]
        parameter1 = null
        parameter2 = null
      }]
    }
    block_no_api_key = {
      description = "Block missing API key"
      priority    = 6
      actions = [{
        type       = "BlockRequest"
        parameter1 = null
        parameter2 = null
        parameter3 = null
      }]
      match_type = "MatchAll"
      triggers = [
        {
          type       = "RequestMethod"
          match_type = "MatchAny"
          patterns   = ["GET", "POST"]
          parameter1 = null
          parameter2 = null
        },
        {
          type       = "RequestHeader"
          match_type = "MatchNone"
          patterns   = ["*"]
          parameter1 = "amais-dxp-api-key"
          parameter2 = null
        }
      ]
    }
    block_no_tenant_name = {
      description = "Block missing tenant name"
      priority    = 7
      actions = [{
        type       = "BlockRequest"
        parameter1 = null
        parameter2 = null
        parameter3 = null
      }]
      match_type = "MatchAll"
      triggers = [
        {
          type       = "RequestMethod"
          match_type = "MatchAny"
          patterns   = ["GET", "POST"]
          parameter1 = null
          parameter2 = null
        },
        {
          type       = "RequestHeader"
          match_type = "MatchNone"
          patterns   = ["*"]
          parameter1 = "amais-dxp-tenant-name"
          parameter2 = null
        }
      ]
    }
    block_no_customer_domain = {
      description = "Block missing customer domain"
      priority    = 8
      actions = [{
        type       = "BlockRequest"
        parameter1 = null
        parameter2 = null
        parameter3 = null
      }]
      match_type = "MatchAll"
      triggers = [
        {
          type       = "RequestMethod"
          match_type = "MatchAny"
          patterns   = ["GET", "POST"]
          parameter1 = null
          parameter2 = null
        },
        {
          type       = "RequestHeader"
          match_type = "MatchNone"
          patterns   = ["*"]
          parameter1 = "amais-dxp-domain"
          parameter2 = null
        }
      ]
    }
  }
  pullzone_shield_config = {
    tier = "Advanced"
    ddos = {
      mode             = "Block"
      level            = "Low"
      challenge_window = 3600
    }
    waf = {
      enabled              = true
      mode                 = "Block"
      allowed_http_methods = ["POST", "GET", "OPTIONS"]
      rules_disabled       = []
      rules_logonly        = ["932235", "932125", "932370", "932380"]
    }
    bot_detection = {
      mode                    = "Log"
      request_integrity       = 1
      ip_sensitivity          = 1
      fingerprint_sensitivity = 1
      fingerprint_aggression  = 1
    }
  }
  pullzone_shield_rate_limit_rules = {
    base_rate_limit = {
      name            = "Base Rate Limit"
      description     = "Base rate limit"
      transformations = ["LOWERCASE"]
      condition = {
        request_uri = {
          operator = "BEGINSWITH"
          variable = "REQUEST_URI"
          value    = "/"
        }
      }
      limit = {
        requests = 2000
        interval = 10
      }
      response = {
        interval = 60
      }
    }
  }
}

resource "bunnynet_pullzone_hostname" "custom" {
  pullzone    = module.bunny_cdn_waf.pullzone.id
  name        = "${local.dns_alias_name}.${local.dns_alias_zone_name}"
  tls_enabled = true
  force_ssl   = true

  depends_on = [time_sleep.dns]
}

resource "bunnynet_pullzone_hostname" "custom-staging" {
  pullzone    = module.bunny_cdn_waf.pullzone.id
  name        = "${local.dns_alias_staging_name}.${local.dns_alias_zone_name}"
  tls_enabled = true
  force_ssl   = true

  depends_on = [time_sleep.dns]
}
