locals {
  sub_id                          = "c94f8a3d-8d0b-4660-85de-26004f233dbf"
  dxp_sub_delegation              = "Microsoft.Web/serverFarms"
  dxp_sub_service_endpoints       = ["Microsoft.AzureCosmosDB", "Microsoft.KeyVault", "Microsoft.Web", "Microsoft.EventHub", "Microsoft.Sql", "Microsoft.CognitiveServices"]
  amais_sub_delegation            = "Microsoft.Web/serverFarms"
  amais_sub_service_endpoints     = ["Microsoft.AzureCosmosDB", "Microsoft.KeyVault", "Microsoft.Web", "Microsoft.EventHub", "Microsoft.Sql", "Microsoft.CognitiveServices"]
  twingate_sub_delegation         = "Microsoft.ContainerInstance/containerGroups"
  twingate_sub_service_endpoints  = ["Microsoft.AzureCosmosDB", "Microsoft.KeyVault", "Microsoft.Web", "Microsoft.EventHub", "Microsoft.CognitiveServices"]
  devops_sub_delegation           = "Microsoft.DevOpsInfrastructure/pools"
  devops_sub_service_endpoints    = ["Microsoft.AzureCosmosDB", "Microsoft.KeyVault", "Microsoft.Web", "Microsoft.EventHub", "Microsoft.CognitiveServices"]
  terraform_sub_delegation        = "Microsoft.ContainerInstance/containerGroups"
  terraform_sub_service_endpoints = ["Microsoft.AzureCosmosDB", "Microsoft.KeyVault", "Microsoft.Web", "Microsoft.EventHub", "Microsoft.CognitiveServices"]
  flex_consumption_sub_delegation = "Microsoft.App/environments"
  cae_sub_delegation              = "Microsoft.App/environments"
  cae_sub_service_endpoints       = ["Microsoft.AzureCosmosDB", "Microsoft.KeyVault", "Microsoft.Web", "Microsoft.EventHub", "Microsoft.Sql", "Microsoft.CognitiveServices"]
  common_tags = {
    environment       = "prod"
    deployment_method = "terraform"
  }
  diag_settings_name = "default_diagnostic_settings"
}
