environment                = "prod"
azure_long_region          = "uksouth"
name                       = "ca-wkflo-alloy"
image_name                 = "grafana/alloy"
runtime                    = { name = "generic" }
add_grafana_alloy_env_vars = true
additional_env_vars = [
  { name = "ALLOY_LOG_LEVEL", value = "debug" }
]
ingress = {
  external_enabled = false
  target_port      = 4317
  transport        = "Tcp"
}
tcp_scale_rules = [
  {
    name                = "tcp-scaler"
    concurrent_requests = 10
  }
]
liveness_probes = [
  {
    path      = "/-/healthy"
    port      = 12345
    transport = "http"
  }
]
readiness_probes = [
  {
    path      = "/-/healthy"
    port      = 12345
    transport = "http"
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
