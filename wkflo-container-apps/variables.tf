variable "environment" {
  type        = string
  description = <<DESCRIPTION
  The environment for which the resources are being created (e.g. staging, prod). Use in names and tags."
  Changing will result in resource recreation.
  DESCRIPTION

  validation {
    error_message = "Environment must be `staging` or `prod`"
    condition     = contains(["staging", "prod"], var.environment)
  }
}

variable "azure_long_region" {
  type        = string
  description = "Azure region (e.g. 'uksouth')"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to be applied to the resources"
}

variable "cae" {
  type = map(object({
    resource = object({
      id                = string
      name              = string
      default_domain    = string
      static_ip_address = string
    })
    subnet_id = string
    identities = object({
      principal_id = string
      resource_id  = string
      client_id    = string
    })
    arcpull_identity = object({
      principal_id = string
      resource_id  = string
      client_id    = string
    })
    redis_resources = object({
      id          = string
      host        = string
      database_id = string
      endpoint    = string
    })
    mssql_resources = map(object({
      name      = string
      id        = string
      server_id = string
    }))
    postgresql_resources = object({
      name = string
      id   = string
      fqdn = string
    })
    key_vault_resources = object({
      id  = string
      uri = string
    })
    law_resources = object({
      id = string
    })
    resource_group_name        = string
    app_resource_group_name    = string
    global_resource_group_name = string
    storage_accounts = object({
      name = string
      id   = string
    })
    signalr_resources = object({
      id          = string
      hostname    = string
      public_port = number
      server_port = number
      custom_fqdn = string
    })
  }))
  description = "Region-keyed CAE output object from the CAE stack. Each region value contains all CAE-related resources and identities."
}

variable "name" {
  type        = string
  description = "Container App name"
}

variable "cpu" {
  type        = number
  description = "CPU cores to allocate to the container app"
}

variable "memory" {
  type        = string
  description = "Memory to allocate to the container app (e.g. '0.5Gi', '1Gi')"
}

variable "image_name" {
  type        = string
  description = "Full container image name reference without the tag (e.g. 'myregistry.azurecr.io/myapp')"
}

variable "image_tag" {
  type        = string
  default     = "latest"
  description = "Container image tag (e.g. 'v1.0.0'), defaults to 'latest'"
}

variable "ignore_image_version" {
  type        = bool
  default     = false
  description = <<DESCRIPTION
  Whether to ignore image version changes and not trigger redeployments when the image tag changes.
  Only affects staging environments, prod will always be versioned via the image_tag variable.
  DESCRIPTION
}

variable "min_replicas" {
  type        = number
  default     = 1
  description = "Minimum number of replicas for the container app"
}

variable "max_replicas" {
  type        = number
  default     = 10
  description = "Maximum number of replicas for the container app"
}

variable "additional_env_vars" {
  type = list(object({
    name  = string
    value = string
  }))
  default     = []
  description = "Additional environment variables to set in the container app"
}

variable "liveness_probes" {
  type = list(object({
    path                    = optional(string)
    port                    = number
    transport               = string
    initial_delay           = optional(number, 10)
    interval_seconds        = optional(number, 10)
    timeout                 = optional(number, 30)
    failure_count_threshold = optional(number, 5)
    header = optional(list(object({
      name  = string
      value = string
    })))
  }))
  default     = []
  description = "Configuration for the liveness probe of the container app"

  validation {
    error_message = "transport should be one of http, https, tcp"
    condition     = alltrue([for probe in var.liveness_probes : contains(["http", "https", "tcp"], probe.transport)])
  }

  validation {
    error_message = "path must be specified if transport is http or https"
    condition     = alltrue([for probe in var.liveness_probes : !(contains(["http", "https"], probe.transport) && (probe.path == null || probe.path == ""))])
  }
}

variable "readiness_probes" {
  type = list(object({
    path                    = optional(string)
    port                    = number
    transport               = string
    initial_delay           = optional(number, 10)
    interval_seconds        = optional(number, 10)
    timeout                 = optional(number, 30)
    failure_count_threshold = optional(number, 30)
    success_count_threshold = optional(number, 3)
    header = optional(list(object({
      name  = string
      value = string
    })))
  }))
  default     = []
  description = "Configuration for the readiness probe of the container app"

  validation {
    error_message = "transport should be one of http, https, tcp"
    condition     = alltrue([for probe in var.readiness_probes : contains(["http", "https", "tcp"], probe.transport)])
  }

  validation {
    error_message = "path must be specified if transport is http or https"
    condition     = alltrue([for probe in var.readiness_probes : !(contains(["http", "https"], probe.transport) && (probe.path == null || probe.path == ""))])
  }
}

