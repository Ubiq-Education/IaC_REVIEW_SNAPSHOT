terraform {
  required_version = "~>1.13"

  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "~>4.0"
      configuration_aliases = [azurerm.shared]
    }

    azapi = {
      source  = "azure/azapi"
      version = "~>2.6"
    }

    time = {
      source  = "hashicorp/time"
      version = "~>0.13"
    }
  }
}
