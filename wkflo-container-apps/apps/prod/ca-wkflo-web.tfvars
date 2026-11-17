environment       = "prod"
azure_long_region = "uksouth"
name              = "ca-wkflo-web"
image_name        = "cruksubiqshared.azurecr.io/wkflo/amais-wkflo-web"
additional_env_vars = [
  { name = "ASPNETCORE_ENVIRONMENT", value = "Production" },
  { name = "VITE_API_URL", value = "https://gateway.wkflo.ai" },
  { name = "VITE_ENTRA_CLIENT_ID", value = "f77aee83-7912-40c5-b6f8-1a5e5457ea3b" },
  { name = "VITE_ENTRA_TENANT_ID", value = "bf3e1181-ffe9-40f7-aee4-11dc5fd642c6" },
  { name = "VITE_MSAL_REDIRECT_URI", value = "https://app.wkflo.ai/" },
  { name = "VITE_ENTRA_SCOPE", value = "api://f77aee83-7912-40c5-b6f8-1a5e5457ea3b/access_as_user" }
]
oltp_exporter_settings = { enabled = true, service_name = "amais-wkflo-web" }
ingress = {
  external_enabled = true
  target_port      = 8080
}
bunny_pullzone_config = {
  add_pullzone               = true
  websockets_enabled         = true
  websockets_max_connections = 500
}
bunny_hostnames = {
  app    = "app.wkflo.ai"
  media  = "media.wkflo.ai"
  static = "static.wkflo.ai"
}
bunny_pullzone_additional_edge_rules = {
  redirect_404 = {
    description = "Redirect 404s to the index.html"
    priority    = 1
    actions = [{
      type       = "Redirect"
      parameter1 = "https://%%{Url.Hostname}/index.html" # First % to escape, %{Url.Hostname} passed to Bunny
      parameter2 = "307"
      parameter3 = null
    }]
    match_type = "MatchAll"
    triggers = [
      {
        type       = "StatusCode"
        match_type = "MatchAny"
        patterns   = ["404"]
        parameter1 = null
        parameter2 = null
      },
      {
        type       = "Url"
        match_type = "MatchNone"
        patterns   = ["https://media.wkflo.ai/*", "https://static.wkflo.ai/*"]
        parameter1 = null
        parameter2 = null
      }
    ]
  }
  media_redirection = {
    description = "Redirect media asset requests to blob storage endpoint"
    priority    = 3
    actions = [{
      type       = "OriginUrl"
      parameter1 = "https://st15d66a1d80a0b3663d97ab.blob.core.windows.net/"
      parameter2 = null
      parameter3 = null
    }]
    match_type = "MatchAny"
    triggers = [{
      type       = "Url"
      match_type = "MatchAny"
      patterns   = ["https://media.wkflo.ai/*"]
      parameter1 = null
      parameter2 = null
    }]
  }
  media_bot_protection_disable = {
    description = "Disable bot protection for media asset blob storage endpoint"
    priority    = 4
    actions = [{
      type       = "DisableShieldBotDetection"
      parameter1 = null
      parameter2 = null
      parameter3 = null
    }]
    match_type = "MatchAny"
    triggers = [{
      type       = "Url"
      match_type = "MatchAny"
      patterns   = ["https://media.wkflo.ai/*"]
      parameter1 = null
      parameter2 = null
    }]
  }
  static_redirection = {
    description = "Redirect static asset requests to web storage endpoint"
    priority    = 5
    actions = [{
      type       = "OriginUrl"
      parameter1 = "https://st15d66a1d80a0b3663d97ab.z33.web.core.windows.net/"
      parameter2 = null
      parameter3 = null
    }]
    match_type = "MatchAny"
    triggers = [{
      type       = "Url"
      match_type = "MatchAny"
      patterns   = ["https://static.wkflo.ai/*"]
      parameter1 = null
      parameter2 = null
    }]
  }
  static_bot_protection_disable = {
    description = "Disable bot protection for static asset web storage endpoint"
    priority    = 6
    actions = [{
      type       = "DisableShieldBotDetection"
      parameter1 = null
      parameter2 = null
      parameter3 = null
    }]
    match_type = "MatchAny"
    triggers = [{
      type       = "Url"
      match_type = "MatchAny"
      patterns   = ["https://static.wkflo.ai/*"]
      parameter1 = null
      parameter2 = null
    }]
  }
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
    port      = 8080
    transport = "tcp"
  }
]
readiness_probes = [
  {
    # path      = "/api/v1/healthcheck"
    port      = 8080
    transport = "tcp"
  }
]
startup_probes = [
  {
    port      = 8080
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
