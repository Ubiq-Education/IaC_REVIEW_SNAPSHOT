provider "azurerm" {
  subscription_id     = var.sub_id
  storage_use_azuread = true

  features {

    resource_group {
      prevent_deletion_if_contains_resources = false
    }

    key_vault {
      purge_soft_deleted_certificates_on_destroy = true
      purge_soft_deleted_keys_on_destroy         = true
      purge_soft_deleted_secrets_on_destroy      = true
      recover_soft_deleted_certificates          = true
      recover_soft_deleted_keys                  = true
      recover_soft_deleted_secrets               = true
      recover_soft_deleted_key_vaults            = true
    }
  }
}

provider "azurerm" {
  alias               = "shared"
  subscription_id     = local.shared_sub_id
  storage_use_azuread = true

  features {

    resource_group {
      prevent_deletion_if_contains_resources = true
    }

    key_vault {
      purge_soft_deleted_certificates_on_destroy = true
      purge_soft_deleted_keys_on_destroy         = true
      purge_soft_deleted_secrets_on_destroy      = true
      recover_soft_deleted_certificates          = true
      recover_soft_deleted_keys                  = true
      recover_soft_deleted_secrets               = true
      recover_soft_deleted_key_vaults            = true
    }
  }
}
