environment          = "staging"
azure_long_region    = "uksouth"
name                 = "ca-wkflo-backend-ai-api"
image_name           = "cruksubiqshared.azurecr.io/wkflo/amais-wkflo-ai-api"
ignore_image_version = true # Only for staging
additional_env_vars = [
  { name = "ASPNETCORE_ENVIRONMENT", value = "Staging" },
  { name = "ASPNETCORE_HTTP_PORTS", value = "32774" },
  { name = "AllowedHosts", value = "*" },
  { name = "CorsSettings__PolicyName", value = "AllowAnyOrigins" },
  { name = "AzureAd__Instance", value = "https://login.microsoftonline.com/" },
  { name = "AzureAd__TenantId", value = "bf3e1181-ffe9-40f7-aee4-11dc5fd642c6" },
  { name = "AzureAd__ClientId", value = "dd92c987-87f8-4c1b-b715-25ba204054d8" }, # Staging Wkflo app registration
  { name = "AmaisChatBotSettings__ChatbotApiURL", value = "https://amais-chatbot-api-staging.amais.com" },
  { name = "AmaisTokenVoiceApiServiceSettings__TokenServiceApiURL", value = "https://amais-jwt-service-staging.amais.com" },
  { name = "AmaisTokenVoiceApiServiceSettings__AppIdUri", value = "api://961b1a26-ca84-4613-843e-a9a1f2f58051" }, # Staging jwt app registration API URI
  { name = "AmaisJwtScheme__Issuer", value = "amais-jwt-service" },
  { name = "AmaisJwtScheme__KeyName", value = "jwt-key-staging" },
  { name = "AMAIS_MCP_SERVER", value = "https://ca-wkflo-mcp-server-staging.cae-uks-wkflo-staging.wkflo.ai" },
  { name = "AMAIS_DXP_MCP_SERVER", value = "https://ca-wkflo-dxp-mcp-server-staging.cae-uks-wkflo-staging.wkflo.ai" },
  { name = "AMAIS_URL_TEST", value = "https://petracmsdev.amais.com" },
  { name = "AMAIS_ROLE_TEST", value = "SuperAdmin" },
  { name = "SCALAR_ENABLED", value = "true" },
  { name = "AZURE_SPEECH_ENDPOINT", value = "https://ais-uks-europe-secondary-1616.cognitiveservices.azure.com/" }
]
oltp_exporter_settings                = { enabled = true, service_name = "amais-wkflo-ai-webapi" }
wkflo_sql_db_connection_enabled       = true
blob_storage_connection_enabled       = true
postgres_vector_db_connection_enabled = true
signalr_connection_enabled            = true
azure_ai_model_access_enabled         = true
central_key_vault_key_access_enabled  = true
dxp_client_enabled                    = true
mcp_oauth_token_encryption_enabled    = true
redis_cache_connection_enabled        = true
ai_embeddings_settings = {
  enabled         = true
  deployment_name = "text-embedding-3-small"
}
elastic_search_connections = {
  standard_enabled                        = true
  serilog_enabled                         = true
  eis_enabled                             = true
  serilog_elastic_search_application_name = "AMAIS.WKFLO.AI.WebAPI"
}
ingress = {
  external_enabled = true
  target_port      = 32774
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
    port      = 32774
    transport = "tcp"
  }
]
readiness_probes = [
  {
    # path      = "/api/v1/healthcheck"
    port      = 32774
    transport = "tcp"
  }
]
startup_probes = [
  {
    port      = 32774
    transport = "tcp"
  }
]
dapr = {
  enabled               = true
  app_id                = "amais-wkflo-ai-webapi"
  app_port              = 32774
  app_protocol          = "http"
  http_max_request_size = 20
  log_level             = "info"
}

# /api/v1/healthcheck
/*
These values are supplied on the Control Monkey stack:

cpu
memory
min_replicas
max_replicas
*/
