terraform {
  required_version = "~>1.9"

  backend "azurerm" {
    use_azuread_auth     = true
    subscription_id      = "a3236c88-aba1-449e-879a-272e0c2ac067"
    storage_account_name = "sttfstatestorage01"
    container_name       = "ubiq-dxp"
    key                  = "amais-dxp-shared-infra.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }

    azapi = {
      source  = "azure/azapi"
      version = "~>2.9"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~>3.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~>3.6"
    }

    time = {
      source  = "hashicorp/time"
      version = "~>0.12"
    }
  }
}
