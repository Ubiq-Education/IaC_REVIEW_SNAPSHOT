locals {
  sub_id               = "c94f8a3d-8d0b-4660-85de-26004f233dbf"
  subnet_identifier    = element(split("-", local.sub_id), 0)
  ubiq_action_group_rg = "rg-uks-ubiq-shared-res"
  resource_group_name  = "Amais-DXP"
  dxp_regions = [
    "uksouth",
    "centralus",
    "canadacentral",
    "germanywestcentral",
    "uaenorth"
  ]
  dxp_sql_dtu_dbs_uks = {
    "AMAIS-DXP-ANALYTICS-STAGING" = {
      sku_name    = "Basic"
      max_size_gb = 2
    }
    "AMAIS-DXP-ANALYTICS" = {
      sku_name    = "S3"
      max_size_gb = 50
    }
    "AMAIS-DXP-STAGING-LOGGING" = {
      sku_name    = "Basic"
      max_size_gb = 2
    }
    "AMAIS-DXP-LOGGING" = {
      sku_name    = "Basic"
      max_size_gb = 2
    }
    "AMAIS-DXP-MD-STAGING" = {
      sku_name    = "Basic"
      max_size_gb = 2
    }
    "AMAIS-DXP-MD" = {
      sku_name    = "S4"
      max_size_gb = 50
    }
  }
  common_tags = {
    deployment_method = "terraform"
    environment       = "prod"
  }
  data_tags = {
    confidential = {
      data_classification = "confidential"
    }
    public = {
      data_classification = "public"
    }
  }
  lock_note = "This resource is locked by Terraform"
}
