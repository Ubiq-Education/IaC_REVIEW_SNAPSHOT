terraform {
  required_version = "~>1.13"

  backend "azurerm" {
    use_azuread_auth     = true
    subscription_id      = "a3236c88-aba1-449e-879a-272e0c2ac067"
    storage_account_name = "sttfstatestorage01"
    container_name       = "ubiq-shared"
    key                  = "" # This will be set in the environment-specific backend.tfbackend file
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "<5.0"
    }

    azapi = {
      source  = "azure/azapi"
      version = "~>2.6"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~>3.7"
    }

    random = {
      source  = "hashicorp/random"
      version = "~>3.6"
    }

    time = {
      source  = "hashicorp/time"
      version = "~>0.13"
    }

    http = {
      source  = "hashicorp/http"
      version = "~>3.0"
    }
  }
}
