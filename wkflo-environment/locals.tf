locals {
  sub_id        = "4ef55ff0-c50a-4146-8d6f-08e9e29defc9"
  domain_suffix = "wkflo.ai"
  is_staging    = var.environment == "staging" ? true : false
  tags = merge(
    {
      deployment_method = "terraform"
      environment       = var.environment
      cost_center       = "WKFLO"
    }, var.tags
  )
  data_tags = {
    confidential = {
      data_classification = "confidential"
    }
    public = {
      data_classification = "public"
    }
  }
  lock_note = "This resource is locked by Terraform"
  cae_names = { for region, config in var.regions_enabled : region => "cae-${module.short-region-lookup[region].short_region}-wkflo-${var.environment}" }
  cae_regions = {
    "uksouth" = {
      zone_redundancy_enabled = true
      log_analytics_workspace = { resource_id = data.azurerm_log_analytics_workspace.shared.id }
      vnets = {
        wkflo-01 = {
          address_space = ["10.0.0.0/16"]
          subnets = {
            cae-01 = {
              address_prefixes        = ["10.0.0.0/21"]
              service_delegation_name = "Microsoft.App/environments"
              service_endpoints       = ["Microsoft.KeyVault", "Microsoft.Web", "Microsoft.EventHub", "Microsoft.CognitiveServices", "Microsoft.ContainerRegistry", "Microsoft.Sql"]
            }
          }
        }
      }
    }
  }
  network_watcher_flow_logs_map = merge([
    for region in keys(var.regions_enabled) : {
      for vnet_key, vnet_cfg in local.cae_regions[region].vnets :
      "${region}:${vnet_key}" => {
        region    = region
        vnet_key  = vnet_key
        vnet_name = "vnet-${module.short-region-lookup[region].short_region}-${vnet_key}"
      }
    }
  ]...)
  # Map of regions with the secure_access_gw_pips added to each region for use in firewall rules
  # It should be a flat map with region-pip_index as key and the pip resource as value, e.g. "uksouth-pip1" => data.azurerm_public_ip.secure_access_gw_pips[0]
  region_secure_access_gw_pips_map = merge([
    for region in keys(var.regions_enabled) : {
      for name, pip in module.ubiq_resources.secure_access_gw_pips :
      "${region}-${name}" => {
        id         = pip.id
        name       = name
        ip_address = pip.ip_address
      }
    }
  ]...)
  sql_dbs = {
    "wkflo" = {
      sku_name    = var.wkflo_sql_db_sku_name
      max_size_gb = var.wkflo_sql_db_max_size_gb
    }
  }
  # Each db in local.sql_dbs should be created in each region
  region_sqldb_map = merge([
    for region in keys(var.regions_enabled) : {
      for db_name, db_config in local.sql_dbs :
      "${region}-${db_name}" => merge({
        name   = db_name
        region = region
      }, db_config)
    }
  ]...)
  sbns_topic_names = {
    pubsub-ai     = "ai-consumer",
    pubsub-worker = "worker-consumer"
  }
  # Set default SignalR sku if not supplied
  sigr_sku_name = {
    for region, config in var.regions_enabled :
    region => coalesce(try(config.signalr_config.sku_name, null), "Standard_S1")
  }
  # Custom domain is supported on Premium tier only
  sigr_custom_domain_and_cert_enabled = {
    for region, config in var.regions_enabled :
    region => startswith(local.sigr_sku_name[region], "Premium_") && coalesce(try(config.signalr_config.custom_domain_and_cert_enabled, null), false)
  }
  postgresql_sku_name = {
    for region, config in var.regions_enabled :
    region => coalesce(try(config.postgresql_config.sku_name, null), "GP_Standard_D2ds_v5")
  }
  # map of each region in var.regions_enabled with all members in data.azuread_group.devs.members to use in a
  # for_each so that all members are assigned to each region
  regions_enabled_developer_map = merge([
    for region in keys(var.regions_enabled) : {
      for member in data.azuread_group.devs.members :
      "${region}-${member}" => {
        region    = region
        member_id = member
      }
    }
  ]...)
  staticweb_files = {
    index = {
      name = "index.html"
      type = "text/html"
    }
    error = {
      name = "error.html"
      type = "text/html"
    }
    style = {
      name = "style.css"
      type = "text/css"
    }
  }
  region_staticweb_files_map = merge([
    for region in keys(var.regions_enabled) : {
      for file_key, file in local.staticweb_files :
      "${region}-${file_key}" => {
        region   = region
        file_key = file_key
        name     = file.name
        type     = file.type
      }
    }
  ]...)
}
