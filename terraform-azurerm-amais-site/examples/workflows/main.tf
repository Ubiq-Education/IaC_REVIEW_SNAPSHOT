module "amais_site" {
  source  = "api.controlmonkey.io/o-26drsisx9g/amais-site/azurerm"
  version = "~>2.2.0"

  # ... required settings omitted for brevity ...

  ## Email Module should be enabled for workflow module to work as expected.
  enable_email_module_production            = true
  enable_email_module_staging               = true
  EmailStatsSyncJobSettings_slot_name       = "staging" # OPTIONAL - Default is "production"
  EmailSupressionsSyncJobSettings_slot_name = "staging" # OPTIONAL - Default is "production"

  ## Workflows
  enable_workflow_module_production = true
  enable_workflow_module_staging    = true
  WorkflowEngineJob_slot_name       = "staging" # OPTIONAL - Default is "production"
}
