environment          = "staging"
azure_long_region    = "uksouth"
name                 = "ca-wkflo-mcp-server"
image_name           = "cruksubiqshared.azurecr.io/wkflo/amais-wkflo-mcp-server"
ignore_image_version = true # Only for staging
additional_env_vars = [
  { name = "ASPNETCORE_ENVIRONMENT", value = "Staging" },
  { name = "ASPNETCORE_HTTP_PORTS", value = "32874" },
  { name = "CorsSettings__PolicyName", value = "AllowAnyOrigins" },
  { name = "AmaisJwtScheme__Issuer", value = "amais-jwt-service" },
  { name = "AmaisJwtScheme__KeyName", value = "jwt-key-staging" },
  { name = "USER_AGENT_HEADER", value = "<REDACTED>" }
]
oltp_exporter_settings               = { enabled = true, service_name = "amais-wkflo-mcp-webapi" }
central_key_vault_key_access_enabled = true
elastic_search_connections = {
  serilog_enabled                         = true
  serilog_elastic_search_application_name = "AMAIS.WKFLO.MCP.WebAPI"
  serilog_elastic_search_level            = "Warn"
}
ingress = {
  external_enabled = true
  target_port      = 32874
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
    port      = 32874
    transport = "tcp"
  }
]
readiness_probes = [
  {
    # path      = "/api/v1/healthcheck"
    port      = 32874
    transport = "tcp"
  }
]
startup_probes = [
  {
    port      = 32874
    transport = "tcp"
  }
]

/*
These values are supplied on the Control Monkey stack:

cpu
memory
min_replicas
max_replicas
*/
