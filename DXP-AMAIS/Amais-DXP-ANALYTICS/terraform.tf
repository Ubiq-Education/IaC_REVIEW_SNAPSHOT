terraform {
  required_version = "~>1.9"

  backend "azurerm" {
    use_azuread_auth     = true
    subscription_id      = "a3236c88-aba1-449e-879a-272e0c2ac067"
    storage_account_name = "sttfstatestorage01"
    container_name       = "ubiq-dxp"
    key                  = "amais-dxp-analytics.tfstate"
  }
}
