output "primary_identity" {
  value = {
    principal_id = module.avm-res-managedidentity-userassignedidentity-app.principal_id
    resource_id  = module.avm-res-managedidentity-userassignedidentity-app.resource_id
    client_id    = module.avm-res-managedidentity-userassignedidentity-app.client_id
  }
}

output "container_app_output" {
  value = module.cae_app.container_app.output
}

output "container_app_id" {
  value = module.cae_app.container_app.id
}
