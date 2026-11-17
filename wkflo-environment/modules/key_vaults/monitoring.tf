module "monitoring_diagnostics" {
  source  = "api.controlmonkey.io/o-26drsisx9g/monitoring-diagnostics/azurerm"
  version = "~>1.2"
  diagnostics_destinations = {
    log_analytics = {
      enabled = true
    }
  }
  diagnostics_resource_ids = {
    main = module.avm-res-keyvault-vault.resource_id
  }
}
