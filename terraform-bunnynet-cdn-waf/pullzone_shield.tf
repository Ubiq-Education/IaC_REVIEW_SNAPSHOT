resource "bunnynet_pullzone_shield" "main" {
  count = var.pullzone_shield_enabled ? 1 : 0

  pullzone                  = bunnynet_pullzone.main.id
  tier                      = var.pullzone_shield_config.tier
  whitelabel                = var.pullzone_shield_config.tier != "Basic" ? var.pullzone_shield_config.whitelabel : null
  whitelabel_block          = var.pullzone_shield_config.tier != "Basic" ? var.pullzone_shield_config.whitelabel_block : null
  whitelabel_challenge      = var.pullzone_shield_config.tier != "Basic" ? var.pullzone_shield_config.whitelabel_challenge : null
  whitelabel_rate_limit     = var.pullzone_shield_config.tier != "Basic" ? var.pullzone_shield_config.whitelabel_rate_limit : null
  upload_scanning_antivirus = var.pullzone_shield_config.tier != "Basic" ? var.pullzone_shield_config.upload_scanning_antivirus : null
  upload_scanning_csam      = var.pullzone_shield_config.upload_scanning_csam

  ddos {
    level            = var.pullzone_shield_config.ddos.level
    challenge_window = var.pullzone_shield_config.ddos.challenge_window
  }

  waf {
    enabled                       = var.pullzone_shield_config.waf.enabled
    allowed_http_methods          = var.pullzone_shield_config.waf.allowed_http_methods
    allowed_http_versions         = var.pullzone_shield_config.waf.allowed_http_versions
    allowed_request_content_types = var.pullzone_shield_config.waf.allowed_request_content_types
    blocking_sensitivity          = var.pullzone_shield_config.waf.blocking_sensitivity
    body_limit_request            = var.pullzone_shield_config.waf.body_limit_request
    body_limit_response           = var.pullzone_shield_config.waf.body_limit_response
    detection_sensitivity         = var.pullzone_shield_config.waf.detection_sensitivity
    execution_sensitivity         = var.pullzone_shield_config.waf.execution_sensitivity
    log_headers                   = var.pullzone_shield_config.waf.log_headers
    log_headers_excluded          = var.pullzone_shield_config.waf.log_headers_excluded
    mode                          = var.pullzone_shield_config.waf.mode
    realtime_threat_intelligence  = var.pullzone_shield_config.tier != "Basic" ? var.pullzone_shield_config.waf.realtime_threat_intelligence : null
    rules_disabled                = var.pullzone_shield_config.waf.rules_disabled
    rules_logonly                 = var.pullzone_shield_config.waf.rules_logonly
  }

  dynamic "bot_detection" {
    for_each = var.pullzone_shield_config.tier != "Basic" ? [1] : []
    content {
      complex_fingerprinting  = var.pullzone_shield_config.bot_detection.complex_fingerprinting
      fingerprint_aggression  = var.pullzone_shield_config.bot_detection.fingerprint_aggression
      fingerprint_sensitivity = var.pullzone_shield_config.bot_detection.fingerprint_sensitivity
      ip_sensitivity          = var.pullzone_shield_config.bot_detection.ip_sensitivity
      mode                    = var.pullzone_shield_config.bot_detection.mode
      request_integrity       = var.pullzone_shield_config.bot_detection.request_integrity
    }
  }

  bot_categorization = local.bot_categorization_ordered != [] ? local.bot_categorization_ordered : null

  dynamic "access_list" {
    for_each = var.pullzone_shield_config.access_list
    content {
      action = access_list.value.action
      id     = access_list.value.id
    }
  }
}

resource "time_sleep" "bunnynet_pullzone_shield" {
  count = var.pullzone_shield_enabled ? 1 : 0

  create_duration = "60s"

  triggers = {
    shield_id = bunnynet_pullzone_shield.main[0].id
  }
}

resource "bunnynet_pullzone_waf_rule" "main" {
  for_each = var.pullzone_shield_enabled ? var.pullzone_shield_waf_rules : {}

  pullzone        = bunnynet_pullzone.main.id
  name            = each.value.name
  description     = each.value.description
  transformations = lookup(each.value, "transformations", null)

  dynamic "condition" {
    for_each = each.value.condition
    content {
      operator             = condition.value.operator
      value                = condition.value.value
      variable             = condition.value.variable
      variable_value       = condition.value.variable_value
      variable_value_regex = condition.value.variable_value_regex
      negated              = condition.value.negated
    }
  }

  response {
    action = each.value.response.action
  }

  depends_on = [time_sleep.bunnynet_pullzone_shield]
}

resource "bunnynet_pullzone_ratelimit_rule" "main" {
  for_each = var.pullzone_shield_enabled ? var.pullzone_shield_rate_limit_rules : {}

  pullzone        = bunnynet_pullzone.main.id
  name            = each.value.name
  description     = each.value.description
  transformations = lookup(each.value, "transformations", null)

  dynamic "condition" {
    for_each = each.value.condition
    content {
      operator             = condition.value.operator
      value                = condition.value.value
      variable             = condition.value.variable
      variable_value       = condition.value.variable_value
      variable_value_regex = condition.value.variable_value_regex
      negated              = condition.value.negated
    }
  }

  limit {
    requests    = each.value.limit.requests
    interval    = each.value.limit.interval
    counter_key = each.value.limit.counter_key
  }

  response {
    interval = each.value.response.interval
    action   = each.value.response.action
  }

  depends_on = [time_sleep.bunnynet_pullzone_shield]
}
