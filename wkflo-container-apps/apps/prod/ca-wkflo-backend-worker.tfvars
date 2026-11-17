environment       = "prod"
azure_long_region = "uksouth"
name              = "ca-wkflo-backend-worker"
image_name        = "cruksubiqshared.azurecr.io/wkflo/amais-wkflo-worker"
additional_env_vars = [
  { name = "ASPNETCORE_ENVIRONMENT", value = "Production" },
  { name = "ASPNETCORE_HTTP_PORTS", value = "32776" },
  { name = "AllowedHosts", value = "*" },
  { name = "CorsSettings__PolicyName", value = "AllowAnyOrigins" },
  { name = "WorkerSettings__LookbackMonths", value = "1" },
  { name = "WorkerSettings__BatchSize", value = "50" },
  { name = "REFRESH", value = "1" }
]
oltp_exporter_settings          = { enabled = true, service_name = "amais-wkflo-worker-webapi" }
wkflo_sql_db_connection_enabled = true
dxp_client_enabled              = true
blob_storage_connection_enabled = true
azure_ai_model_access_enabled   = true
elastic_search_connections = {
  serilog_enabled                         = true
  serilog_elastic_search_application_name = "AMAIS.WKFLO.WORKER.WebAPI"
  serilog_elastic_search_level            = "Warn"
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
    port      = 32776
    transport = "tcp"
  }
]
readiness_probes = [
  {
    # path      = "/api/v1/healthcheck"
    port      = 32776
    transport = "tcp"
  }
]
startup_probes = [
  {
    port      = 32776
    transport = "tcp"
  }
]
dapr = {
  enabled      = true
  app_id       = "amais-wkflo-worker-webapi"
  app_port     = 32776
  app_protocol = "http"
  log_level    = "info"
}

/*
These values are supplied on the Control Monkey stack:

cpu
memory
image_tag
min_replicas
max_replicas
*/