variable "startup_probes" {
  type = list(object({
    path                    = optional(string)
    port                    = number
    transport               = string
    initial_delay           = optional(number, 10)
    interval_seconds        = optional(number, 1)
    timeout                 = optional(number, 30)
    failure_count_threshold = optional(number, 240)
    header = optional(list(object({
      name  = string
      value = string
    })))
  }))
  default     = []
  description = "Configuration for the startup probe of the container app"

  validation {
    error_message = "transport should be one of http, https, tcp"
    condition     = alltrue([for probe in var.startup_probes : contains(["http", "https", "tcp"], probe.transport)])
  }

  validation {
    error_message = "path must be specified if transport is http or https"
    condition     = alltrue([for probe in var.startup_probes : !(contains(["http", "https"], probe.transport) && (probe.path == null || probe.path == ""))])
  }
}

variable "central_key_vault_key_access_enabled" {
  type        = bool
  default     = false
  description = "Whether to grant the container app access to the keys in the central Key Vault"
}

variable "central_key_vault_secret_access_enabled" {
  type        = bool
  default     = false
  description = "Whether to grant the container app access to the secrets in the central Key Vault"
}

variable "add_grafana_alloy_env_vars" {
  type        = bool
  default     = false
  description = "Whether to add the necessary environment variables (e.g. for deploying a Grafana Alloy container)"
}

variable "http_scale_rules" {
  type = list(object({
    name                = string
    concurrent_requests = number
  }))
  default     = []
  description = "Configuration for HTTP scale rules"
}

variable "tcp_scale_rules" {
  type = list(object({
    name                = string
    concurrent_requests = number
  }))
  default     = []
  description = "Configuration for TCP scale rules"
}

variable "custom_scale_rules" {
  type = list(object({
    custom_rule_type = string
    metadata         = map(string)
    name             = string
  }))
  default     = []
  description = "Configuration for custom scale rules (e.g. KEDA)"
}

variable "ingress" {
  type = object({
    allow_insecure_connections = optional(bool, false)
    client_certificate_mode    = optional(string)
    exposed_port               = optional(number)
    external_enabled           = optional(bool, false)
    target_port                = number
    transport                  = optional(string, "Auto")
    ip_security_restriction = optional(list(object({
      action           = string
      description      = optional(string)
      ip_address_range = string
      name             = string
    })))
    traffic_weight = optional(list(object({
      label           = optional(string)
      latest_revision = bool
      percentage      = number
      revision_suffix = optional(string)
    })))
  })
  default     = null
  description = "Configuration for the ingress of the container app"

  validation {
    error_message = "transport should be one of Auto, Http, Http2, Tcp"
    condition     = var.ingress == null || try(var.ingress.transport, null) == null ? true : contains(["Auto", "Http", "Http2", "Tcp"], var.ingress.transport)
  }
}

variable "azure_ai_model_access_enabled" {
  type        = bool
  default     = false
  description = "Whether to grant the container app primary identity access to Azure AI services in the `UBIQAIxx` subscriptions"
}

variable "wkflo_sql_db_connection_enabled" {
  type        = bool
  default     = false
  description = "Whether to grant the container app access to the wkflo SQL database, and add the connection string as an environment variable"
}

variable "postgres_vector_db_connection_enabled" {
  type        = bool
  default     = false
  description = "Whether to grant the container app access to the PostgreSQL vector database, and add the connection string as an environment variable"
}

variable "elastic_search_connections" {
  type = object({
    standard_enabled                        = optional(bool, false)
    serilog_enabled                         = optional(bool, false)
    eis_enabled                             = optional(bool, false)
    serilog_elastic_search_datastream       = optional(string, "logs-wkflow")
    serilog_elastic_search_application_name = optional(string)
    serilog_elastic_search_level            = optional(string, "Info")
    eis_elastic_search_topk                 = optional(number, 10)
  })
  default = {
    standard_enabled = false
  }
  description = "Whether to grant the container app access to the Elastic cluster, and add the connection string as an environment variable"

  validation {
    error_message = "If elastic_search_connections.serilog_enabled is true then 'serilog_elastic_search_application_name' must be provided"
    condition     = !(var.elastic_search_connections.serilog_enabled && (var.elastic_search_connections.serilog_elastic_search_application_name == null || var.elastic_search_connections.serilog_elastic_search_application_name == ""))
  }
}

