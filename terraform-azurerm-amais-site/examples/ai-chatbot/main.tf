module "amais_site" {
  source  = "api.controlmonkey.io/o-26drsisx9g/amais-site/azurerm"
  version = "~>2.2.0"

  # ... required settings omitted for brevity ...

  ## AI Chatbot
  enable_ai_chatbot_staging    = true
  enable_ai_chatbot_production = false
}
