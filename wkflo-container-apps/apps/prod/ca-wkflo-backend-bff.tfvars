environment       = "prod"
azure_long_region = "uksouth"
name              = "ca-wkflo-backend-bff"
image_name        = "cruksubiqshared.azurecr.io/wkflo/amais-wkflo-bff"
additional_env_vars = [
  { name = "ASPNETCORE_ENVIRONMENT", value = "Production" },
  { name = "ASPNETCORE_HTTP_PORTS", value = "32770" },
  { name = "ReverseProxy__Routes__route-ubiq-md__ClusterId", value = "md-cluster" },
  { name = "ReverseProxy__Routes__route-ubiq-md__Timeout", value = "00:15:00" },
  { name = "ReverseProxy__Routes__route-ubiq-md__Match__Hosts__0", value = "ca-wkflo-backend-bff-prod.icyfield-74c63d09.uksouth.azurecontainerapps.io" },
  { name = "ReverseProxy__Routes__route-ubiq-md__Match__Path", value = "md/{**catch-all}" },
  { name = "ReverseProxy__Routes__route-ubiq-md__Transforms__0__PathPattern", value = "{**catch-all}" },
  { name = "ReverseProxy__Clusters__md-cluster__Destinations__destination1__Address", value = "https://ca-wkflo-backend-md-api-prod.cae-uks-wkflo-prod.wkflo.ai" },
  { name = "ReverseProxy__Routes__route-ubiq-ai__ClusterId", value = "ai-cluster" },
  { name = "ReverseProxy__Routes__route-ubiq-ai__Timeout", value = "00:15:00" },
  { name = "ReverseProxy__Routes__route-ubiq-ai__Match__Hosts__0", value = "ca-wkflo-backend-bff-prod.icyfield-74c63d09.uksouth.azurecontainerapps.io" },
  { name = "ReverseProxy__Routes__route-ubiq-ai__Match__Path", value = "ai/{**catch-all}" },
  { name = "ReverseProxy__Routes__route-ubiq-ai__Transforms__0__PathPattern", value = "{**catch-all}" },
  { name = "ReverseProxy__Clusters__ai-cluster__Destinations__destination1__Address", value = "https://ca-wkflo-backend-ai-api-prod.cae-uks-wkflo-prod.wkflo.ai" }
]
oltp_exporter_settings = { enabled = true, service_name = "amais-wkflo-bff-webapi" }
elastic_search_connections = {
  serilog_enabled                         = true
  serilog_elastic_search_application_name = "AMAIS.WKFLO.BFF.WebAPI"
  serilog_elastic_search_level            = "Warn"
}
ingress = {
  external_enabled = true
  target_port      = 32770
}
bunny_pullzone_config = {
  add_pullzone               = true
  websockets_enabled         = true
  websockets_max_connections = 500
}
bunny_hostnames = {
  gateway = "gateway.wkflo.ai"
}
bunny_pullzone_shield_config = {
  tier = "Advanced"
  waf = {
    enabled = true
    mode    = "Log"
  }
  bot_detection = {
    mode = "Log"
  }
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
    port      = 32770
    transport = "tcp"
  }
]
readiness_probes = [
  {
    # path      = "/api/v1/healthcheck"
    port      = 32770
    transport = "tcp"
  }
]
startup_probes = [
  {
    port      = 32770
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
