sub_id          = "cebaf0a1-67da-490d-bd7f-77ba7e1448b6"
primary_region  = "eastus2"
regions         = ["eastus2", "westus3", "southcentralus"]
deployment_name = "us-secondary"
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
pullzone_zones = ["US"]
tags = {
  environment = "prod"
}
