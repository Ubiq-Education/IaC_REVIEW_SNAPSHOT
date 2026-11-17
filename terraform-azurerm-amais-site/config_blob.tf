locals {
  # Same asset environment the web app's staging slot uses for dev sites (prod otherwise)
  dev_captcha_assets_env = var.dev_site != "no" && contains(local.captcha_environments, "staging") ? "staging" : "prod"

  env_var_blob = {
    environmentVariables = merge(
      {
        AMS_CDN_PATH                = local.ams_cdn_path
        Application                 = local.amais_application_name
        ASPNETCORE_ENVIRONMENT      = "Localfed"
        AZURE_TENANT_ID             = local.azure_tenant_id
        AZURE_SUBSCRIPTION_ID       = var.sub_id
        AZURE_TOKEN_CREDENTIALS     = "dev"
        BLOB_STORAGE_ACCOUNT_URI    = module.avm-res-storage-storageaccount.resource.output.properties.primaryEndpoints.blob
        BLOB_STORAGE_ROOT_CONTAINER = local.blob_storage_root_container
        BLOB_STORAGE_CDN_CONTAINER  = "$web"
        KEY_VAULT_URI               = module.avm-res-keyvault-vault.uri
        CDN_PROVIDER                = local.cdn_provider
        DATA_ENCRYPTION_KEY_NAME    = azurerm_key_vault_key.amais.name
        DB_CONNECTION_STRING = join("", [
          "Server=tcp:${azurerm_mssql_server.main.fully_qualified_domain_name},1433;",
          "Initial Catalog=${azurerm_mssql_database.main.name};",
          "Authentication=Active Directory Default;",
          "MultipleActiveResultSets=True;",
          "Encrypt=True;",
          "TrustServerCertificate=False;",
          "Connection Timeout=60;"
        ])
        DB_USER_CONNECTION_STRING = join("", [
          "Server=tcp:${data.azurerm_mssql_server.central_amais.fully_qualified_domain_name},1433;",
          "Initial Catalog=${local.central_amais_sqldb_initial_catalog};",
          "Authentication=Active Directory Default;",
          "MultipleActiveResultSets=False;",
          "Encrypt=True;",
          "TrustServerCertificate=False;",
          "Connection Timeout=60;"
        ])
        NLOG_CONNECTION_STRING = join("", [
          "Server=tcp:${azurerm_mssql_server.main.fully_qualified_domain_name},1433;",
          "Initial Catalog=${azurerm_mssql_database.main.name};",
          "Authentication=Active Directory Default;",
          "MultipleActiveResultSets=True;",
          "Encrypt=True;",
          "TrustServerCertificate=False;",
          "Connection Timeout=60;"
        ])
        TEMPLATES_FOLDER                            = local.templates_folder
        ROOT_CDN_PATH                               = "/cdn"
        EMAIL_MODULE_ENABLED                        = "false"
        DISABLE_BRANCH_REDIRECTS                    = "true"
        CKEDITOR_API_KEY_SECRET_NAME                = data.azurerm_key_vault_secret.ckeditor_apikey_staging.name
        CKEDITOR_IMPORT_WORD_SECRET_KEY_SECRET_NAME = data.azurerm_key_vault_secret.ckeditor_secretkey_staging.name
        CKEditor_Import_Word_Url                    = "https://docx-converter-staging.amais.com"
        CKEditor_Import_Word_Audience               = local.ckeditor_api_identifier_uri.staging
        SSO_SAML_UBIQ_ENTITY_ID                     = "UbiqAMAIS-petracmsdev"
        SSO_SAML_UBIQ_LOGIN_URL                     = "https://login.microsoftonline.com/414ca595-4008-478e-a036-953f19733f2e/saml2"
        SSO_SAML_UBIQ_LOGOUT_URL                    = ""
        SSO_SAML_UBIQ_CERT_1                        = "MIIC8DCCAdigAwIBAgIQUUiXQOqIGZ9FvBHyL079azANBgkqhkiG9w0BAQsFADA0MTIwMAYDVQQDEylNaWNyb3NvZnQgQXp1cmUgRmVkZXJhdGVkIFNTTyBDZXJ0aWZpY2F0ZTAeFw0yNTEwMTcxMTIzMzdaFw0yODEwMTcxMTIzNDhaMDQxMjAwBgNVBAMTKU1pY3Jvc29mdCBBenVyZSBGZWRlcmF0ZWQgU1NPIENlcnRpZmljYXRlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA36pJ0Xhzr0N0qwwZVHYlSJ9MA2ueY38Z2kxEC8EiP4xuwfCAWVoqYSs4qeb/KkvykdHn22biPvN1fBYEgH87s8t1IJ/5HdD4DLMMnhGzNF0qhlXvFUkRn1YPKZZWLnBR/emL8fUdLyqMrcjUvdNTTSqmEcZGtwt4lG2KbbtmMC49W/FMDJgwnDoTJm5oQCI9zxazl8I8W1wCu6bn/VpCffk3E9cJ1YUa4yfpJOwPhB+CmOA1cNwXVFMMNaBezQOPgc2Skm76iZDv6idNQT2UV2KmYw71pTlPVyLRljlkuOA3F1LcpsI2NrwSUs/rO610OzEYbwD9Mx+HnlhOLC1FEQIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQDE5KCGud8VP4//3OJaTXMyT6x5Z2u2NGQ4iPmnfo5/Ew+Wt8PM5K3ceEaqYM1Egh0X0Z5zeLS8NS0gFpJup4OHxk3mDUwX6eeu9131EYg0Obp9/CZ9lW7dqCeKEVboHCbNpMydgzrdGgmf55rLunRntP+fnU0Gh3xhN2UbzJi07XXv3Ix5AdDB3s5VDVpQdP6YinmTqBRrwRLN7e69y+1M2GxDHn0vX/w5as0MODVcxZd9OYNg1yZ/Od4WlPOfmF916tRi8q/VPFyfui5VqSeJf1+fve2k/1d3HPbL0BtpmDHsBmGpww7RLT82bLRpV8v5ZRCjWjZP8geHL/3ifS0O"
        SSO_SAML_UBIQ_CERT_2                        = "MIIC8DCCAdigAwIBAgIQW3g2entPh4VMhhA32g956jANBgkqhkiG9w0BAQsFADA0MTIwMAYDVQQDEylNaWNyb3NvZnQgQXp1cmUgRmVkZXJhdGVkIFNTTyBDZXJ0aWZpY2F0ZTAeFw0yNTExMDcwOTEzNDJaFw0yODExMDcwOTEzNDJaMDQxMjAwBgNVBAMTKU1pY3Jvc29mdCBBenVyZSBGZWRlcmF0ZWQgU1NPIENlcnRpZmljYXRlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA56/azEGp8dGeX637pPUbQzYrxCT38GVs9Uh1kxeHI4iZr+8PrE3TxgOG3F7N498Re0LjGVbTO4qadAgUlxvZkDhCT/zrQ7NgXP1ECBQiVCx2WltiFioV0AMVXPx5IdbktL+F4ppgMhDEM1BXFuCa55juckLingzoDn8sYz3Dr9+JqcEIAWihnvv19ND4+19eIGJMuQNMqij4S2UlZfDa3IT6CR/b+3OSBtHGnEj3glJf78JnbtWCSUKIk1gl0u4aVrS/GHxBJB1Zl7ShmZCVXe5Y4tMLT12ss+MYfb57F1Fv1htLU9EazzTa1iAJJQjnDmkmL9l6KYEKqbS+D5dVnQIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQBXm19A7mTFRb67tFWUWmlzWDMoG6yLPGpF5BjdIaKwoIk0rbvno5lJpaPc0JD8xssIuDHgyAp6xZI1yIcbylyJa3d4lEQw/IpldAOfXzRQ3EGcJXkqJt+Y/S5jbLKPl5KzRLj5Y209bpXBRujxgeKZ4JoQ7O2+ffIg4HKAtnwzxdmoqpaiBVb1bEE4sub/utBZqVv9NK00MdVf3Ivs4ypBgeRGEGUmJ11VIucH1++wsSDzZG93jbHiHfcBcNlxuPcB9jC3vwUqOnjxl4DleHtsgpEsNI+CLlz2NdHE0j4TGz+NS7I9wFZpjjf4Je45hrXX0dx8aSSeWC7rslAE61/s"
        UBIQ_CAPTCHA_API_ENDPOINT                   = data.azurerm_key_vault_secret.devconfig_ubiq_captcha["DEVCONFIG-UBIQ-CAPTCHA-API-ENDPOINT"].value
        UBIQ_CAPTCHA_SITEVERIFY_URL                 = data.azurerm_key_vault_secret.devconfig_ubiq_captcha["DEVCONFIG-UBIQ-CAPTCHA-SITEVERIFY-URL"].value
        UBIQ_CAPTCHA_SITE_KEY                       = data.azurerm_key_vault_secret.devconfig_ubiq_captcha["DEVCONFIG-UBIQ-CAPTCHA-SITE-KEY"].value
        UBIQ_CAPTCHA_WIDGET_URL                     = local.captcha_assets[local.dev_captcha_assets_env].widget
        UBIQ_CAPTCHA_WASM_URL                       = local.captcha_assets[local.dev_captcha_assets_env].wasm
        UBIQ_CAPTCHA_HASHWX_URL                     = local.captcha_assets[local.dev_captcha_assets_env].hashwx
        UBIQ_CAPTCHA_PAKO_URL                       = local.captcha_assets[local.dev_captcha_assets_env].pako
      },
      var.bunny_cdn_enablement == "yes" ? {
        BUNNY_PULLZONE_ID         = module.bunny_cdn_waf[0].pullzone.id
        BUNNY_API_KEY_SECRET_NAME = data.azurerm_key_vault_secret.bunnynet_api_key[0].name
      } : {}
    )
  }
}

resource "azurerm_storage_blob" "config" {
  provider             = azurerm.shared
  name                 = "${local.templates_folder}/${local.app_name}-EnvVars.json"
  storage_container_id = data.azurerm_storage_container.configs.id
  type                 = "Block"
  content_type         = "application/json"
  source_content       = jsonencode(local.env_var_blob)
  content_md5          = md5(jsonencode(local.env_var_blob))
}
