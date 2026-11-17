environment          = "staging"
azure_long_region    = "uksouth"
name                 = "ca-wkflo-web"
image_name           = "cruksubiqshared.azurecr.io/wkflo/amais-wkflo-web"
ignore_image_version = true # Only for staging
additional_env_vars = [
  { name = "ASPNETCORE_ENVIRONMENT", value = "Staging" },
  { name = "VITE_API_URL", value = "https://staging.gateway.wkflo.ai" },
  { name = "VITE_ENTRA_CLIENT_ID", value = "dd92c987-87f8-4c1b-b715-25ba204054d8" },
  { name = "VITE_ENTRA_TENANT_ID", value = "bf3e1181-ffe9-40f7-aee4-11dc5fd642c6" },
  { name = "VITE_MSAL_REDIRECT_URI", value = "https://staging.app.wkflo.ai/" },
  { name = "VITE_ENTRA_SCOPE", value = "api://dd92c987-87f8-4c1b-b715-25ba204054d8/access_as_user" }
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
  app    = "staging.app.wkflo.ai"
  media  = "staging.media.wkflo.ai"
  static = "staging.static.wkflo.ai"
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
        patterns   = ["https://staging.media.wkflo.ai/*", "https://staging.static.wkflo.ai/*"]
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
      parameter1 = "https://stc8f06d4e9bd78efb4b4bd9.blob.core.windows.net/"
      parameter2 = null
      parameter3 = null
    }]
    match_type = "MatchAny"
    triggers = [{
      type       = "Url"
      match_type = "MatchAny"
      patterns   = ["https://staging.media.wkflo.ai/*"]
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
      patterns   = ["https://staging.media.wkflo.ai/*"]
      parameter1 = null
      parameter2 = null
    }]
  }
  static_redirection = {
    description = "Redirect static asset requests to web storage endpoint"
    priority    = 5
    actions = [{
      type       = "OriginUrl"
      parameter1 = "https://stc8f06d4e9bd78efb4b4bd9.z33.web.core.windows.net/"
      parameter2 = null
      parameter3 = null
    }]
    match_type = "MatchAny"
    triggers = [{
      type       = "Url"
      match_type = "MatchAny"
      patterns   = ["https://staging.static.wkflo.ai/*"]
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
      patterns   = ["https://staging.static.wkflo.ai/*"]
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
