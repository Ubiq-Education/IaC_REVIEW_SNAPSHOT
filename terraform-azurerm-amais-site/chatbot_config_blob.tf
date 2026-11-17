locals {
  ai_config_blob_production = var.enable_ai_chatbot_staging || var.enable_ai_chatbot_production ? {
    name                        = lower(local.amais_application_name)
    azure_search_endpoint       = local.ai_search_endpoint
    azure_search_index_name     = lower(local.ai_search_index_names.production)
    azure_openai_endpoint       = local.amais_ai_url
    azure_openai_embedding_name = var.ai_chatbot_embedding_model_production
    school_base_url             = local.production_url
  } : {}
  ai_config_blob_staging = var.enable_ai_chatbot_staging || var.enable_ai_chatbot_production ? {
    name                        = lower(local.amais_application_name)
    azure_search_endpoint       = local.ai_search_endpoint
    azure_search_index_name     = lower(local.ai_search_index_names.staging)
    azure_openai_endpoint       = local.amais_ai_url
    azure_openai_embedding_name = var.ai_chatbot_embedding_model_staging
    school_base_url             = local.staging_url
  } : {}
}

resource "azurerm_storage_blob" "ai_config_blob_production" {
  count                = var.enable_ai_chatbot_staging || var.enable_ai_chatbot_production ? 1 : 0
  provider             = azurerm.shared
  name                 = "production/${lower(local.amais_application_name)}/infra-config.json"
  storage_container_id = "${data.azurerm_storage_account.uks_dxp.id}/blobServices/default/containers/0-datafeeder"
  type                 = "Block"
  content_type         = "application/json"
  source_content       = jsonencode(local.ai_config_blob_production)
  content_md5          = md5(jsonencode(local.ai_config_blob_production))
}

resource "azurerm_storage_blob" "ai_config_blob_staging" {
  count                = var.enable_ai_chatbot_staging || var.enable_ai_chatbot_production ? 1 : 0
  provider             = azurerm.shared
  name                 = "staging/${lower(local.amais_application_name)}/infra-config.json"
  storage_container_id = "${data.azurerm_storage_account.uks_dxp.id}/blobServices/default/containers/0-datafeeder"
  type                 = "Block"
  content_type         = "application/json"
  source_content       = jsonencode(local.ai_config_blob_staging)
  content_md5          = md5(jsonencode(local.ai_config_blob_staging))
}
