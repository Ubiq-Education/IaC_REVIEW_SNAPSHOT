locals {
  container_env_vars = concat(
    [
      { name = "UsageLogClientSettings__EventHubQualifiedFullName", value = var.environment == "prod" ? module.ubiq_resources.pum.prod.eventhub_fqdn : module.ubiq_resources.pum.staging.eventhub_fqdn },
      { name = "UsageLogClientSettings__EvenHubName", value = var.environment == "prod" ? module.ubiq_resources.pum.prod.eventhub_name : module.ubiq_resources.pum.staging.eventhub_name },
      { name = "UsageLogClientSettings__EventHubName", value = var.environment == "prod" ? module.ubiq_resources.pum.prod.eventhub_name : module.ubiq_resources.pum.staging.eventhub_name }
    ],
    var.add_grafana_alloy_env_vars ? [
      { name = "GRAFANA_TEMPO_ENDPOINT", value = "tempo-prod-08-prod-eu-west-3.grafana.net:443" },
      { name = "TEMPO_USERNAME", secret_name = "tempo-username" },
      { name = "GRAFANA_LOKI_ENDPOINT", value = "https://logs-prod-013.grafana.net/otlp" },
      { name = "LOKI_USERNAME", secret_name = "loki-username" },
      { name = "GRAFANA_PROMETHEUS_ENDPOINT", value = "https://prometheus-prod-22-prod-eu-west-3.grafana.net/otlp" },
      { name = "PROMETHEUS_USERNAME", secret_name = "prometheus-username" },
      { name = "GRAFANA_CLOUD_API_KEY", secret_name = "grafana-cloud-api-key" }
    ] : [],
    local.central_key_vault_access_enabled ? [
      { name = "CENTRAL_KEY_VAULT_URI", value = data.azurerm_key_vault.central.vault_uri }
    ] : [],
    var.wkflo_sql_db_connection_enabled ? [
      {
        # TODO: Add pipeline with SQL script to create contained database user for the container app's managed identity
        # STAGING AND PROD SEPARATELY
        name = "DB_CONNECTION_STRING"
        value = join("", [
          "Server=${data.azurerm_mssql_server.wkflo[0].fully_qualified_domain_name};",
          "Database=${local.cae_wkflo_mssql_resource.name};",
          "Authentication=Active Directory Default;",
          "User Id=${module.avm-res-managedidentity-userassignedidentity-app.client_id};",
          "MultipleActiveResultSets=True;",
          "Encrypt=True;",
          "TrustServerCertificate=False;",
          "Connection Timeout=30;"
        ])
      }
    ] : [],
    var.postgres_vector_db_connection_enabled ? [
      { name = "PG_DB_HOST", value = local.cae_postgresql_resource.fqdn },
      { name = "PG_DB_NAME", value = "postgres" },
      { name = "PG_DB_PORT", value = 5432 },
      { name = "PG_DB_USER", value = module.avm-res-managedidentity-userassignedidentity-app.resource_name }
    ] : [],
    var.elastic_search_connections.standard_enabled ? [
      { name = "ElasticsearchSettings__Url", value = local.elastic_search_url[var.environment] },
      { name = "ElasticsearchSettings__ApiKey", secret_name = data.azurerm_key_vault_secret.elasticsearch_api_key[0].name },
      { name = "ElasticsearchSettings__KnowledgeIndex", value = "amais-${var.environment}-wkflo-knowledge-index" }
    ] : [],
    var.elastic_search_connections.serilog_enabled ? [
      { name = "SerilogElasticSearchSettings__Url", value = local.serilog_elastic_search_url[var.environment] },
      { name = "SerilogElasticSearchSettings__ApiKey", secret_name = data.azurerm_key_vault_secret.serilog_elasticsearch_api_key[0].name },
      { name = "SerilogElasticSearchSettings__DataStream", value = var.elastic_search_connections.serilog_elastic_search_datastream },
      { name = "SerilogElasticSearchSettings__ApplicationName", value = var.elastic_search_connections.serilog_elastic_search_application_name },
      { name = "SerilogElasticSearchSettings__Level", value = var.elastic_search_connections.serilog_elastic_search_level }
    ] : [],
    var.elastic_search_connections.eis_enabled ? [
      { name = "EisElasticsearchSettings__Url", value = local.eis_elastic_search_url[var.environment] },
      { name = "EisElasticsearchSettings__ApiKey", secret_name = data.azurerm_key_vault_secret.eis_elasticsearch_api_key[0].name },
      { name = "EisElasticsearchSettings__TopK", value = var.elastic_search_connections.eis_elastic_search_topk }
    ] : [],
    var.blob_storage_connection_enabled ? [
      # NOTE: Assumes the Bunny PZ and DNS for this have been created by the ca-wkflo-web app stack
      { name = "BlobStorageSettings__BaseCdnUrl", value = var.environment == "prod" ? "https://media.wkflo.ai" : "https://staging.media.wkflo.ai" },
      { name = "BlobStorageSettings__BaseUrl", value = "https://${local.cae_storeage_account.name}.blob.core.windows.net" }
    ] : [],
    var.signalr_connection_enabled ? [
      { name = "Azure__SignalR__ConnectionString", value = "Endpoint=https://${local.signalr_fqdn};AuthType=azure.msi;ClientId=${module.avm-res-managedidentity-userassignedidentity-app.client_id};Version=1.0;" }
    ] : [],
    try(var.oltp_exporter_settings.enabled, false) ? [
      { name = "OTEL_EXPORTER_OTLP_ENDPOINT", value = "http://ca-wkflo-alloy-${lower(var.environment)}:4317" }, # Should be the container app name for the alloy container in the same CAE
      { name = "OTEL_EXPORTER_OTLP_PROTOCOL", value = var.oltp_exporter_settings.protocol },
      { name = "OTEL_SERVICE_NAME", value = var.oltp_exporter_settings.service_name }
    ] : [],
    try(var.ai_embeddings_settings.enabled, false) ? [
      { name = "EmbeddingSettings__DeploymentName", value = var.ai_embeddings_settings.deployment_name },
      { name = "EmbeddingSettings__Endpoint", value = "https://ai-europe-primary.amais.com/" }
    ] : [],
    var.mcp_oauth_token_encryption_enabled ? [
      { name = "MCP_OAUTH_TOKEN_ENCRYPTION_KEY", secret_name = data.azurerm_key_vault_secret.mcp_oauth_token_encryption_key[0].name }
    ] : [],
    var.redis_cache_connection_enabled ? [
      # Use the CAE identity, which has the Redis access policy for container apps (see wkflo-environment/redis.tf)
      { name = "AZURE_REDIS_HOSTNAME", value = var.cae[var.azure_long_region].redis_resources.endpoint },
      { name = "AZURE_REDIS_CLIENT_ID", value = local.cae_identity.client_id }
    ] : [],
    local.dxp_client_identity_enabled ? [
      { name = "AMAIS_DXP_CLIENT_AUTH_FLOW", value = "entraid-no-secrets" }
    ] : [],
    var.dxp_client_enabled ? [
      { name = "AMAIS_DXP_INGRESS_SERVER_URL", value = local.dxp_client[var.environment].ingress_url },
      { name = "IngressClientOAuthSettings__ClientId", value = local.dxp_client[var.environment].mi_client_id },
      { name = "IngressClientOAuthSettings__Audience", value = "${local.dxp_api_identifier_uri}/.default" },
      { name = "AMAIS_DXP_MASTERDATA_SERVER_URL", value = local.dxp_client[var.environment].md_url },
      { name = "MasterDataClientOAuthSettings__ClientId", value = local.dxp_client[var.environment].mi_client_id },
      { name = "MasterDataClientOAuthSettings__Audience", value = "${local.dxp_api_identifier_uri}/.default" }
    ] : [],
    var.dxp_report_client_enabled ? [
      { name = "AMAIS_DXP_REPORT_SERVER_URL", value = local.dxp_client[var.environment].report_url },
      { name = "ReportClientOAuthSettings__ClientId", value = local.dxp_client[var.environment].mi_client_id },
      { name = "ReportClientOAuthSettings__Audience", value = "${local.dxp_api_identifier_uri}/.default" }
    ] : [],
    # Keep additional environment variables defined in the .tfvars files last, so they can override any of the above if needed
    var.additional_env_vars
  )
}
