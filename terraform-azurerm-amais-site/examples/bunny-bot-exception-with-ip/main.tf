module "amais_site" {
  source  = "api.controlmonkey.io/o-26drsisx9g/amais-site/azurerm"
  version = "~>2.2.0"

  # ... required settings omitted for brevity ...

  ## Bot protection exception rule
  bunny_pullzone_additional_edge_rules = {
    allow_bot_detection_bypass = {
      description = "4748 - Disable bot detection for AlumniFire, ConstantContact"
      priority    = 3
      actions = [{
        type       = "DisableShieldBotDetection"
        parameter1 = null
        parameter2 = null
        parameter3 = null
      }]
      match_type = "MatchAny"
      triggers = [
        {
          type       = "RemoteIP"
          match_type = "MatchAny"
          patterns   = ["74.220.50.*", "74.220.58.*"]
          parameter1 = null
          parameter2 = null
          }, {
          type       = "RequestHeader"
          match_type = "MatchAny"
          patterns = [
            "Mozilla/5.0 (compatible; Embedly/0.2; snap; +http://support.embed.ly/)",
            "Mozilla/5.0 (compatible; Embedly/0.2; +http://support.embed.ly/)",
            "Mozilla/5.0 (compatible; Embedly/0.2*"
          ]
          parameter1 = "User-Agent"
          parameter2 = null
        }
      ]
    }
  }
}