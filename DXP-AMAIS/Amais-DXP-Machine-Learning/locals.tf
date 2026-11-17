locals {
  sub_id                                  = "c94f8a3d-8d0b-4660-85de-26004f233dbf"
  az_long_region                          = "uksouth"
  az_short_region                         = "uks"
  resource_group_name                     = "Amais-DXP"
  deployment_name                         = "mlw-${local.az_short_region}-amaisdxp"
  st_name                                 = "stmlwuksamaisdxp"
  st_id_name                              = "id-st-uks-${local.st_name}"
  mlw_id_name                             = "id-${local.deployment_name}"
  mlw_comp_id_name                        = "id-comp-${local.deployment_name}"
  azure_rbac_ai_developer_group_object_id = "3b9500e0-923f-4669-9f36-dc9e3bd8c34b"
  common_tags = {
    deployment_method = "terraform"
    environment       = "prod"
  }
}
