moved {
  from = module.amais-ai-staging.azurerm_role_assignment.app_ais["255c319b-efcb-40ac-9058-2e154c387365"]
  to   = module.amais-ai-staging.azurerm_role_assignment.app_ais["app_openai_user"]
}

moved {
  from = module.amais-ai-prod.azurerm_role_assignment.app_ais["90fa9364-0be1-4ecb-ab48-2745695c9d75"]
  to   = module.amais-ai-prod.azurerm_role_assignment.app_ais["app_openai_user"]
}
