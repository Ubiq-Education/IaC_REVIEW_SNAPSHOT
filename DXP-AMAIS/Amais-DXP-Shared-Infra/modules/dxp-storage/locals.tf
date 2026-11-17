locals {
  short_region                 = module.short-region-lookup.short_region
  diag_settings_name           = "default_diagnostic_settings"
  log_analytics_workspace_name = "log-uks-ubiq-shared-logging"
  log_analytics_workspace_rg   = "rg-uks-ubiq-shared-logging"
  kv_rg                        = "Amais-DXP"
  st_name                      = "st${local.short_region}${lower(substr(random_id.main.hex, 0, 5))}${var.storage_purpose_short_name}"
  common_tags = {
    deployment_method = "terraform"
  }
  tags = merge(var.tags, local.common_tags)
  environments = {
    staging = {
      short_id = "s"
      tags = {
        environment = "staging"
      }
      role_assignments = { for k, v in var.staging_role_assignments : k => {
        role_definition_id_or_name = v.role_name
        principal_id               = v.principal_id
        }
      }
    }
    production = {
      short_id = "p"
      tags = {
        environment = "prod"
      }
      role_assignments = { for k, v in var.production_role_assignments : k => {
        role_definition_id_or_name = v.role_name
        principal_id               = v.principal_id
        }
      }
    }
  }
}
