module "short_region_lookup" {
  for_each = toset(local.dxp_regions)

  source         = "api.controlmonkey.io/o-26drsisx9g/short-region-lookup/azurerm"
  version        = "~>1.0.0"
  az_long_region = each.key
}

data "azurerm_user_assigned_identity" "ais_srch" {
  name                = "id-ais-uks-ai-central"
  resource_group_name = "rg-uks-ai-central"
}

data "azurerm_log_analytics_workspace" "shared" {
  name                = "log-uks-ubiq-shared-logging"
  resource_group_name = "rg-uks-ubiq-shared-logging"
}

module "amais-ai-prod" {
  source                                = "api.controlmonkey.io/o-26drsisx9g/amais-ai/azurerm"
  version                               = "~>2.0"
  deployment_name                       = "Amais-DXP-AI-4fe8"
  random_deployment_name_suffix_enabled = false
  resource_group_resource_id            = "/subscriptions/c94f8a3d-8d0b-4660-85de-26004f233dbf/resourceGroups/Amais-DXP"
  az_long_region                        = "uksouth"
  ais_restricted_subnet_ids = concat(
    [
      data.azurerm_subnet.vnet_integration_ai_functions.id,
      data.azurerm_subnet.hub_centralindia_tg.id,
      data.azurerm_subnet.hub_uksouth_tg.id
    ],
    local.vnet_integration_subnet_ids,
  )
  ais_roles = {
    app_openai_user = {
      principal_id         = module.dxp-appservice.production_identity_principal_id
      role_definition_name = "Cognitive Services OpenAI User"
    }
  }
  key_vault_resource_id               = "/subscriptions/c94f8a3d-8d0b-4660-85de-26004f233dbf/resourceGroups/Amais-DXP/providers/Microsoft.KeyVault/vaults/kv-uks-amaisdxp"
  ais_srch_mi_resource_id             = data.azurerm_user_assigned_identity.ais_srch.id
  log_analytics_workspace_resource_id = data.azurerm_log_analytics_workspace.shared.id
  tags                                = { deployment_method = "terraform", environment = "prod" }
  cognitive_deployments = {
    o3-mini = {
      name                  = "o3-mini"
      capacity_in_thousands = 1000
    }
  }
}

module "amais-ai-staging" {
  source                                = "api.controlmonkey.io/o-26drsisx9g/amais-ai/azurerm"
  version                               = "~>2.0"
  deployment_name                       = "Amais-DXP-AI-staging-4fe8"
  random_deployment_name_suffix_enabled = false
  resource_group_resource_id            = "/subscriptions/c94f8a3d-8d0b-4660-85de-26004f233dbf/resourceGroups/Amais-DXP"
  az_long_region                        = "uksouth"
  ais_restricted_subnet_ids = concat(
    [
      data.azurerm_subnet.vnet_integration_ai_functions.id,
      data.azurerm_subnet.hub_centralindia_tg.id,
      data.azurerm_subnet.hub_uksouth_tg.id
    ],
    local.vnet_integration_subnet_ids,
  )
  ais_roles = {
    app_openai_user = {
      principal_id         = module.dxp-appservice.staging_identity_principal_id
      role_definition_name = "Cognitive Services OpenAI User"
    }
  }
  key_vault_resource_id               = "/subscriptions/c94f8a3d-8d0b-4660-85de-26004f233dbf/resourceGroups/Amais-DXP/providers/Microsoft.KeyVault/vaults/kv-uks-amaisdxp"
  ais_srch_mi_resource_id             = data.azurerm_user_assigned_identity.ais_srch.id
  log_analytics_workspace_resource_id = data.azurerm_log_analytics_workspace.shared.id
  tags                                = { deployment_method = "terraform", environment = "staging" }
  cognitive_deployments = {
    o3-mini = {
      name                  = "o3-mini"
      capacity_in_thousands = 1000
    }
  }
}
