# Global identity for Arc Pull persmissions
module "avm-res-managedidentity-userassignedidentity-global-arcpull" {
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3"
  enable_telemetry    = false
  name                = "id-cae-wkflo-global-cruksubiqshared-arcpull"
  resource_group_name = azurerm_resource_group.shared.name
  location            = azurerm_resource_group.shared.location
  tags                = local.tags
}

# Identities for the regional Container App Environments
module "avm-res-managedidentity-userassignedidentity-cae" {
  for_each = var.regions_enabled

  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3"
  enable_telemetry    = false
  name                = "id-${local.cae_names[each.key]}"
  resource_group_name = azurerm_resource_group.main[each.key].name
  location            = azurerm_resource_group.main[each.key].location
  tags                = local.tags
}

# Identities for the regional Azure Managed Redis instances
module "avm-res-managedidentity-userassignedidentity-redis" {
  for_each = var.regions_enabled

  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3"
  enable_telemetry    = false
  name                = "id-amr-${local.cae_names[each.key]}"
  resource_group_name = azurerm_resource_group.main[each.key].name
  location            = azurerm_resource_group.main[each.key].location
  tags                = local.tags
}

# Identities for the regional Azure SQL Servers
module "avm-res-managedidentity-userassignedidentity-sql" {
  for_each = var.regions_enabled

  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3"
  enable_telemetry    = false
  name                = "id-sql-${local.cae_names[each.key]}"
  resource_group_name = azurerm_resource_group.main[each.key].name
  location            = azurerm_resource_group.main[each.key].location
  tags                = local.tags
}

# Identities for the regional Azure SQL Databases
module "avm-res-managedidentity-userassignedidentity-sqldb" {
  for_each = var.regions_enabled

  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3"
  enable_telemetry    = false
  name                = "id-sqldb-${local.cae_names[each.key]}"
  resource_group_name = azurerm_resource_group.main[each.key].name
  location            = azurerm_resource_group.main[each.key].location
  tags                = local.tags
}

# Identities for the regional Storage Accounts
module "avm-res-managedidentity-userassignedidentity-st" {
  for_each = var.regions_enabled

  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3"
  enable_telemetry    = false
  name                = "id-st${lower(substr(random_id.main[each.key].hex, 0, 22))}"
  resource_group_name = azurerm_resource_group.main[each.key].name
  location            = azurerm_resource_group.main[each.key].location
  tags                = local.tags
}

# Identities for the regional net flow log Storage Accounts
module "avm-res-managedidentity-userassignedidentity-st-netflowlogs" {
  for_each = var.regions_enabled

  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3"
  enable_telemetry    = false
  name                = "id-st${lower(substr(random_id.netflowlog[each.key].hex, 0, 22))}"
  resource_group_name = azurerm_resource_group.main[each.key].name
  location            = azurerm_resource_group.main[each.key].location
  tags                = local.tags
}

# MI for flow logs to use to connect to the storage account
module "avm-res-managedidentity-userassignedidentity-nwfl" {
  for_each = var.regions_enabled

  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3"
  enable_telemetry    = false
  name                = "id-st${lower(substr(random_id.netflowlog[each.key].hex, 0, 22))}-flow-log"
  resource_group_name = azurerm_resource_group.main[each.key].name
  location            = azurerm_resource_group.main[each.key].location
  tags                = local.tags
}

# Identities for the regional Service Bus Namespaces
module "avm-res-managedidentity-userassignedidentity-sbns" {
  for_each = var.regions_enabled

  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3"
  enable_telemetry    = false
  name                = "id-sbns-${local.cae_names[each.key]}"
  resource_group_name = azurerm_resource_group.main[each.key].name
  location            = azurerm_resource_group.main[each.key].location
  tags                = local.tags
}

# Identities for the regional Azure SignalR instances
module "avm-res-managedidentity-userassignedidentity-sigr" {
  for_each = var.regions_enabled

  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3"
  enable_telemetry    = false
  name                = "id-sigr-${local.cae_names[each.key]}"
  resource_group_name = azurerm_resource_group.main[each.key].name
  location            = azurerm_resource_group.main[each.key].location
  tags                = local.tags
}

# Identities for the regional Azure PostgreSQL Flexible Servers
module "avm-res-managedidentity-userassignedidentity-pgsql" {
  for_each = var.regions_enabled

  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3"
  enable_telemetry    = false
  name                = "id-pgsql-${local.cae_names[each.key]}"
  resource_group_name = azurerm_resource_group.main[each.key].name
  location            = azurerm_resource_group.main[each.key].location
  tags                = local.tags
}

resource "time_sleep" "azurerm_userassignedidentity_all" {
  create_duration = "60s"

  triggers = merge(
    {
      global_id = module.avm-res-managedidentity-userassignedidentity-global-arcpull.resource_id
    },
    {
      for k, v in module.avm-res-managedidentity-userassignedidentity-cae : k => v.resource_id
    },
    {
      for k, v in module.avm-res-managedidentity-userassignedidentity-redis : k => v.resource_id
    },
    {
      for k, v in module.avm-res-managedidentity-userassignedidentity-sql : k => v.resource_id
    },
    {
      for k, v in module.avm-res-managedidentity-userassignedidentity-sqldb : k => v.resource_id
    },
    {
      for k, v in module.avm-res-managedidentity-userassignedidentity-st : k => v.resource_id
    },
    {
      for k, v in module.avm-res-managedidentity-userassignedidentity-sbns : k => v.resource_id
    },
    {
      for k, v in module.avm-res-managedidentity-userassignedidentity-sigr : k => v.resource_id
    },
    {
      for k, v in module.avm-res-managedidentity-userassignedidentity-pgsql : k => v.resource_id
    }
  )
}
