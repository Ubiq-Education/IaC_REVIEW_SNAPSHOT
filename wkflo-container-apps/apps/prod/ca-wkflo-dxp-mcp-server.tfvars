environment       = "prod"
azure_long_region = "uksouth"
name              = "ca-wkflo-dxp-mcp-server"
image_name        = "cruksubiqshared.azurecr.io/wkflo/amais-wkflo-dxp-mcp-server"
additional_env_vars = [
  { name = "ASPNETCORE_ENVIRONMENT", value = "Production" },
  { name = "ASPNETCORE_HTTP_PORTS", value = "32876" },
  { name = "CorsSettings__PolicyName", value = "AllowAnyOrigins" },
  { name = "AmaisJwtScheme__Issuer", value = "amais-jwt-service" },
  { name = "AmaisJwtScheme__KeyName", value = "jwt-key-prod" },
  { name = "USER_AGENT_HEADER", value = "<REDACTED>" }
]
oltp_exporter_settings               = { enabled = true, service_name = "amais-wkflo-dxp-mcp-webapi" }
central_key_vault_key_access_enabled = true
# Adds AMAIS_DXP_REPORT_SERVER_URL, ReportClientOAuthSettings__* and AMAIS_DXP_CLIENT_AUTH_FLOW
# for the WKFLO DXP client managed identity (id-app-uks-wkflo-dxp-client-prod)
dxp_report_client_enabled = true
elastic_search_connections = {
  serilog_enabled                         = true
  serilog_elastic_search_application_name = "AMAIS.WKFLO.DXP.MCP.WebAPI"
  serilog_elastic_search_level            = "Warn"
}
ingress = {
  external_enabled = true
  target_port      = 32876
}
http_scale_rules = [
  {
    name                = "http-scaler"
    concurrent_requests = 10
  }
]
liveness_probes = [
  {
    port      = 32876
    transport = "tcp"
  }
]
readiness_probes = [
  {
    port      = 32876
    transport = "tcp"
  }
]
startup_probes = [
  {
    port      = 32876
    transport = "tcp"
  }
]

/*
These values are supplied on the Control Monkey stack:

cpu
memory
image_tag
min_replicas
max_replicas
*/
