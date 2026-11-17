sub_id          = "cebaf0a1-67da-490d-bd7f-77ba7e1448b6"
primary_region  = "uksouth"
regions         = ["uksouth", "swedencentral", "westeurope"]
deployment_name = "europe-secondary"
cognitive_deployments = {
  gpt-4_1-mini = {
    name                  = "gpt-4.1-mini"
    format                = "OpenAI"
    sku_name              = "GlobalStandard"
    capacity_in_thousands = 150000
  }
  text-embedding-3-large = {
    name                  = "text-embedding-3-large"
    format                = "OpenAI"
    sku_name              = "GlobalStandard"
    capacity_in_thousands = 10000
  }
  claude-sonnet-4-5 = {
    name                  = "claude-sonnet-4-5"
    format                = "Anthropic"
    sku_name              = "GlobalStandard"
    capacity_in_thousands = 4000
    regions               = ["swedencentral"] # Limited availability
  }
  gpt-5-6-terra = {
    name                  = "gpt-5.6-terra"
    format                = "OpenAI"
    sku_name              = "GlobalStandard"
    capacity_in_thousands = 3000
  }
}
pullzone_zones = ["EU"]
tags = {
  environment = "prod"
}
