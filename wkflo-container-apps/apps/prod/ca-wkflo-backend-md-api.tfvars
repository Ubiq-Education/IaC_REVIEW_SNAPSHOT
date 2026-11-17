environment       = "prod"
azure_long_region = "uksouth"
name              = "ca-wkflo-backend-md-api"
image_name        = "cruksubiqshared.azurecr.io/wkflo/amais-wkflo-md-api"
additional_env_vars = [
  { name = "ASPNETCORE_ENVIRONMENT", value = "Production" },
  { name = "ASPNETCORE_HTTP_PORTS", value = "32772" },
  { name = "AllowedHosts", value = "*" },
  { name = "CorsSettings__PolicyName", value = "AllowAnyOrigins" },
  { name = "AzureAd__Instance", value = "https://login.microsoftonline.com/" },
  { name = "AzureAd__TenantId", value = "bf3e1181-ffe9-40f7-aee4-11dc5fd642c6" },
  { name = "AzureAd__ClientId", value = "f77aee83-7912-40c5-b6f8-1a5e5457ea3b" }, # Prod Wkflo app registration
  { name = "AzureAd__Scopes", value = "access_as_user" },
  { name = "ChatWidgetSettings__WidgetScriptUrl", value = "https://app.wkflo.ai/assets/wkflo-widget.umd.cjs" },
  { name = "SCALAR_ENABLED", value = "true" },
  { name = "DEFAULT_WEB_ORIGINS", value = "https://app.wkflo.ai;https://gateway.wkflo.ai" },
  { name = "ClassificationJobSettings__DelayHours", value = "0.01" },
  { name = "ClassificationJobSettings__CooldownHours", value = "0.01" },
  { name = "ClassificationJobSettings__LookbackMonths", value = "1" },
  { name = "STATIC_WEBSITE_BASE_URL", value = "https://static.wkflo.ai" },
  { name = "McpOAuthSettings__PublicBaseUrl", value = "https://gateway.wkflo.ai" }
]
oltp_exporter_settings                = { enabled = true, service_name = "amais-wkflo-md-webapi" }
wkflo_sql_db_connection_enabled       = true
blob_storage_connection_enabled       = true
postgres_vector_db_connection_enabled = true
azure_ai_model_access_enabled         = true
mcp_oauth_token_encryption_enabled    = true
redis_cache_connection_enabled        = true
ai_embeddings_settings = {
  enabled         = true
  deployment_name = "text-embedding-3-small"
}
elastic_search_connections = {
  standard_enabled                        = true
  serilog_enabled                         = true
  serilog_elastic_search_application_name = "AMAIS.WKFLO.MD.WebAPI"
}
ingress = {
  external_enabled = true
  target_port      = 32772
}
http_scale_rules = [
  {
    name                = "http-scaler"
    concurrent_requests = 10
  }
]
liveness_probes = [
  {
    # path      = "/api/v1/healthcheck"
    port      = 32772
    transport = "tcp"
  }
]
readiness_probes = [
  {
    # path      = "/api/v1/healthcheck"
    port      = 32772
    transport = "tcp"
  }
]
startup_probes = [
  {
    port      = 32772
    transport = "tcp"
  }
]
dapr = {
  enabled      = true
  app_id       = "amais-wkflo-md-webapi"
  app_port     = 32772
  app_protocol = "http"
  log_level    = "info"
}

# /api/v1/healthcheck
/*
These values are supplied on the Control Monkey stack:

cpu
memory
image_tag
min_replicas
max_replicas
*/
