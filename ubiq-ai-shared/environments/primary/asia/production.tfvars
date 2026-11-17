sub_id          = "73ba2918-0235-481b-9601-ce542927a943"
primary_region  = "uaenorth"
regions         = ["uaenorth"]
deployment_name = "asia-primary"
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
}
pullzone_zones = ["ASIA"]
tags = {
  environment = "prod"
}
