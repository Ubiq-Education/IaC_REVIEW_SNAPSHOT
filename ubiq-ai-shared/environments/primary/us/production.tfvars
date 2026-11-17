sub_id          = "73ba2918-0235-481b-9601-ce542927a943"
primary_region  = "eastus2"
regions         = ["eastus2", "westus3", "southcentralus"]
deployment_name = "us-primary"
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
    regions               = ["eastus2"] # Limited availability
  }
}
pullzone_zones = ["US"]
tags = {
  environment = "prod"
}
