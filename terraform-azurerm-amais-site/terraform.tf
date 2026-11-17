terraform {
  required_version = "~>1.14"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "<5.0"
    }

    azapi = {
      source  = "azure/azapi"
      version = "~>2.0"
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

    http = {
      source  = "hashicorp/http"
      version = "~>3.0"
    }

    bunnynet = {
      source  = "BunnyWay/bunnynet"
      version = "~>0.19.0"
    }

    restful = {
      source  = "magodo/restful"
      version = "0.25.2"
    }

    azureactions = {
      source  = "WebedMJ/azureactions"
      version = "~>1.3"
    }
  }
}