variable "blob_storage_connection_enabled" {
  type        = bool
  default     = false
  description = "Whether to grant the container app access to blob storage, and add the connection string as an environment variable"
}

variable "ai_embeddings_settings" {
  type = object({
    enabled         = bool
    deployment_name = optional(string)
  })
  default = {
    enabled = false
  }
  description = "Whether to add AI embeddings settings environment variables, and the name of the model to use for embeddings if enabled"

  validation {
    error_message = "If ai_embeddings_settings.enabled is true then 'deployment_name' must be provided"
    condition     = !(var.ai_embeddings_settings.enabled && (var.ai_embeddings_settings.deployment_name == null || var.ai_embeddings_settings.deployment_name == ""))
  }

  validation {
    error_message = "If ai_embeddings_settings.enabled is true then 'azure_ai_model_access_enabled' must also be true"
    condition     = !(var.ai_embeddings_settings.enabled && !var.azure_ai_model_access_enabled)
  }
}

variable "signalr_connection_enabled" {
  type        = bool
  default     = false
  description = "Whether to grant the container app access to Azure SignalR, and add the connection string as an environment variable"
}

variable "oltp_exporter_settings" {
  type = object({
    enabled      = bool
    service_name = optional(string)
    protocol     = optional(string, "grpc")
  })
  default = {
    enabled = false
  }
  description = "Whether to add environment variables for the OLTP Exporter, and grant access to the necessary resources"

  validation {
    error_message = "oltp_exporter_settings.service_name must be provided if oltp_exporter_settings.enabled is true"
    condition     = !(var.oltp_exporter_settings.enabled && (var.oltp_exporter_settings.service_name == null || var.oltp_exporter_settings.service_name == ""))
  }
}

variable "dapr" {
  type = object({
    enabled               = optional(bool)
    app_id                = optional(string)
    app_port              = optional(number)
    app_protocol          = optional(string)
    enable_api_logging    = optional(bool)
    http_max_request_size = optional(number)
    http_read_buffer_size = optional(number)
    log_level             = optional(string)
    max_concurrency       = optional(number)
    app_health = optional(object({
      enabled                    = optional(bool)
      path                       = optional(string)
      probe_interval_seconds     = optional(number)
      probe_timeout_milliseconds = optional(number)
      threshold                  = optional(number)
    }))
  })
  default     = null
  description = "Optional Dapr sidecar configuration for the Container App (properties.configuration.dapr)."

  validation {
    error_message = "dapr.app_protocol must be one of `http`, `grpc` when provided."
    condition     = var.dapr == null || try(var.dapr.app_protocol, null) == null ? true : contains(["http", "grpc"], lower(var.dapr.app_protocol))
  }

  validation {
    error_message = "dapr.log_level must be one of `debug`, `info`, `warn`, `error` when provided."
    condition     = var.dapr == null || try(var.dapr.log_level, null) == null ? true : contains(["debug", "info", "warn", "error"], lower(var.dapr.log_level))
  }
}

variable "runtime" {
  type = object({
    name                                  = string
    dotnet_auto_configure_data_protection = optional(bool)
    java_enable_metrics_exporter          = optional(bool)
  })
  default = {
    name                                  = "dotnet"
    dotnet_auto_configure_data_protection = true
  }
  description = "Optional runtime configuration for the Container App (properties.configuration.runtime)."

  validation {
    error_message = "Supported values for name are `dotnet`, `java` or `generic`."
    condition     = var.runtime == null ? true : contains(["dotnet", "java", "generic"], var.runtime.name)
  }

  validation {
    error_message = "dotnet_auto_configure_data_protection can only be used when runtime.name is `dotnet`."
    condition     = var.runtime == null || var.runtime.name != "dotnet" ? true : try(var.runtime.dotnet_auto_configure_data_protection, null) != null
  }

  validation {
    error_message = "java_enable_metrics_exporter can only be used when runtime.name is `java`."
    condition     = var.runtime == null || var.runtime.name != "java" ? true : try(var.runtime.java_enable_metrics_exporter, null) != null
  }
}

