locals {
  webapp_name            = "Amais-DXP-INGRESS"
  x_azure_fdid_value     = uuidv5("url", "https://${lower(local.webapp_name)}.azurewebsites.net")
  bunny_pullzone_name    = "pz-amais-dxp-ingress"
  dns_alias_name         = "ingress.dxp"
  dns_alias_staging_name = "ingress-staging.dxp"
  dns_alias_zone_name    = "amais.com"
  common_tags = {
    deployment_method = "terraform"
    environment       = "prod"
  }
}
