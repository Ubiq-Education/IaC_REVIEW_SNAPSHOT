terraform {
  required_version = "~>1.9"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~>2.10"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~>3.0"
    }

    http = {
      source  = "hashicorp/http"
      version = "~>3.4"
    }
  }
}