variable "bunny_pullzone_config" {
  type = object({
    add_pullzone               = optional(bool)
    pullzone_name              = optional(string)
    cache_enabled              = optional(bool)
    cache_expiration_time      = optional(number)
    cache_errors               = optional(bool)
    cache_vary                 = optional(list(string))
    cache_chunked              = optional(bool)
    cors_enabled               = optional(bool)
    cors_extensions            = optional(list(string))
    add_canonical_header       = optional(bool)
    safehop_enabled            = optional(bool)
    safehop_connection_timeout = optional(number)
    safehop_response_timeout   = optional(number)
    safehop_retry_count        = optional(number)
    safehop_retry_delay        = optional(number)
    safehop_retry_reasons      = optional(list(string))
    block_root_path            = optional(bool)
    sort_querystring           = optional(bool)
    strip_cookies              = optional(bool)
    request_coalescing_enabled = optional(bool)
    websockets_enabled         = optional(bool)
    websockets_max_connections = optional(number)
    log_forward_enabled        = optional(bool)
    log_forward_format         = optional(string)
    log_forward_port           = optional(number)
    log_forward_protocol       = optional(string)
    log_forward_server         = optional(string)
    log_forward_token          = optional(string)
    origin = optional(object({
      verify_ssl          = optional(bool)
      follow_redirects    = optional(bool)
      forward_host_header = optional(bool)
      host_header         = optional(string)
      middleware_script   = optional(number)
      script              = optional(number)
      storagezone         = optional(number)
    }))
    routing = optional(object({
      tier  = optional(string)
      zones = optional(list(string))
    }))
    optimizer_enabled                     = optional(bool)
    optimizer_webp                        = optional(bool)
    optimizer_dynamic_image_api           = optional(bool)
    optimizer_burrow                      = optional(bool)
    optimizer_classes_force               = optional(bool)
    optimizer_html_prerender              = optional(bool)
    optimizer_minify_css                  = optional(bool)
    optimizer_minify_js                   = optional(bool)
    optimizer_smartimage                  = optional(bool)
    optimizer_smartimage_desktop_maxwidth = optional(number)
    optimizer_smartimage_desktop_quality  = optional(number)
    optimizer_smartimage_mobile_maxwidth  = optional(number)
    optimizer_smartimage_mobile_quality   = optional(number)
    optimizer_watermark                   = optional(bool)
    optimizer_watermark_borderoffset      = optional(number)
    optimizer_watermark_minsize           = optional(number)
    optimizer_watermark_position          = optional(string)
    optimizer_watermark_url               = optional(string)
  })
  default     = {}
  description = <<DESCRIPTION
  Configuration for the bunny pullzone.
  For valid values, refer to https://registry.terraform.io/providers/BunnyWay/bunnynet/latest/docs/resources/pullzone
  DESCRIPTION
}

variable "bunny_pullzone_additional_edge_rules" {
  type = map(object({
    description = string
    enabled     = optional(bool, true)
    priority    = number
    actions = list(object({
      type       = string
      parameter1 = optional(string)
      parameter2 = optional(string)
      parameter3 = optional(string)
    }))
    match_type = string
    triggers = list(object({
      type       = string
      match_type = string
      patterns   = list(string)
      parameter1 = optional(string)
      parameter2 = optional(string)
    }))
  }))
  default     = {}
  description = <<DESCRIPTION
  Optional: Additional Bunny CDN edge rules to apply.
  Priority is an integer value that determines the order of the rules, starting at 1.
  The specified priority will be used to order the additional rules relative to each other.
  Rules will be added after the default rules.
  DESCRIPTION
}

