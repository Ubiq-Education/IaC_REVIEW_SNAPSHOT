module "short-region-lookup" {
  source         = "api.controlmonkey.io/o-26drsisx9g/short-region-lookup/azurerm"
  version        = "~>1.0.0"
  az_long_region = var.cae_location
}

module "container_app" {
  source                  = "./modules/container_app"
  azurerm_client_config   = data.azurerm_client_config.current
  ignore_image_version    = var.ignore_image_version
  name                    = var.name
  cae_resource_id         = var.cae_resource_id
  resource_group_name     = var.resource_group_name
  tags                    = var.tags
  additional_identity_ids = local.additional_identity_ids
  entra_auth              = local.entra_auth
  azure_conainter_registry = {
    login_server         = var.azure_conainter_registry.login_server
    identity_resource_id = var.azure_conainter_registry.identity_resource_id
  }
  app_secrets = merge({
    for id, v in var.key_vault_secret_ids :
    id => data.azurerm_key_vault_secret.app_secrets[id].value
    }, var.app_secrets
  )
  template                              = var.template
  ingress                               = var.ingress
  dapr                                  = var.dapr
  runtime                               = var.runtime
  local_app_instance_identity_client_id = var.create_app_instance_identity ? module.avm-res-managedidentity-userassignedidentity-app[0].client_id : null
  app_primary_identity = {
    id        = local.app_primary_identity.id
    client_id = local.app_primary_identity.client_id
  }
  cae_key_vault_uri = data.azurerm_key_vault.cae.vault_uri
}

resource "azurerm_container_app_custom_domain" "main" {
  for_each = var.custom_domains

  container_app_id                         = module.container_app.container_app.id
  name                                     = each.value.name
  certificate_binding_type                 = each.value.certificate_binding_type
  container_app_environment_certificate_id = each.value.container_app_environment_certificate_id

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
    }
  }

  lifecycle {
    ignore_changes = [certificate_binding_type, container_app_environment_certificate_id]
  }
}

resource "azapi_resource" "managed_certificates" {
  for_each = var.custom_domains

  type      = "Microsoft.App/managedEnvironments/managedCertificates@2025-01-01"
  name      = each.value.name
  parent_id = var.cae_resource_id
  location  = var.cae_location
  tags      = var.tags
  body = {
    properties = {
      domainControlValidation = each.value.domain_control_validation
      subjectName             = each.value.name
    }
  }

  depends_on = [azurerm_container_app_custom_domain.main]

  response_export_values = ["properties.subjectName"]
}

resource "azapi_update_resource" "custom_domain_binding" {
  for_each = var.custom_domains

  type        = "Microsoft.App/containerApps@2025-01-01"
  resource_id = module.container_app.container_app.id
  body = {
    properties = {
      configuration = {
        ingress = {
          customDomains = [
            {
              name          = azapi_resource.managed_certificates[each.key].output.properties.subjectName
              certificateId = azapi_resource.managed_certificates[each.key].id
              bindingType   = "SniEnabled"
            }
          ]
        }
        # Re-adding secrets is a temporary workaround because of a bug in the Azure API that hides the secret values but then
        # blocks updates to the configuration because it thinks the secrets are missing rquired values.
        # Can be replaced with new container_app_environment_managed_certificate from https://github.com/hashicorp/terraform-provider-azurerm/pull/31137
        secrets = flatten(concat([
          length(local.entra_auth) > 0 ? [{
            name  = "override-use-mi-fic-assertion-client-id"
            value = local.app_primary_identity.client_id
          }] : [],
          [for secret, v in var.key_vault_secret_ids : {
            name  = secret
            value = data.azurerm_key_vault_secret.app_secrets[secret].value
          }]
        ]))
      }
    }
  }

  depends_on = [azurerm_container_app_custom_domain.main]

  response_export_values = ["properties.configuration.ingress.customDomains"]
}
