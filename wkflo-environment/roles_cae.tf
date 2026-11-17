# Global role for CAE identity to pull from ACR
resource "azurerm_role_assignment" "global_cae_acr_pull" {
  scope                = data.azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = module.avm-res-managedidentity-userassignedidentity-global-arcpull.principal_id

  depends_on = [time_sleep.azurerm_userassignedidentity_all]
}

resource "time_sleep" "roles_acr" {
  create_duration = "30s"

  triggers = merge(
    {
      global_cae_acr_pull = azurerm_role_assignment.global_cae_acr_pull.id
    }, {}
  )
}
