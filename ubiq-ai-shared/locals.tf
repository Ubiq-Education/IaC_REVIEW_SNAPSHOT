locals {
  primary_region = {
    name       = var.primary_region
    short_name = module.short-region-lookup.short_region
  }
  custom_hostname = "ai-${var.deployment_name}"
  custom_fqdn     = "${local.custom_hostname}.${data.azurerm_dns_zone.amais_com.name}"
  common_tags = {
    deployment_method = "terraform"
  }
  merged_tags = merge(
    local.common_tags,
    var.tags
  )
  diag_settings_name = "default_diagnostic_settings"
  cognitive_deployments_by_region = {
    for region in var.regions :
    region => {
      for deployment_key, deployment in var.cognitive_deployments :
      deployment_key => {
        name                  = deployment.name
        format                = deployment.format
        version               = deployment.version
        sku_name              = deployment.sku_name
        capacity_in_thousands = deployment.capacity_in_thousands
      } if deployment.regions == null || contains(deployment.regions, region)
    }
  }
  ais_regional_origins = {
    # Loop through non-primary regions and add random chance load balancing rules
    for region in var.regions :
    region => {
      description = "LB - ${region}"
      # priorty should be the same as the index in the regions list
      priority = index(var.regions, region) + 2
      actions = [{
        type       = "OriginUrl"
        parameter1 = module.amais-ai[region].azure_openai_client_url
        parameter2 = null
        parameter3 = null
      }]
      match_type = "MatchAny"
      triggers = [{
        type       = "RandomChance"
        match_type = "MatchAny"
        patterns   = [tostring(floor(100 / length(var.regions)))]
        parameter1 = null
        parameter2 = null
      }]
    } if region != local.primary_region.name
  }
}