variable "bunny_pullzone_shield_config" {
  type = object({
    tier       = optional(string)
    whitelabel = optional(bool)
    ddos = optional(object({
      level            = optional(string, "Low")
      challenge_window = optional(number, 3600)
    }))
    waf = optional(object({
      # Ensure variable defaults matches the default in bunny.waf for an empty variable for consistency
      enabled                       = optional(bool)
      allowed_http_methods          = optional(list(string), ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"])
      allowed_http_versions         = optional(list(string))
      allowed_request_content_types = optional(list(string))
      blocking_sensitivity          = optional(number)
      body_limit_request            = optional(string)
      body_limit_response           = optional(string)
      detection_sensitivity         = optional(number)
      execution_sensitivity         = optional(number)
      log_headers                   = optional(bool)
      log_headers_excluded          = optional(list(string))
      mode                          = optional(string, "Log")
      realtime_threat_intelligence  = optional(bool)
      rules_disabled                = optional(list(string), ["952100", "953100", "953101", "953110", "953120", "DDoS-0ad5f8", "SHL-G8", "941160", "932125"])
      rules_logonly                 = optional(list(string), ["932235", "941100", "921130", "933120", "942100", "942550", "932370"])
    }))
    bot_detection = optional(object({
      complex_fingerprinting  = optional(bool)
      fingerprint_aggression  = optional(number)
      fingerprint_sensitivity = optional(number)
      ip_sensitivity          = optional(number)
      mode                    = optional(string, "Log")
      request_integrity       = optional(number)
    }))
    access_list = optional(set(object({
      action = string
      id     = number
    })), [])
  })
  default     = {}
  description = <<DESCRIPTION
  Optional: Custom configuration for the Bunny pull zone shield, defaults will be used for values not supplied.
  For valid values, refer to https://registry.terraform.io/providers/BunnyWay/bunnynet/latest/docs/resources/pullzone_shield
  DESCRIPTION
}

variable "bunny_pullzone_custom_waf_rules" {
  type = map(object({
    name            = string
    description     = string
    transformations = optional(list(string))
    condition = map(object({
      operator       = string
      value          = string
      variable       = string
      variable_value = optional(string)
    }))
    response = object({
      action = string
    })
  }))
  default     = {}
  description = <<DESCRIPTION
  Optional: Pull zone shield waf rules to apply.
  For valid property values, refer to https://registry.terraform.io/providers/BunnyWay/bunnynet/latest/docs/resources/pullzone_waf_rule
  DESCRIPTION
}

variable "bunny_pullzone_additional_rate_limit_rules" {
  type = map(object({
    name            = string
    description     = string
    transformations = optional(list(string))
    condition = map(object({
      operator       = string
      value          = string
      variable       = string
      variable_value = optional(string)
    }))
    limit = object({
      requests = number
      interval = optional(number, 1)
    })
    response = object({
      interval = optional(number, 60)
    })
  }))
  default     = {}
  description = <<DESCRIPTION
  Optional: Pull zone shield rate limit rules to apply.
  For valid property values, refer to https://registry.terraform.io/providers/BunnyWay/bunnynet/latest/docs/resources/pullzone_ratelimit_rule
  DESCRIPTION
}

variable "bot_detection_disable_paths" {
  type        = list(string)
  default     = []
  description = "A list of URL paths to disable Bunny bot detection"
}

variable "waf_rules_disable_paths" {
  type        = list(string)
  default     = []
  description = "A list of URL paths to disable Bunny WAF rules"
}

variable "bunny_hostnames" {
  type        = map(string)
  default     = {}
  description = "Map of hostnames to add to the bunny hostname, must end in wkflo.ai or amais.com"

  validation {
    error_message = "Supported domains are wkflo.ai or amais.com"
    condition = alltrue([
      for v in values(var.bunny_hostnames) : endswith(v, ".amais.com") || endswith(v, ".wkflo.ai")
    ])
  }
}

variable "syslog_token" {
  type        = string
  sensitive   = true
  default     = null
  description = "Value for the Bunny syslog token"
}

variable "dxp_client_enabled" {
  type        = bool
  default     = false
  description = "Whether to grant the container app access to the DXP client, and add the required configuration."
}

variable "dxp_report_client_enabled" {
  type        = bool
  default     = false
  description = "Whether to attach the WKFLO DXP client managed identity and add the DXP Report API client configuration (AMAIS_DXP_REPORT_SERVER_URL, ReportClientOAuthSettings__*). Independent of dxp_client_enabled."
}

variable "mcp_oauth_token_encryption_enabled" {
  type        = bool
  default     = false
  description = "Whether to grant the container app access to the MCP OAuth token encryption key, and add it as an environment variable"
}

variable "redis_cache_connection_enabled" {
  type        = bool
  default     = false
  description = "Whether to add the CAE Azure Managed Redis endpoint and the CAE identity client ID as environment variables, for the EF second-level cache"
}
