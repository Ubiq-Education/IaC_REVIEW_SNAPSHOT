resource "azapi_resource" "versionless" {
  count = var.ignore_image_version ? 1 : 0

  type                      = "Microsoft.App/containerApps@2026-03-02-preview"
  name                      = var.name
  parent_id                 = data.azurerm_resource_group.parent.id
  location                  = data.azurerm_container_app_environment.cae.location
  tags                      = var.tags
  schema_validation_enabled = false
  body                      = local.container_app_body

  dynamic "identity" {
    for_each = local.container_app_identity_user_assigned == null ? [] : [1]

    content {
      type         = "UserAssigned"
      identity_ids = keys(local.container_app_identity_user_assigned)
    }
  }

  lifecycle {
    ignore_changes = [
      body.properties.template.containers[0].image,
      body.properties.template.revisionSuffix,
      body.properties.configuration.ingress.traffic
    ]
  }

  response_export_values           = ["properties.configuration"]
  replace_triggers_external_values = [var.runtime] # Current API version doesn't update runtime properly, so we need to trigger replacement
  ignore_casing                    = true
}
