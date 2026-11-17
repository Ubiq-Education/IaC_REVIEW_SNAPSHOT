module "amais_site" {
  source  = "api.controlmonkey.io/o-26drsisx9g/amais-site/azurerm"
  version = "~>2.2.0"

  # ... required settings omitted for brevity ...

  ## Bot protection exception rule
  bunny_pullzone_additional_edge_rules = {
    allow_bot_detection_bypass = {
      description = "6476 - Add edge rule to disable bot detection for Semrush"
      priority    = 3
      actions = [{
        type       = "DisableShieldBotDetection"
        parameter1 = null
        parameter2 = null
        parameter3 = null
      }]
      match_type = "MatchAny"
      triggers = [{
        type       = "RequestHeader"
        match_type = "MatchAny"
        patterns   = ["SiteAuditBot"]
        parameter1 = "User-Agent"
        parameter2 = null
        }
      ]
    }
  }
}
