resource "random_id" "main" {
  byte_length = 16
}

module "ubiq_resources" {
  source  = "api.controlmonkey.io/o-26drsisx9g/ubiq-resources/azapi"
  version = "~>1.0"

  get_pum = true
}

# TODO: Add development stack and default to .net
module "cae_app" {
  source  = "api.controlmonkey.io/o-26drsisx9g/cae-app/azurerm"
  version = "~>3.0"

  ignore_image_version                  = var.ignore_image_version
  name                                  = local.app_name
  resource_group_name                   = local.resource_group_name
  global_resource_group_name            = var.cae[var.azure_long_region].global_resource_group_name
  replica_count_alert_enabled           = var.environment == "prod" ? true : false
  readiness_probe_failure_alert_enabled = var.environment == "prod" ? true : false
  azure_conainter_registry = {
    identity_resource_id = var.cae[var.azure_long_region].arcpull_identity.resource_id
  }
  cae_resource_id    = local.cae_id
  cae_location       = var.azure_long_region
  cae_default_domain = local.cae_default_domain
  cae_details = {
    key_vault_name             = data.azurerm_key_vault.main.name
    log_analytics_workspace_id = local.cae_log_analytics_workspace_id
  }
  additional_secrets_key_vault_id = data.azurerm_key_vault.central.id
  key_vault_secret_ids = merge(
    var.add_grafana_alloy_env_vars ? {
      # names should match secret names if environment variable secret references
      grafana-cloud-api-key = "https://kv-uks-amais-central.vault.azure.net/secrets/grafana-cloud-api-key-wkflo"
      tempo-username        = "https://kv-uks-amais-central.vault.azure.net/secrets/grafana-cloud-tempo-username"
      loki-username         = "https://kv-uks-amais-central.vault.azure.net/secrets/grafana-cloud-loki-username"
      prometheus-username   = "https://kv-uks-amais-central.vault.azure.net/secrets/grafana-cloud-prometheus-username"
    } : {}
  )
  app_secrets = merge(
    var.add_grafana_alloy_env_vars ? {
      (local.alloy_config_secret.name) = local.alloy_config_secret.value
    } : {},
    var.elastic_search_connections.standard_enabled ? {
      (data.azurerm_key_vault_secret.elasticsearch_api_key[0].name) = data.azurerm_key_vault_secret.elasticsearch_api_key[0].value
    } : {},
    var.elastic_search_connections.serilog_enabled ? {
      (data.azurerm_key_vault_secret.serilog_elasticsearch_api_key[0].name) = data.azurerm_key_vault_secret.serilog_elasticsearch_api_key[0].value
    } : {},
    var.elastic_search_connections.eis_enabled ? {
      (data.azurerm_key_vault_secret.eis_elasticsearch_api_key[0].name) = data.azurerm_key_vault_secret.eis_elasticsearch_api_key[0].value
    } : {},
    var.mcp_oauth_token_encryption_enabled ? {
      (data.azurerm_key_vault_secret.mcp_oauth_token_encryption_key[0].name) = data.azurerm_key_vault_secret.mcp_oauth_token_encryption_key[0].value
    } : {}
  )
  add_primary_identity = {
    id = module.avm-res-managedidentity-userassignedidentity-app.resource_id
  }
  additional_identities = merge(
    local.cae_identity != null ? {
      cae = {
        id = local.cae_identity.resource_id
      }
    } : {},
    local.dxp_client_identity_enabled ? {
      dxp_client = {
        id = local.dxp_client[var.environment].mi_resource_id
      }
    } : {}
  )
  create_app_instance_identity = false
  template = {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas
    containers = [{
      name             = var.name
      image            = "${var.image_name}:${var.image_tag}"
      cpu              = var.cpu
      memory           = var.memory
      env              = local.container_env_vars
      liveness_probes  = var.liveness_probes
      readiness_probes = var.readiness_probes
      startup_probes   = var.startup_probes
      volume_mounts = concat(
        var.add_grafana_alloy_env_vars ? [
          {
            name = "alloy-config"
            path = "/etc/alloy"
          }
        ] : []
      )
    }]
    http_scale_rules   = var.http_scale_rules
    tcp_scale_rules    = var.tcp_scale_rules
    custom_scale_rules = var.custom_scale_rules
    volumes = concat(
      var.add_grafana_alloy_env_vars ? [
        {
          name         = "alloy-config"
          storage_type = "Secret"
          secrets = [
            {
              path       = "config.alloy"
              secret_ref = "alloy-config"
            }
          ]
        }
      ] : []
    )
  }
  ingress = var.ingress == null ? null : {
    allow_insecure_connections = var.ingress.allow_insecure_connections
    client_certificate_mode    = var.ingress.client_certificate_mode
    exposed_port               = var.ingress.exposed_port
    external_enabled           = var.ingress.external_enabled
    target_port                = var.ingress.target_port
    transport                  = var.ingress.transport
    ip_security_restriction    = var.ingress.ip_security_restriction
    traffic_weight = coalesce(try(var.ingress.traffic_weight, null),
      [{
        latest_revision = true
        percentage      = 100
      }]
    )
  }
  dapr    = var.dapr
  runtime = var.runtime.name == "generic" ? null : var.runtime
  tags    = local.tags

  depends_on = [time_sleep.identities]
}
