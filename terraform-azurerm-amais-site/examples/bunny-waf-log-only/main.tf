module "amais_site" {
  source  = "api.controlmonkey.io/o-26drsisx9g/amais-site/azurerm"
  version = "~>2.2.0"

  # ... required settings omitted for brevity ...

  ## Bunny WAF and bot protection log only
  ## DDoS should always be on
  bunny_pullzone_shield_config = {
    tier = "Advanced"
    ddos = {
      mode = "Block"
    }
    waf = {
      enabled = true
      mode    = "Log"
    }
    bot_detection = {
      mode = "Log"
    }
  }
}
