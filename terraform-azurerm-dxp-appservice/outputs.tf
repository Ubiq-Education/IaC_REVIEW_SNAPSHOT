output "production_identity_resource_id" {
  value = module.avm-res-managedidentity-userassignedidentity-app.resource_id
}

output "production_identity_principal_id" {
  value = module.avm-res-managedidentity-userassignedidentity-app.principal_id
}

output "staging_identity_resource_id" {
  value = module.avm-res-managedidentity-userassignedidentity-app-staging.resource_id
}

output "staging_identity_principal_id" {
  value = module.avm-res-managedidentity-userassignedidentity-app-staging.principal_id
}
