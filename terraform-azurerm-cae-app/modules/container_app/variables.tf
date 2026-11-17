variable "azurerm_client_config" {
  type        = any
  description = "Output of data.azurerm_client_config"
}

variable "ignore_image_version" {
  type        = bool
  default     = false
  description = "Whether to ignore changes in the container image version to allow new container images releases outside of Terraform."
}

variable "name" {
  type = string
}

variable "cae_resource_id" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "additional_identity_ids" {
  type = list(string)
}

variable "app_secrets" {
  type = map(string)
}

variable "entra_auth" {}

variable "azure_conainter_registry" {
  type = object({
    login_server         = string
    identity_resource_id = string
  })
}

variable "template" {
  type = object({
    max_replicas    = optional(number)
    min_replicas    = optional(number)
    revision_suffix = optional(string)
    containers = list(object({
      args    = optional(list(string))
      command = optional(list(string))
      cpu     = number
      image   = string
      memory  = string
      name    = string
      env = optional(list(object({
        name        = string
        secret_name = optional(string)
        value       = optional(string)
      })))
      liveness_probes = optional(list(object({
        failure_count_threshold = optional(number, 5)
        host                    = optional(string)
        initial_delay           = optional(number)
        interval_seconds        = optional(number)
        path                    = optional(string)
        port                    = number
        timeout                 = optional(number)
        transport               = string
        header = optional(list(object({
          name  = string
          value = string
        })))
      })))
      readiness_probes = optional(list(object({
        failure_count_threshold = optional(number, 30)
        host                    = optional(string)
        initial_delay           = optional(number)
        interval_seconds        = optional(number)
        path                    = optional(string)
        port                    = number
        success_count_threshold = optional(number, 3)
        timeout                 = optional(number)
        transport               = string
        header = optional(list(object({
          name  = string
          value = string
        })))
      })))
      startup_probes = optional(list(object({
        failure_count_threshold = optional(number, 10)
        host                    = optional(string)
        initial_delay           = optional(number)
        interval_seconds        = optional(number)
        path                    = optional(string)
        port                    = number
        timeout                 = optional(number)
        transport               = string
        header = optional(list(object({
          name  = string
          value = string
        })))
      })))
      volume_mounts = optional(list(object({
        name     = string
        path     = string
        sub_path = optional(string)
      })))
    }))
    azure_queue_scale_rules = optional(list(object({
      name         = string
      queue_length = number
      queue_name   = string
      authentication = list(object({
        secret_name       = string
        trigger_parameter = string
      }))
    })))
    custom_scale_rules = optional(list(object({
      custom_rule_type = string
      metadata         = map(string)
      name             = string
      authentication = optional(list(object({
        secret_name       = string
        trigger_parameter = string
      })))
    })))
    http_scale_rules = optional(list(object({
      concurrent_requests = string
      name                = string
      authentication = optional(list(object({
        secret_name       = string
        trigger_parameter = optional(string)
      })))
    })))
    init_containers = optional(list(object({
      args    = optional(list(string))
      command = optional(list(string))
      cpu     = optional(number)
      image   = string
      memory  = optional(string)
      name    = string
      env = optional(list(object({
        name        = string
        secret_name = optional(string)
        value       = optional(string)
      })))
      volume_mounts = optional(list(object({
        name     = string
        path     = string
        sub_path = optional(string)
      })))
    })))
    tcp_scale_rules = optional(list(object({
      concurrent_requests = string
      name                = string
      authentication = optional(list(object({
        secret_name       = string
        trigger_parameter = optional(string)
      })))
    })))
    volumes = optional(list(object({
      name          = string
      storage_name  = optional(string)
      storage_type  = optional(string)
      mount_options = optional(string)
      secrets = optional(list(object({
        path       = string
        secret_ref = string
      })))
    })))
  })
}

variable "local_app_instance_identity_client_id" {
  type    = string
  default = null
}

variable "app_primary_identity" {
  type = object({
    id        = string
    client_id = string
  })
}

variable "ingress" {
  type = object({
    allow_insecure_connections = optional(bool)
    client_certificate_mode    = optional(string)
    exposed_port               = optional(number)
    external_enabled           = optional(bool)
    target_port                = number
    transport                  = optional(string)
    ip_security_restriction = optional(list(object({
      action           = string
      description      = optional(string)
      ip_address_range = string
      name             = string
    })))
    traffic_weight = list(object({
      label           = optional(string)
      latest_revision = optional(bool)
      percentage      = number
      revision_suffix = optional(string)
    }))
  })
  default = null
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
  default = null
}

variable "runtime" {
  type = object({
    name                                  = string
    dotnet_auto_configure_data_protection = optional(bool)
    java_enable_metrics_exporter          = optional(bool)
  })
  default = null
}

variable "cae_key_vault_uri" {
  type = string
}
